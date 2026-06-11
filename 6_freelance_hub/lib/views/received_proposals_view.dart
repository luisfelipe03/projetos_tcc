import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/services/auth_service.dart';
import '../core/services/proposals_service.dart';
import '../models/proposal.dart';

const _primary = Color(0xFF3B309E);
const _surfaceCream = Color(0xFFFBF9F2);
const _slate900 = Color(0xFF0F172A);
const _slate500 = Color(0xFF64748B);
const _slate800 = Color(0xFF1E293B);
const _bgDark = Color(0xFF0B1020);

class ReceivedProposalsView extends StatefulWidget {
  const ReceivedProposalsView({super.key});

  @override
  State<ReceivedProposalsView> createState() => _ReceivedProposalsViewState();
}

class _ReceivedProposalsViewState extends State<ReceivedProposalsView> {
  Stream<List<Proposal>>? _stream;
  String? _loadError;
  // ID da proposta atualmente sendo aceita/rejeitada — exibe spinner localizado.
  String? _processingId;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  Future<void> _initStream() async {
    if (Firebase.apps.isEmpty) {
      setState(() => _stream = Stream<List<Proposal>>.value(const []));
      return;
    }
    try {
      final user = await AuthService.instance.currentAppUser();
      if (!mounted) return;
      if (user == null) {
        setState(() => _loadError = 'Sessão expirada. Faça login novamente.');
        return;
      }
      setState(() =>
          _stream = ProposalsService.instance.streamProposalsByClient(user.uid));
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = 'Falha ao carregar propostas: $e');
    }
  }

  Future<void> _handleAccept(Proposal p) async {
    if (_processingId != null) return;
    setState(() => _processingId = p.id);
    try {
      await ProposalsService.instance.acceptProposal(p.id);
      if (!mounted) return;
      _showSnack(
        'Proposta aceita! Contrato criado com ${p.freelancerName}.',
        success: true,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack(_humanizeError(e, 'aceitar'), success: false);
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  Future<void> _handleReject(Proposal p) async {
    if (_processingId != null) return;
    setState(() => _processingId = p.id);
    try {
      await ProposalsService.instance.rejectProposal(p.id);
      if (!mounted) return;
      _showSnack('Proposta rejeitada.', success: true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(_humanizeError(e, 'rejeitar'), success: false);
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
          return 'Você não tem permissão para $action esta proposta.';
        case 'failed-precondition':
          return 'Proposta não está mais pendente.';
        case 'not-found':
          return 'Proposta não encontrada.';
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _bgDark : _surfaceCream;
    final titleColor = isDark ? Colors.white : _slate900;
    final mutedColor = isDark ? Colors.white70 : _slate500;

    return Container(
      color: bg,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Header(titleColor: titleColor, mutedColor: mutedColor),
          ),
          if (_loadError != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _StateMessage(
                icon: Icons.error_outline,
                title: 'Erro',
                message: _loadError!,
                titleColor: titleColor,
                mutedColor: mutedColor,
              ),
            )
          else if (_stream == null)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator(color: _primary)),
            )
          else
            StreamBuilder<List<Proposal>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(color: _primary),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _StateMessage(
                      icon: Icons.error_outline,
                      title: 'Erro',
                      message: '${snapshot.error}',
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                    ),
                  );
                }
                final proposals = snapshot.data ?? const <Proposal>[];
                if (proposals.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _StateMessage(
                      icon: Icons.inbox_outlined,
                      title: 'Nenhuma proposta recebida',
                      message:
                          'Quando freelancers enviarem propostas para seus '
                          'projetos, elas aparecem aqui.',
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                    ),
                  );
                }
                final groups = _groupByProject(proposals);
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: groups.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 20),
                    itemBuilder: (_, i) => _ProjectGroup(
                      group: groups[i],
                      isDark: isDark,
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                      processingId: _processingId,
                      onAccept: _handleAccept,
                      onReject: _handleReject,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  static List<_ProposalGroup> _groupByProject(List<Proposal> proposals) {
    final byId = <String, List<Proposal>>{};
    final titleById = <String, String>{};
    final firstSeenAt = <String, DateTime>{};
    for (final p in proposals) {
      byId.putIfAbsent(p.projectId, () => []).add(p);
      titleById[p.projectId] = p.projectTitle;
      // proposals chegam ordenadas por createdAt desc; o primeiro visto é o mais recente.
      firstSeenAt.putIfAbsent(p.projectId, () => p.createdAt);
    }
    final entries = byId.entries.toList()
      // ordenar grupos pelo projeto com proposta mais recente no topo.
      ..sort((a, b) => firstSeenAt[b.key]!.compareTo(firstSeenAt[a.key]!));
    return entries
        .map((e) => _ProposalGroup(
              projectId: e.key,
              projectTitle: titleById[e.key]!,
              proposals: e.value,
            ))
        .toList();
  }
}

class _ProposalGroup {
  const _ProposalGroup({
    required this.projectId,
    required this.projectTitle,
    required this.proposals,
  });
  final String projectId;
  final String projectTitle;
  final List<Proposal> proposals;
}

class _Header extends StatelessWidget {
  const _Header({required this.titleColor, required this.mutedColor});

  final Color titleColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Projetos',
            style: GoogleFonts.dmSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Propostas recebidas, agrupadas pelo projeto correspondente.',
            style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
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

class _ProjectGroup extends StatelessWidget {
  const _ProjectGroup({
    required this.group,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.processingId,
    required this.onAccept,
    required this.onReject,
  });

  final _ProposalGroup group;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final String? processingId;
  final ValueChanged<Proposal> onAccept;
  final ValueChanged<Proposal> onReject;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  group.projectTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  group.proposals.length == 1
                      ? '1 proposta'
                      : '${group.proposals.length} propostas',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < group.proposals.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _ProposalCard(
            proposal: group.proposals[i],
            isDark: isDark,
            titleColor: titleColor,
            mutedColor: mutedColor,
            isProcessing: processingId == group.proposals[i].id,
            actionsDisabled:
                processingId != null && processingId != group.proposals[i].id,
            onAccept: () => onAccept(group.proposals[i]),
            onReject: () => onReject(group.proposals[i]),
          ),
        ],
      ],
    );
  }
}

class _ProposalCard extends StatelessWidget {
  const _ProposalCard({
    required this.proposal,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.isProcessing,
    required this.actionsDisabled,
    required this.onAccept,
    required this.onReject,
  });

  final Proposal proposal;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final bool isProcessing;
  final bool actionsDisabled;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? _slate800 : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : _primary.withValues(alpha: 0.10);
    final isPending = proposal.status == ProposalStatus.pending;

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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(proposal.freelancerName),
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  proposal.freelancerName.isEmpty
                      ? 'Freelancer'
                      : proposal.freelancerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: proposal.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MetaItem(
                icon: Icons.attach_money,
                label: _formatValue(proposal.value, proposal.isHourly),
                color: mutedColor,
              ),
              const SizedBox(width: 14),
              _MetaItem(
                icon: Icons.event_outlined,
                label: proposal.daysEstimate == 1
                    ? '1 dia'
                    : '${proposal.daysEstimate} dias',
                color: mutedColor,
              ),
            ],
          ),
          if (proposal.message.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              proposal.message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: titleColor,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            _relativeDate(proposal.createdAt),
            style: GoogleFonts.inter(
              fontSize: 11,
              color: mutedColor,
              letterSpacing: 0.2,
            ),
          ),
          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: (isProcessing || actionsDisabled)
                        ? null
                        : onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFBA1A1A),
                      side: const BorderSide(color: Color(0xFFBA1A1A)),
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
                              valueColor: AlwaysStoppedAnimation(
                                Color(0xFFBA1A1A),
                              ),
                            ),
                          )
                        : const Text('Rejeitar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: (isProcessing || actionsDisabled)
                        ? null
                        : onAccept,
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
                    child: isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text('Aceitar'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
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
      return d == 1 ? 'recebida há 1 dia' : 'recebida há $d dias';
    }
    if (diff.inHours >= 1) {
      final h = diff.inHours;
      return h == 1 ? 'recebida há 1 hora' : 'recebida há $h horas';
    }
    if (diff.inMinutes >= 1) {
      final m = diff.inMinutes;
      return m == 1 ? 'recebida há 1 minuto' : 'recebida há $m minutos';
    }
    return 'recebida agora';
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

  final ProposalStatus status;

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

  static _BadgeSpec _specFor(ProposalStatus s) {
    switch (s) {
      case ProposalStatus.pending:
        return const _BadgeSpec(
          label: 'Aguardando',
          bg: Color(0xFFFFF4DC),
          fg: Color(0xFF92571A),
        );
      case ProposalStatus.accepted:
        return const _BadgeSpec(
          label: 'Aceita',
          bg: Color(0xFFD8F5E9),
          fg: Color(0xFF086B53),
        );
      case ProposalStatus.rejected:
        return const _BadgeSpec(
          label: 'Recusada',
          bg: Color(0xFFFADBDB),
          fg: Color(0xFFBA1A1A),
        );
      case ProposalStatus.withdrawn:
        return const _BadgeSpec(
          label: 'Retirada',
          bg: Color(0xFFE2E8F0),
          fg: Color(0xFF334155),
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
