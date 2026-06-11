import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../core/services/auth_service.dart';
import '../core/services/contracts_service.dart';
import '../core/services/storage_service.dart';
import '../models/contract.dart';
import '../models/user_role.dart';
import 'chat_view.dart';

const _primary = Color(0xFF3B309E);
const _surfaceCream = Color(0xFFFBF9F2);
const _slate900 = Color(0xFF0F172A);
const _slate500 = Color(0xFF64748B);
const _slate800 = Color(0xFF1E293B);
const _bgDark = Color(0xFF0B1020);

class MyContractsView extends StatefulWidget {
  const MyContractsView({super.key});

  @override
  State<MyContractsView> createState() => _MyContractsViewState();
}

class _MyContractsViewState extends State<MyContractsView> {
  Stream<List<Contract>>? _stream;
  UserRole? _role;
  String? _loadError;
  String? _processingId;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  Future<void> _handleMarkDelivered(Contract c) =>
      _handleDelivery(c, isResubmit: false);

  Future<void> _handleResubmitDelivery(Contract c) =>
      _handleDelivery(c, isResubmit: true);

  Future<void> _handleDelivery(Contract c, {required bool isResubmit}) async {
    if (_processingId != null) return;
    final selected = await showModalBottomSheet<List<File>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeliveryComposerSheet(isResubmit: isResubmit),
    );
    if (!mounted || selected == null) return;

    setState(() => _processingId = c.id);
    try {
      final urls = <String>[];
      for (final file in selected) {
        final url = await StorageService.instance.uploadDeliveryPhoto(
          contractId: c.id,
          file: file,
        );
        urls.add(url);
      }
      if (isResubmit) {
        await ContractsService.instance
            .resubmitDelivery(c.id, photoUrls: urls);
      } else {
        await ContractsService.instance.markDelivered(c.id, photoUrls: urls);
      }
      if (!mounted) return;
      final action = isResubmit ? 'Reenvio registrado' : 'Entrega registrada';
      _showSnack(
        urls.isEmpty
            ? '$action. Aguardando aprovação do cliente.'
            : '$action com ${urls.length} foto${urls.length == 1 ? '' : 's'}. Aguardando aprovação.',
        success: true,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack(
        _humanizeError(e, isResubmit ? 'reenviar' : 'marcar como entregue'),
        success: false,
      );
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  Future<void> _handleRequestRevision(Contract c) async {
    if (_processingId != null) return;
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _RevisionReasonSheet(),
    );
    if (!mounted || reason == null) return;

    setState(() => _processingId = c.id);
    try {
      await ContractsService.instance.requestRevision(c.id, reason);
      if (!mounted) return;
      _showSnack(
        'Revisão solicitada. O freelancer foi notificado.',
        success: true,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack(_humanizeError(e, 'solicitar revisão'), success: false);
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  Future<void> _handleAcceptDelivery(Contract c) async {
    if (_processingId != null) return;
    setState(() => _processingId = c.id);
    try {
      await ContractsService.instance.acceptDelivery(c.id);
      if (!mounted) return;
      _showSnack('Entrega aprovada! Contrato concluído.', success: true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(_humanizeError(e, 'aprovar entrega'), success: false);
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  void _openChat(Contract c) {
    final isClient = (_role ?? UserRole.freelancer) == UserRole.client;
    final otherUid = isClient ? c.freelancerId : c.clientId;
    final otherName = isClient
        ? (c.freelancerName.isEmpty ? 'Freelancer' : c.freelancerName)
        : (c.clientName.isEmpty ? 'Cliente' : c.clientName);
    if (otherUid.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatView(otherUid: otherUid, otherName: otherName),
      ),
    );
  }

  String _humanizeError(Object e, String action) {
    if (e is FirebaseFunctionsException) {
      switch (e.code) {
        case 'unauthenticated':
          return 'Sessão expirada. Faça login novamente.';
        case 'permission-denied':
          return 'Você não tem permissão para $action.';
        case 'failed-precondition':
          return 'O estado do contrato mudou. Puxe pra baixo pra atualizar e tente novamente.';
        case 'not-found':
          return 'Contrato não encontrado.';
        default:
          return 'Falha ao $action: ${e.message ?? e.code}';
      }
    }
    return 'Falha ao $action: $e';
  }

  void _showSnack(String message, {required bool success}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: success
              ? const Color(0xFF086B53)
              : const Color(0xFFBA1A1A),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      );
  }

  Future<void> _initStream() async {
    if (Firebase.apps.isEmpty) {
      setState(() {
        _stream = Stream<List<Contract>>.value(const []);
        _role = UserRole.freelancer;
      });
      return;
    }
    try {
      final user = await AuthService.instance.currentAppUser();
      if (!mounted) return;
      if (user == null) {
        setState(() => _loadError = 'Sessão expirada. Faça login novamente.');
        return;
      }
      setState(() {
        _role = user.role;
        _stream = user.role == UserRole.freelancer
            ? ContractsService.instance.streamContractsByFreelancer(user.uid)
            : ContractsService.instance.streamContractsByClient(user.uid);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = 'Falha ao carregar contratos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _bgDark : _surfaceCream;
    final titleColor = isDark ? Colors.white : _slate900;
    final mutedColor = isDark ? Colors.white70 : _slate500;
    final cardBg = isDark ? _slate800 : Colors.white;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: cardBg,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TopBar(titleColor: titleColor),
              Expanded(
                child: _buildContent(titleColor, mutedColor, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Força reassinar a stream — útil quando a UI fica stale (ex.: depois de
  /// hot reload ou cache local divergente do servidor). RefreshIndicator
  /// chama isso quando o user puxa pra baixo.
  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => _loadError = null);
    await _initStream();
    // Pequeno delay pra dar feedback visual mesmo quando a re-emissão é instantânea.
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  Widget _buildContent(Color titleColor, Color mutedColor, bool isDark) {
    if (_loadError != null) {
      return RefreshIndicator(
        color: _primary,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: _StateMessage(
                icon: Icons.error_outline,
                title: 'Erro',
                message: _loadError!,
                titleColor: titleColor,
                mutedColor: mutedColor,
              ),
            ),
          ],
        ),
      );
    }
    if (_stream == null) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }
    return RefreshIndicator(
      color: _primary,
      onRefresh: _refresh,
      child: StreamBuilder<List<Contract>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _primary),
            );
          }
          if (snapshot.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: _StateMessage(
                    icon: Icons.error_outline,
                    title: 'Erro',
                    message: '${snapshot.error}',
                    titleColor: titleColor,
                    mutedColor: mutedColor,
                  ),
                ),
              ],
            );
          }
          final contracts = snapshot.data ?? const <Contract>[];
          if (contracts.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: _StateMessage(
                    icon: Icons.assignment_outlined,
                    title: 'Nenhum contrato ainda',
                    message: _role == UserRole.client
                        ? 'Quando você aceitar propostas, os contratos aparecem aqui.'
                        : 'Quando um cliente aceitar uma de suas propostas, o contrato aparece aqui.',
                    titleColor: titleColor,
                    mutedColor: mutedColor,
                  ),
                ),
              ],
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: contracts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _ContractCard(
              contract: contracts[i],
              viewerRole: _role ?? UserRole.freelancer,
              isDark: isDark,
              titleColor: titleColor,
              mutedColor: mutedColor,
              isProcessing: _processingId == contracts[i].id,
              actionsDisabled:
                  _processingId != null && _processingId != contracts[i].id,
              onMarkDelivered: () => _handleMarkDelivered(contracts[i]),
              onAcceptDelivery: () => _handleAcceptDelivery(contracts[i]),
              onRequestRevision: () =>
                  _handleRequestRevision(contracts[i]),
              onResubmitDelivery: () =>
                  _handleResubmitDelivery(contracts[i]),
              onOpenChat: () => _openChat(contracts[i]),
            ),
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.titleColor});

  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: Icon(Icons.arrow_back, color: titleColor),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 48),
                child: Text(
                  'Meus contratos',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: titleColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.titleColor,
    required this.mutedColor,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color titleColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: mutedColor),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
          ),
        ],
      ),
    );
  }
}

class _ContractCard extends StatelessWidget {
  const _ContractCard({
    required this.contract,
    required this.viewerRole,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.isProcessing,
    required this.actionsDisabled,
    required this.onMarkDelivered,
    required this.onAcceptDelivery,
    required this.onRequestRevision,
    required this.onResubmitDelivery,
    required this.onOpenChat,
  });

  final Contract contract;
  final UserRole viewerRole;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final bool isProcessing;
  final bool actionsDisabled;
  final VoidCallback onMarkDelivered;
  final VoidCallback onAcceptDelivery;
  final VoidCallback onRequestRevision;
  final VoidCallback onResubmitDelivery;
  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? _slate800 : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : _primary.withValues(alpha: 0.10);

    // Contraparte = a outra parte do contrato em relação ao viewer.
    final counterpartyLabel =
        viewerRole == UserRole.client ? 'Freelancer' : 'Cliente';
    final counterpartyUid = viewerRole == UserRole.client
        ? contract.freelancerId
        : contract.clientId;
    final rawCounterpartyName = viewerRole == UserRole.client
        ? contract.freelancerName
        : contract.clientName;
    final counterpartyName = rawCounterpartyName.isEmpty
        ? counterpartyLabel
        : rawCounterpartyName;

    final showMarkDelivered = viewerRole == UserRole.freelancer &&
        contract.status == ContractStatus.active;
    final showAcceptDelivery = viewerRole == UserRole.client &&
        contract.status == ContractStatus.delivered;
    final showRequestRevision = viewerRole == UserRole.client &&
        contract.status == ContractStatus.delivered;
    final showResubmitDelivery = viewerRole == UserRole.freelancer &&
        contract.status == ContractStatus.revisionRequested;
    // Motivo da revisão é relevante pro freelancer (que precisa agir) ou
    // como histórico se o contrato já voltou a delivered/completed depois.
    final showRevisionReason = contract.revisionReason.isNotEmpty &&
        (contract.status == ContractStatus.revisionRequested ||
            contract.revisionCount > 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  contract.projectTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: contract.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MetaItem(
                icon: Icons.attach_money,
                label: _formatValue(contract.value, contract.isHourly),
                color: mutedColor,
              ),
              const SizedBox(width: 14),
              _MetaItem(
                icon: Icons.event_outlined,
                label: contract.daysEstimate == 1
                    ? '1 dia'
                    : '${contract.daysEstimate} dias',
                color: mutedColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: mutedColor),
              const SizedBox(width: 4),
              Text(
                '$counterpartyLabel: ',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: mutedColor,
                ),
              ),
              Expanded(
                child: Text(
                  counterpartyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
              ),
              if (counterpartyUid.isNotEmpty)
                InkWell(
                  onTap: onOpenChat,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 14,
                          color: _primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Mensagem',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (contract.deliveryPhotoUrls.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Anexos da entrega',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: mutedColor,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: contract.deliveryPhotoUrls.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) => GestureDetector(
                  onTap: () => Navigator.of(ctx).push(
                    MaterialPageRoute(
                      builder: (_) => _PhotoFullscreenView(
                        url: contract.deliveryPhotoUrls[i],
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      contract.deliveryPhotoUrls[i],
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          width: 72,
                          height: 72,
                          color: mutedColor.withValues(alpha: 0.15),
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: mutedColor,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, _, _) => Container(
                        width: 72,
                        height: 72,
                        color: mutedColor.withValues(alpha: 0.15),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: mutedColor,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            _relativeDate(contract.createdAt),
            style: GoogleFonts.inter(
              fontSize: 11,
              color: mutedColor,
              letterSpacing: 0.2,
            ),
          ),
          if (showMarkDelivered) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (isProcessing || actionsDisabled)
                    ? null
                    : onMarkDelivered,
                icon: isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Marcar como entregue'),
                style: FilledButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _primary.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
          if (showRevisionReason) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFC2410C).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFC2410C).withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.replay_circle_filled_outlined,
                        size: 14,
                        color: Color(0xFFC2410C),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        contract.revisionCount > 1
                            ? 'Última revisão solicitada (${contract.revisionCount}ª)'
                            : 'Revisão solicitada',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFC2410C),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    contract.revisionReason,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: titleColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (showAcceptDelivery || showRequestRevision) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: (isProcessing || actionsDisabled)
                        ? null
                        : onRequestRevision,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFC2410C),
                      side: const BorderSide(color: Color(0xFFC2410C)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Solicitar revisão'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: (isProcessing || actionsDisabled)
                        ? null
                        : onAcceptDelivery,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF086B53),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFF086B53).withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text('Aprovar'),
                  ),
                ),
              ],
            ),
          ],
          if (showResubmitDelivery) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (isProcessing || actionsDisabled)
                    ? null
                    : onResubmitDelivery,
                icon: isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.upload_outlined, size: 18),
                label: const Text('Reenviar entrega'),
                style: FilledButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _primary.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatValue(double value, bool isHourly) {
    final intPart = value.truncate();
    final buf = StringBuffer('R\$ ');
    final str = intPart.toString();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    if (isHourly) buf.write('/h');
    return buf.toString();
  }

  static String _relativeDate(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays >= 1) {
      final d = diff.inDays;
      return d == 1 ? 'iniciado há 1 dia' : 'iniciado há $d dias';
    }
    if (diff.inHours >= 1) {
      final h = diff.inHours;
      return h == 1 ? 'iniciado há 1 hora' : 'iniciado há $h horas';
    }
    if (diff.inMinutes >= 1) {
      final m = diff.inMinutes;
      return m == 1 ? 'iniciado há 1 minuto' : 'iniciado há $m minutos';
    }
    return 'iniciado agora';
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ContractStatus status;

  @override
  Widget build(BuildContext context) {
    final spec = _specFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: spec.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        spec.label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: spec.fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  static _BadgeSpec _specFor(ContractStatus s) {
    switch (s) {
      case ContractStatus.active:
        return const _BadgeSpec(
          label: 'Em andamento',
          bg: Color(0xFFE0E7FF),
          fg: Color(0xFF3B309E),
        );
      case ContractStatus.delivered:
        return const _BadgeSpec(
          label: 'Entregue',
          bg: Color(0xFFFFF4DC),
          fg: Color(0xFF92571A),
        );
      case ContractStatus.revisionRequested:
        return const _BadgeSpec(
          label: 'Revisão pedida',
          bg: Color(0xFFFFE4E0),
          fg: Color(0xFFC2410C),
        );
      case ContractStatus.completed:
        return const _BadgeSpec(
          label: 'Concluído',
          bg: Color(0xFFD8F5E9),
          fg: Color(0xFF086B53),
        );
      case ContractStatus.disputed:
        return const _BadgeSpec(
          label: 'Em disputa',
          bg: Color(0xFFFADBDB),
          fg: Color(0xFFBA1A1A),
        );
    }
  }
}

class _BadgeSpec {
  const _BadgeSpec({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;
}

/// Bottom sheet pra compor a entrega: opcionalmente anexa fotos antes de
/// confirmar. Pop com `null` = cancelou, pop com lista (possivelmente vazia)
/// = confirmou.
class _DeliveryComposerSheet extends StatefulWidget {
  const _DeliveryComposerSheet({this.isResubmit = false});

  final bool isResubmit;

  @override
  State<_DeliveryComposerSheet> createState() => _DeliveryComposerSheetState();
}

class _DeliveryComposerSheetState extends State<_DeliveryComposerSheet> {
  static const _maxPhotos = 5;
  final _picker = ImagePicker();
  final List<File> _photos = [];

  Future<void> _pickFromCamera() async {
    if (_photos.length >= _maxPhotos) return;
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (picked == null || !mounted) return;
      setState(() => _photos.add(File(picked.path)));
    } catch (e) {
      if (!mounted) return;
      _showError('Não foi possível abrir a câmera: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    if (_photos.length >= _maxPhotos) return;
    try {
      final remaining = _maxPhotos - _photos.length;
      final picked = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        limit: remaining,
      );
      if (picked.isEmpty || !mounted) return;
      setState(() => _photos.addAll(picked.map((x) => File(x.path))));
    } catch (e) {
      if (!mounted) return;
      _showError('Não foi possível abrir a galeria: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFBA1A1A),
        content: Text(message, style: GoogleFonts.inter(fontSize: 13)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _slate800 : Colors.white;
    final titleColor = isDark ? Colors.white : _slate900;
    final mutedColor = isDark ? Colors.white70 : _slate500;
    final atLimit = _photos.length >= _maxPhotos;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: mutedColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.isResubmit ? 'Reenviar entrega' : 'Confirmar entrega',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.isResubmit
                    ? 'Anexe as novas fotos do trabalho ajustado. Até $_maxPhotos imagens.'
                    : 'Anexe fotos do trabalho (opcional). Até $_maxPhotos imagens.',
                style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
              ),
              const SizedBox(height: 16),
              if (_photos.isNotEmpty) ...[
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _photos.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => _ThumbWithRemove(
                      file: _photos[i],
                      onRemove: () => setState(() => _photos.removeAt(i)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: atLimit ? null : _pickFromCamera,
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: const Text('Câmera'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: BorderSide(
                          color: _primary.withValues(
                            alpha: atLimit ? 0.3 : 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: atLimit ? null : _pickFromGallery,
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: const Text('Galeria'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: BorderSide(
                          color: _primary.withValues(
                            alpha: atLimit ? 0.3 : 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_photos),
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(
                    _photos.isEmpty
                        ? (widget.isResubmit
                            ? 'Reenviar sem fotos'
                            : 'Confirmar sem fotos')
                        : (widget.isResubmit
                            ? 'Reenviar entrega (${_photos.length})'
                            : 'Confirmar entrega (${_photos.length})'),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: mutedColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThumbWithRemove extends StatelessWidget {
  const _ThumbWithRemove({required this.file, required this.onRemove});

  final File file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            file,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Color(0xFFBA1A1A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// Viewer fullscreen para fotos da entrega.
class _PhotoFullscreenView extends StatelessWidget {
  const _PhotoFullscreenView({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return const CircularProgressIndicator(color: Colors.white);
            },
            errorBuilder: (_, _, _) => const Text(
              'Falha ao carregar imagem',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet pra capturar o motivo da revisão. Pop com `null` = cancelou,
/// pop com a string trimmed = confirmou. Valida tamanho client-side; o
/// server revalida 10..500 chars.
class _RevisionReasonSheet extends StatefulWidget {
  const _RevisionReasonSheet();

  @override
  State<_RevisionReasonSheet> createState() => _RevisionReasonSheetState();
}

class _RevisionReasonSheetState extends State<_RevisionReasonSheet> {
  static const _minChars = 10;
  static const _maxChars = 500;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _slate800 : Colors.white;
    final titleColor = isDark ? Colors.white : _slate900;
    final mutedColor = isDark ? Colors.white70 : _slate500;
    final inputBorder = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : const Color(0xFFE2E8F0);

    final trimmed = _controller.text.trim();
    final canSubmit = trimmed.length >= _minChars;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: mutedColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Solicitar revisão',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Descreva os ajustes que o freelancer precisa fazer. '
                'Mínimo $_minChars caracteres.',
                style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                maxLines: 5,
                minLines: 4,
                maxLength: _maxChars,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.inter(fontSize: 14, color: titleColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFFBF9F2),
                  hintText: 'Ex.: A paleta de cores está fora do brief — '
                      'usar o roxo da marca em vez do azul.',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 13,
                    color: mutedColor.withValues(alpha: 0.7),
                  ),
                  counterStyle:
                      GoogleFonts.inter(fontSize: 11, color: mutedColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFC2410C),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      canSubmit ? () => Navigator.of(context).pop(trimmed) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFC2410C),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFFC2410C).withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(
                    canSubmit
                        ? 'Enviar solicitação'
                        : 'Faltam ${(_minChars - trimmed.length).clamp(0, _minChars)} caracteres',
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: mutedColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
