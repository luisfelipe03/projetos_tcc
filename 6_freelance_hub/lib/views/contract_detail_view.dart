import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/services/auth_service.dart';
import '../core/services/contracts_service.dart';
import '../core/services/reviews_service.dart';
import '../core/services/storage_service.dart';
import '../models/contract.dart';
import '../models/review.dart';
import '../models/user_role.dart';
import '../widgets/contract_widgets.dart';
import '../widgets/rating_stars.dart';
import '../widgets/submit_review_sheet.dart';
import 'chat_view.dart';
import 'public_profile_view.dart';

const _primary = Color(0xFF3B309E);
const _surfaceCream = Color(0xFFFBF9F2);
const _slate900 = Color(0xFF0F172A);
const _slate500 = Color(0xFF64748B);
const _slate800 = Color(0xFF1E293B);
const _bgDark = Color(0xFF0B1020);
const _successGreen = Color(0xFF086B53);
const _errorRed = Color(0xFFBA1A1A);
const _orange = Color(0xFFC2410C);

class ContractDetailView extends StatefulWidget {
  const ContractDetailView({super.key, required this.contractId});

  final String contractId;

  @override
  State<ContractDetailView> createState() => _ContractDetailViewState();
}

class _ContractDetailViewState extends State<ContractDetailView> {
  Stream<Contract?>? _stream;
  UserRole? _viewerRole;
  String? _viewerUid;
  String? _loadError;
  String? _processingAction; // 'deliver' | 'accept' | 'revision' | 'resubmit' | 'review'
  String? _counterpartyPhotoUrl;
  Review? _myReview;
  Review? _counterpartyReview;
  bool _reviewsLoadedForCompleted = false;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  Future<void> _initStream() async {
    if (Firebase.apps.isEmpty) {
      setState(() {
        _stream = Stream<Contract?>.value(null);
        _viewerRole = UserRole.freelancer;
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
        _viewerRole = user.role;
        _viewerUid = user.uid;
        _stream = ContractsService.instance.streamContract(widget.contractId);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = 'Falha ao carregar contrato: $e');
    }
  }

  Future<void> _loadReviews(Contract contract) async {
    if (_reviewsLoadedForCompleted) return;
    final viewerUid = _viewerUid ?? '';
    if (viewerUid.isEmpty) return;
    if (contract.status != ContractStatus.completed) return;

    _reviewsLoadedForCompleted = true;
    final counterpartyUid = viewerUid == contract.clientId
        ? contract.freelancerId
        : contract.clientId;
    try {
      final results = await Future.wait([
        ReviewsService.instance.getMyReview(
          contractId: contract.id,
          reviewerId: viewerUid,
        ),
        ReviewsService.instance.getMyReview(
          contractId: contract.id,
          reviewerId: counterpartyUid,
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _myReview = results[0];
        _counterpartyReview = results[1];
      });
    } catch (_) {
      // Falha aqui não bloqueia o detail — pior caso o user toca em "Avaliar"
      // e o erro do callable mostra SnackBar.
    }
  }

  Future<void> _handleSubmitReview(Contract contract) async {
    if (_processingAction != null) return;
    final viewerUid = _viewerUid ?? '';
    if (viewerUid.isEmpty) return;

    final isClient = (_viewerRole ?? UserRole.freelancer) == UserRole.client;
    final revieweeName = isClient
        ? (contract.freelancerName.isEmpty
            ? 'o freelancer'
            : contract.freelancerName)
        : (contract.clientName.isEmpty ? 'o cliente' : contract.clientName);

    final draft = await showModalBottomSheet<ReviewDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SubmitReviewSheet(revieweeName: revieweeName),
    );
    if (!mounted || draft == null) return;

    setState(() => _processingAction = 'review');
    try {
      await ReviewsService.instance.submitReview(
        contractId: contract.id,
        rating: draft.rating,
        comment: draft.comment,
      );
      if (!mounted) return;
      _showSnack('Avaliação enviada. Obrigado!', success: true);
      // Re-fetch pra mostrar a review nova na UI.
      _reviewsLoadedForCompleted = false;
      await _loadReviews(contract);
    } catch (e) {
      if (!mounted) return;
      _showSnack(_humanizeError(e, 'avaliar'), success: false);
    } finally {
      if (mounted) setState(() => _processingAction = null);
    }
  }

  Future<void> _loadCounterpartyPhoto(String counterpartyUid) async {
    if (counterpartyUid.isEmpty || _counterpartyPhotoUrl != null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(counterpartyUid)
          .get();
      if (!mounted || !doc.exists) return;
      final url = doc.data()?['photoUrl'] as String?;
      if (url == null || url.isEmpty) return;
      setState(() => _counterpartyPhotoUrl = url);
    } catch (_) {
      // Foto ausente não bloqueia o detail.
    }
  }

  Future<void> _handleMarkDelivered(Contract c) =>
      _handleDelivery(c, isResubmit: false);

  Future<void> _handleResubmitDelivery(Contract c) =>
      _handleDelivery(c, isResubmit: true);

  Future<void> _handleDelivery(Contract c, {required bool isResubmit}) async {
    if (_processingAction != null) return;
    final selected = await showModalBottomSheet<List<File>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeliveryComposerSheet(isResubmit: isResubmit),
    );
    if (!mounted || selected == null) return;

    setState(() => _processingAction = isResubmit ? 'resubmit' : 'deliver');
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
      if (mounted) setState(() => _processingAction = null);
    }
  }

  Future<void> _handleRequestRevision(Contract c) async {
    if (_processingAction != null) return;
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RevisionReasonSheet(),
    );
    if (!mounted || reason == null) return;

    setState(() => _processingAction = 'revision');
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
      if (mounted) setState(() => _processingAction = null);
    }
  }

  Future<void> _handleAcceptDelivery(Contract c) async {
    if (_processingAction != null) return;
    setState(() => _processingAction = 'accept');
    try {
      await ContractsService.instance.acceptDelivery(c.id);
      if (!mounted) return;
      _showSnack('Entrega aprovada! Contrato concluído.', success: true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(_humanizeError(e, 'aprovar entrega'), success: false);
    } finally {
      if (mounted) setState(() => _processingAction = null);
    }
  }

  void _openChat(Contract c) {
    final isClient = (_viewerRole ?? UserRole.freelancer) == UserRole.client;
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
          return 'O estado do contrato mudou. Aguarde a atualização.';
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
          backgroundColor: success ? _successGreen : _errorRed,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _bgDark : _surfaceCream;
    final cardBg = isDark ? _slate800 : Colors.white;
    final titleColor = isDark ? Colors.white : _slate900;
    final mutedColor = isDark ? Colors.white70 : _slate500;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : _primary.withValues(alpha: 0.10);

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
                child: _buildBody(
                  cardBg: cardBg,
                  titleColor: titleColor,
                  mutedColor: mutedColor,
                  borderColor: borderColor,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required Color cardBg,
    required Color titleColor,
    required Color mutedColor,
    required Color borderColor,
    required bool isDark,
  }) {
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

    return StreamBuilder<Contract?>(
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
        final contract = snapshot.data;
        if (contract == null) {
          return _StateMessage(
            icon: Icons.search_off,
            title: 'Contrato não encontrado',
            message:
                'Pode ter sido removido. Volte para a lista de contratos.',
            titleColor: titleColor,
            mutedColor: mutedColor,
          );
        }

        final viewerRole = _viewerRole ?? UserRole.freelancer;
        final isClient = viewerRole == UserRole.client;
        final counterpartyUid = isClient
            ? contract.freelancerId
            : contract.clientId;
        final counterpartyName = isClient
            ? (contract.freelancerName.isEmpty
                ? 'Freelancer'
                : contract.freelancerName)
            : (contract.clientName.isEmpty
                ? 'Cliente'
                : contract.clientName);
        final counterpartyLabel = isClient ? 'Freelancer' : 'Cliente';

        // Foto da contraparte é carregada lazy (1 read, só na primeira vez).
        if (counterpartyUid.isNotEmpty && _counterpartyPhotoUrl == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadCounterpartyPhoto(counterpartyUid);
          });
        }

        // Reviews só fazem sentido pra contratos concluídos. Lazy load 1x.
        if (contract.status == ContractStatus.completed &&
            !_reviewsLoadedForCompleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadReviews(contract);
          });
        }

        final actions = _buildActions(
          contract: contract,
          viewerRole: viewerRole,
          cardBg: cardBg,
          borderColor: borderColor,
        );

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  _HeaderCard(
                    contract: contract,
                    cardBg: cardBg,
                    titleColor: titleColor,
                    mutedColor: mutedColor,
                    borderColor: borderColor,
                  ),
                  const SizedBox(height: 12),
                  _CounterpartyCard(
                    label: counterpartyLabel,
                    name: counterpartyName,
                    photoUrl: _counterpartyPhotoUrl,
                    canOpenChat: counterpartyUid.isNotEmpty,
                    cardBg: cardBg,
                    titleColor: titleColor,
                    mutedColor: mutedColor,
                    borderColor: borderColor,
                    onOpenChat: () => _openChat(contract),
                    onOpenProfile: counterpartyUid.isEmpty
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    PublicProfileView(uid: counterpartyUid),
                              ),
                            ),
                  ),
                  const SizedBox(height: 12),
                  _TimelineCard(
                    contract: contract,
                    cardBg: cardBg,
                    titleColor: titleColor,
                    mutedColor: mutedColor,
                    borderColor: borderColor,
                  ),
                  if (contract.revisionReason.isNotEmpty &&
                      (contract.status == ContractStatus.revisionRequested ||
                          contract.revisionCount > 0)) ...[
                    const SizedBox(height: 12),
                    _RevisionReasonCard(
                      contract: contract,
                      titleColor: titleColor,
                    ),
                  ],
                  if (contract.deliveryPhotoUrls.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _GalleryCard(
                      urls: contract.deliveryPhotoUrls,
                      cardBg: cardBg,
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                      borderColor: borderColor,
                    ),
                  ],
                  if (contract.status == ContractStatus.completed) ...[
                    const SizedBox(height: 12),
                    _ReviewsCard(
                      contract: contract,
                      myReview: _myReview,
                      counterpartyReview: _counterpartyReview,
                      counterpartyName: counterpartyName,
                      submitting: _processingAction == 'review',
                      onSubmit: () => _handleSubmitReview(contract),
                      cardBg: cardBg,
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                      borderColor: borderColor,
                    ),
                  ],
                ],
              ),
            ),
            ?actions,
          ],
        );
      },
    );
  }

  Widget? _buildActions({
    required Contract contract,
    required UserRole viewerRole,
    required Color cardBg,
    required Color borderColor,
  }) {
    final isClient = viewerRole == UserRole.client;
    final processing = _processingAction;
    final isProcessing = processing != null;

    final showMarkDelivered =
        !isClient && contract.status == ContractStatus.active;
    final showResubmit =
        !isClient && contract.status == ContractStatus.revisionRequested;
    final showAcceptOrRevise =
        isClient && contract.status == ContractStatus.delivered;

    if (!showMarkDelivered && !showResubmit && !showAcceptOrRevise) {
      return null;
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: showAcceptOrRevise
              ? Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isProcessing
                            ? null
                            : () => _handleRequestRevision(contract),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _orange,
                          side: const BorderSide(color: _orange),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: processing == 'revision'
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(_orange),
                                ),
                              )
                            : const Text('Solicitar revisão'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: isProcessing
                            ? null
                            : () => _handleAcceptDelivery(contract),
                        style: FilledButton.styleFrom(
                          backgroundColor: _successGreen,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              _successGreen.withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: processing == 'accept'
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Text('Aprovar entrega'),
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isProcessing
                        ? null
                        : (showMarkDelivered
                            ? () => _handleMarkDelivered(contract)
                            : () => _handleResubmitDelivery(contract)),
                    icon: isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Icon(
                            showMarkDelivered
                                ? Icons.check_circle_outline
                                : Icons.upload_outlined,
                            size: 18,
                          ),
                    label: Text(
                      showMarkDelivered
                          ? 'Marcar como entregue'
                          : 'Reenviar entrega',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _primary.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
        ),
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
                  'Detalhes do contrato',
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.contract,
    required this.cardBg,
    required this.titleColor,
    required this.mutedColor,
    required this.borderColor,
  });

  final Contract contract;
  final Color cardBg;
  final Color titleColor;
  final Color mutedColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  contract.projectTitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: titleColor,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ContractStatusBadge(status: contract.status, large: true),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _InfoChip(
                icon: Icons.attach_money,
                label: formatContractValue(contract.value, contract.isHourly),
                color: titleColor,
                muted: mutedColor,
              ),
              const SizedBox(width: 20),
              _InfoChip(
                icon: Icons.event_outlined,
                label: contract.daysEstimate == 1
                    ? '1 dia'
                    : '${contract.daysEstimate} dias',
                color: titleColor,
                muted: mutedColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.muted,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: muted),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _CounterpartyCard extends StatelessWidget {
  const _CounterpartyCard({
    required this.label,
    required this.name,
    required this.photoUrl,
    required this.canOpenChat,
    required this.cardBg,
    required this.titleColor,
    required this.mutedColor,
    required this.borderColor,
    required this.onOpenChat,
    required this.onOpenProfile,
  });

  final String label;
  final String name;
  final String? photoUrl;
  final bool canOpenChat;
  final Color cardBg;
  final Color titleColor;
  final Color mutedColor;
  final Color borderColor;
  final VoidCallback onOpenChat;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final identityRow = Row(
      children: [
        _Avatar(name: name, photoUrl: photoUrl, size: 48),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: mutedColor,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: onOpenProfile == null
                ? identityRow
                : InkWell(
                    onTap: onOpenProfile,
                    borderRadius: BorderRadius.circular(8),
                    child: identityRow,
                  ),
          ),
          if (canOpenChat)
            FilledButton.icon(
              onPressed: onOpenChat,
              icon: const Icon(Icons.chat_bubble_outline, size: 16),
              label: const Text('Mensagem'),
              style: FilledButton.styleFrom(
                backgroundColor: _primary.withValues(alpha: 0.1),
                foregroundColor: _primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.name,
    required this.photoUrl,
    required this.size,
  });

  final String name;
  final String? photoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _initials(),
        ),
      );
    }
    return _initials();
  }

  Widget _initials() {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _primary.withValues(alpha: 0.18),
      ),
      child: Text(
        _initialsOf(name),
        style: GoogleFonts.dmSans(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          color: _primary,
        ),
      ),
    );
  }

  static String _initialsOf(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.contract,
    required this.cardBg,
    required this.titleColor,
    required this.mutedColor,
    required this.borderColor,
  });

  final Contract contract;
  final Color cardBg;
  final Color titleColor;
  final Color mutedColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final marks = _buildMarks();
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
          Text(
            'Linha do tempo',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < marks.length; i++)
            _TimelineRow(
              mark: marks[i],
              isLast: i == marks.length - 1,
              titleColor: titleColor,
              mutedColor: mutedColor,
            ),
        ],
      ),
    );
  }

  List<_TimelineMark> _buildMarks() {
    final s = contract.status;
    final hasDelivered = s == ContractStatus.delivered ||
        s == ContractStatus.revisionRequested ||
        s == ContractStatus.completed;
    final hasRevision = contract.revisionCount > 0;
    final isCompleted = s == ContractStatus.completed;

    return [
      _TimelineMark(
        label: 'Contrato iniciado',
        subtitle: relativeContractDate(contract.createdAt),
        icon: Icons.flag_outlined,
        active: true,
      ),
      _TimelineMark(
        label: 'Entrega enviada',
        subtitle: hasDelivered
            ? (s == ContractStatus.delivered
                ? 'Aguardando aprovação do cliente'
                : 'Entrega registrada')
            : 'Freelancer ainda não entregou',
        icon: Icons.send_outlined,
        active: hasDelivered,
      ),
      if (hasRevision)
        _TimelineMark(
          label: contract.revisionCount > 1
              ? 'Revisão solicitada (${contract.revisionCount}ª)'
              : 'Revisão solicitada',
          subtitle: s == ContractStatus.revisionRequested
              ? 'Aguardando reenvio do freelancer'
              : 'Reenviada pelo freelancer',
          icon: Icons.replay_circle_filled_outlined,
          active: true,
          accent: _orange,
        ),
      _TimelineMark(
        label: 'Contrato concluído',
        subtitle: isCompleted
            ? 'Cliente aprovou a entrega'
            : 'Aguardando aprovação final',
        icon: Icons.verified_outlined,
        active: isCompleted,
        accent: isCompleted ? _successGreen : null,
      ),
    ];
  }
}

class _TimelineMark {
  const _TimelineMark({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.active,
    this.accent,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool active;
  final Color? accent;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.mark,
    required this.isLast,
    required this.titleColor,
    required this.mutedColor,
  });

  final _TimelineMark mark;
  final bool isLast;
  final Color titleColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final accent = mark.accent ?? _primary;
    final fg = mark.active ? accent : mutedColor.withValues(alpha: 0.6);
    final bg = mark.active
        ? accent.withValues(alpha: 0.15)
        : mutedColor.withValues(alpha: 0.10);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
                child: Icon(mark.icon, size: 16, color: fg),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: mutedColor.withValues(alpha: 0.18),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mark.label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: mark.active
                          ? titleColor
                          : mutedColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mark.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: mutedColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevisionReasonCard extends StatelessWidget {
  const _RevisionReasonCard({
    required this.contract,
    required this.titleColor,
  });

  final Contract contract;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _orange.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.replay_circle_filled_outlined,
                size: 16,
                color: _orange,
              ),
              const SizedBox(width: 6),
              Text(
                contract.revisionCount > 1
                    ? 'Última revisão (${contract.revisionCount}ª)'
                    : 'Revisão solicitada',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _orange,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            contract.revisionReason,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: titleColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard({
    required this.urls,
    required this.cardBg,
    required this.titleColor,
    required this.mutedColor,
    required this.borderColor,
  });

  final List<String> urls;
  final Color cardBg;
  final Color titleColor;
  final Color mutedColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
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
              Text(
                'Anexos da entrega',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${urls.length}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: mutedColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: urls.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (ctx, i) => GestureDetector(
              onTap: () => Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (_) => ContractPhotoFullscreenView(url: urls[i]),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  urls[i],
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
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
        ],
      ),
    );
  }
}

class _ReviewsCard extends StatelessWidget {
  const _ReviewsCard({
    required this.contract,
    required this.myReview,
    required this.counterpartyReview,
    required this.counterpartyName,
    required this.submitting,
    required this.onSubmit,
    required this.cardBg,
    required this.titleColor,
    required this.mutedColor,
    required this.borderColor,
  });

  final Contract contract;
  final Review? myReview;
  final Review? counterpartyReview;
  final String counterpartyName;
  final bool submitting;
  final VoidCallback onSubmit;
  final Color cardBg;
  final Color titleColor;
  final Color mutedColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Avaliações',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 12),
          _myReviewSection(),
          const SizedBox(height: 14),
          Container(height: 1, color: borderColor),
          const SizedBox(height: 14),
          _counterpartyReviewSection(),
        ],
      ),
    );
  }

  Widget _myReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SUA AVALIAÇÃO',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: mutedColor,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        if (myReview != null) ...[
          RatingStars(value: myReview!.rating, size: 22),
          if (myReview!.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              myReview!.comment,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: titleColor,
                height: 1.4,
              ),
            ),
          ],
        ] else ...[
          Text(
            'Como foi trabalhar com $counterpartyName? Sua avaliação ajuda '
            'outras pessoas a decidirem.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: mutedColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: submitting ? null : onSubmit,
              icon: submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.star_rounded, size: 18),
              label: const Text('Avaliar agora'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3B309E),
                foregroundColor: Colors.white,
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
    );
  }

  Widget _counterpartyReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AVALIAÇÃO DA CONTRAPARTE',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: mutedColor,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        if (counterpartyReview != null) ...[
          RatingStars(value: counterpartyReview!.rating, size: 22),
          if (counterpartyReview!.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              counterpartyReview!.comment,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: titleColor,
                height: 1.4,
              ),
            ),
          ],
        ] else ...[
          Text(
            'Aguardando avaliação de $counterpartyName.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: mutedColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
