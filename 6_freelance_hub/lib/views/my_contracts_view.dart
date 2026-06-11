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

  Future<void> _handleMarkDelivered(Contract c) async {
    if (_processingId != null) return;
    // Abre o composer para escolher fotos (opcional) e confirmar.
    final selected = await showModalBottomSheet<List<File>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _DeliveryComposerSheet(),
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
      await ContractsService.instance.markDelivered(c.id, photoUrls: urls);
      if (!mounted) return;
      _showSnack(
        urls.isEmpty
            ? 'Entrega registrada. Aguardando aprovação do cliente.'
            : 'Entrega registrada com ${urls.length} foto${urls.length == 1 ? '' : 's'}. Aguardando aprovação.',
        success: true,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack(_humanizeError(e, 'marcar como entregue'), success: false);
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

  String _humanizeError(Object e, String action) {
    if (e is FirebaseFunctionsException) {
      switch (e.code) {
        case 'unauthenticated':
          return 'Sessão expirada. Faça login novamente.';
        case 'permission-denied':
          return 'Você não tem permissão para $action.';
        case 'failed-precondition':
          return 'Contrato não está no status esperado.';
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

  Widget _buildContent(Color titleColor, Color mutedColor, bool isDark) {
    if (_loadError != null) {
      return _StateMessage(
        icon: Icons.error_outline,
        title: 'Erro',
        message: _loadError!,
        titleColor: titleColor,
        mutedColor: mutedColor,
      );
    }
    if (_stream == null) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }
    return StreamBuilder<List<Contract>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _primary),
          );
        }
        if (snapshot.hasError) {
          return _StateMessage(
            icon: Icons.error_outline,
            title: 'Erro',
            message: '${snapshot.error}',
            titleColor: titleColor,
            mutedColor: mutedColor,
          );
        }
        final contracts = snapshot.data ?? const <Contract>[];
        if (contracts.isEmpty) {
          return _StateMessage(
            icon: Icons.assignment_outlined,
            title: 'Nenhum contrato ainda',
            message: _role == UserRole.client
                ? 'Quando você aceitar propostas, os contratos aparecem aqui.'
                : 'Quando um cliente aceitar uma de suas propostas, o contrato aparece aqui.',
            titleColor: titleColor,
            mutedColor: mutedColor,
          );
        }
        return ListView.separated(
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
          ),
        );
      },
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

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? _slate800 : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : _primary.withValues(alpha: 0.10);

    // Contraparte = a outra parte do contrato em relação ao viewer.
    final counterpartyLabel =
        viewerRole == UserRole.client ? 'Freelancer' : 'Cliente';
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
              Flexible(
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
          if (showAcceptDelivery) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (isProcessing || actionsDisabled)
                    ? null
                    : onAcceptDelivery,
                icon: isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.task_alt, size: 18),
                label: const Text('Aprovar entrega'),
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
  const _DeliveryComposerSheet();

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
                'Confirmar entrega',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Anexe fotos do trabalho (opcional). Até $_maxPhotos imagens.',
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
                        ? 'Confirmar sem fotos'
                        : 'Confirmar entrega (${_photos.length})',
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
