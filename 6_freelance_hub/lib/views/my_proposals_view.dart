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

class MyProposalsView extends StatefulWidget {
  const MyProposalsView({super.key});

  @override
  State<MyProposalsView> createState() => _MyProposalsViewState();
}

class _MyProposalsViewState extends State<MyProposalsView> {

  Stream<List<Proposal>>? _stream;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  Future<void> _initStream() async {
    // Em testes sem Firebase.initializeApp, cai pra stream vazia.
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
          _stream = ProposalsService.instance.streamProposalsByFreelancer(user.uid));
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = 'Falha ao carregar propostas: $e');
    }
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
              child: _ErrorState(message: _loadError!, color: mutedColor),
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
                    child: _ErrorState(
                      message: 'Erro ao carregar: ${snapshot.error}',
                      color: mutedColor,
                    ),
                  );
                }
                final proposals = snapshot.data ?? const <Proposal>[];
                if (proposals.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: proposals.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _ProposalCard(
                      proposal: proposals[i],
                      isDark: isDark,
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
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
            'Meus Trabalhos',
            style: GoogleFonts.dmSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Propostas que você enviou e o status atual de cada uma.',
            style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.titleColor, required this.mutedColor});

  final Color titleColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: mutedColor),
          const SizedBox(height: 14),
          Text(
            'Nenhuma proposta ainda',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Vá ao Feed, abra um projeto e envie sua primeira proposta.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: color),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: color),
          ),
        ],
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  const _ProposalCard({
    required this.proposal,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
  });

  final Proposal proposal;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? _slate800 : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : _primary.withValues(alpha: 0.10);

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
                  proposal.projectTitle,
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
                label: _formatDays(proposal.daysEstimate),
                color: mutedColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _relativeDate(proposal.createdAt),
            style: GoogleFonts.inter(
              fontSize: 11,
              color: mutedColor,
              letterSpacing: 0.2,
            ),
          ),
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

  static String _formatDays(int days) =>
      days == 1 ? '1 dia' : '$days dias';

  static String _relativeDate(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays >= 1) {
      final d = diff.inDays;
      return d == 1 ? 'enviada há 1 dia' : 'enviada há $d dias';
    }
    if (diff.inHours >= 1) {
      final h = diff.inHours;
      return h == 1 ? 'enviada há 1 hora' : 'enviada há $h horas';
    }
    if (diff.inMinutes >= 1) {
      final m = diff.inMinutes;
      return m == 1 ? 'enviada há 1 minuto' : 'enviada há $m minutos';
    }
    return 'enviada agora';
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
