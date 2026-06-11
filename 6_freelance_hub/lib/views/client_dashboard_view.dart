import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/services/auth_service.dart';
import '../core/services/contracts_service.dart';
import '../core/services/projects_service.dart';
import '../core/services/proposals_service.dart';
import '../models/contract.dart';
import '../models/project.dart';
import '../models/proposal.dart';
import 'create_project_view.dart';
import 'my_contracts_view.dart';
import 'project_detail_view.dart';

class ClientDashboardView extends StatefulWidget {
  const ClientDashboardView({super.key});

  @override
  State<ClientDashboardView> createState() => _ClientDashboardViewState();
}

class _ClientDashboardViewState extends State<ClientDashboardView> {
  static const _primary = Color(0xFF3B309E);
  static const _slate900 = Color(0xFF0F172A);
  static const _slate500 = Color(0xFF64748B);
  static const _slate800 = Color(0xFF1E293B);

  StreamSubscription<List<Project>>? _projectsSub;
  StreamSubscription<List<Contract>>? _contractsSub;
  StreamSubscription<List<Proposal>>? _proposalsSub;

  List<Project> _projects = const [];
  List<Contract> _contracts = const [];
  List<Proposal> _proposals = const [];

  @override
  void initState() {
    super.initState();
    _initStreams();
  }

  @override
  void dispose() {
    _projectsSub?.cancel();
    _contractsSub?.cancel();
    _proposalsSub?.cancel();
    super.dispose();
  }

  Future<void> _initStreams() async {
    if (Firebase.apps.isEmpty) return;
    final user = await AuthService.instance.currentAppUser();
    if (user == null || !mounted) return;

    _projectsSub = ProjectsService.instance
        .streamMyProjects(user.uid)
        .listen((list) => mounted ? setState(() => _projects = list) : null);

    _contractsSub = ContractsService.instance
        .streamContractsByClient(user.uid)
        .listen((list) => mounted ? setState(() => _contracts = list) : null);

    _proposalsSub = ProposalsService.instance
        .streamProposalsByClient(user.uid)
        .listen((list) => mounted ? setState(() => _proposals = list) : null);
  }

  // Projetos "em movimento" — engloba open (esperando proposta) e active
  // (proposta aceita, contrato rolando). Exclui completed/closed.
  List<Project> get _activeProjects => _projects
      .where((p) =>
          p.status == ProjectStatus.open || p.status == ProjectStatus.active)
      .toList();

  // Contratos com entrega aguardando aprovação do cliente.
  List<Contract> get _pendingReviewContracts => _contracts
      .where((c) => c.status == ContractStatus.delivered)
      .toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : _slate900;
    final mutedColor = isDark ? Colors.white70 : _slate500;
    final cardBg = isDark ? _slate800 : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : _primary.withValues(alpha: 0.10);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : _primary.withValues(alpha: 0.10);

    final metrics = <_Metric>[
      _Metric(
        label: 'Projetos ativos',
        value: _activeProjects.length.toString(),
        icon: Icons.trending_up,
        accent: _primary,
      ),
      _Metric(
        label: 'Aguardando revisão',
        value: _pendingReviewContracts.length.toString(),
        icon: Icons.hourglass_top_outlined,
        accent: const Color(0xFFFFC107),
      ),
      _Metric(
        label: 'Total de propostas',
        value: _proposals.length.toString(),
        icon: Icons.people_outline,
        accent: const Color(0xFF086B53),
      ),
    ];

    final topActive = _activeProjects.take(3).toList();
    final topPending = _pendingReviewContracts.take(3).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _TopHeader(
            titleColor: titleColor,
            dividerColor: dividerColor,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverList.separated(
            itemCount: metrics.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _MetricCard(
              metric: metrics[i],
              cardBg: cardBg,
              borderColor: borderColor,
              titleColor: titleColor,
              mutedColor: mutedColor,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          sliver: SliverToBoxAdapter(
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CreateProjectView(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Publicar Novo Projeto'),
                style: FilledButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: 'Projetos ativos',
            actionLabel: null,
            titleColor: titleColor,
            actionColor: _primary,
          ),
        ),
        if (topActive.isEmpty)
          SliverToBoxAdapter(
            child: _SectionEmpty(
              icon: Icons.dashboard_outlined,
              message: 'Nenhum projeto em movimento ainda.\n'
                  'Publique um pra começar a receber propostas.',
              titleColor: titleColor,
              mutedColor: mutedColor,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.separated(
              itemCount: topActive.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _ActiveProjectCard(
                project: topActive[i],
                cardBg: cardBg,
                borderColor: borderColor,
                titleColor: titleColor,
                mutedColor: mutedColor,
                isDark: isDark,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProjectDetailView(project: topActive[i]),
                  ),
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: 'Aguardando aprovação',
            actionLabel: null,
            titleColor: titleColor,
            actionColor: _primary,
          ),
        ),
        if (topPending.isEmpty)
          SliverToBoxAdapter(
            child: _SectionEmpty(
              icon: Icons.task_alt,
              message: 'Nada pra revisar agora.',
              titleColor: titleColor,
              mutedColor: mutedColor,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.separated(
              itemCount: topPending.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _PendingReviewCard(
                contract: topPending[i],
                cardBg: cardBg,
                borderColor: borderColor,
                titleColor: titleColor,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyContractsView(),
                  ),
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({required this.titleColor, required this.dividerColor});

  final Color titleColor;
  final Color dividerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Painel',
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: titleColor,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF3B309E).withValues(alpha: 0.18),
              border: Border.all(
                color: const Color(0xFF3B309E),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFF3B309E),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric {
  const _Metric({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.metric,
    required this.cardBg,
    required this.borderColor,
    required this.titleColor,
    required this.mutedColor,
  });

  final _Metric metric;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: mutedColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metric.value,
                  style: GoogleFonts.dmSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: titleColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: metric.accent.withValues(alpha: 0.15),
            ),
            child: Icon(metric.icon, color: metric.accent, size: 22),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.titleColor,
    required this.actionColor,
  });

  final String title;
  final String? actionLabel;
  final Color titleColor;
  final Color actionColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: titleColor,
              ),
            ),
          ),
          if (actionLabel != null)
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: actionColor,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_forward, size: 14, color: actionColor),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionEmpty extends StatelessWidget {
  const _SectionEmpty({
    required this.icon,
    required this.message,
    required this.titleColor,
    required this.mutedColor,
  });

  final IconData icon;
  final String message;
  final Color titleColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        decoration: BoxDecoration(
          color: mutedColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: mutedColor.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 26, color: mutedColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: mutedColor,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveProjectCard extends StatelessWidget {
  const _ActiveProjectCard({
    required this.project,
    required this.cardBg,
    required this.borderColor,
    required this.titleColor,
    required this.mutedColor,
    required this.isDark,
    required this.onTap,
  });

  final Project project;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;
  final Color mutedColor;
  final bool isDark;
  final VoidCallback onTap;

  static const _primary = Color(0xFF3B309E);

  String? _badgeFor(Project p) {
    if (p.status == ProjectStatus.active) return 'EM ANDAMENTO';
    if (p.proposalCount >= 5) return 'MAIS DISCUTIDO';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final badge = _badgeFor(project);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeroPlaceholder(),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (badge != null) ...[
                    _Badge(label: badge, isDark: isDark),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    project.title,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 14,
                            color: mutedColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            project.proposalCount == 1
                                ? '1 proposta'
                                : '${project.proposalCount} propostas',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: mutedColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ver projeto',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _primary,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: _primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingReviewCard extends StatelessWidget {
  const _PendingReviewCard({
    required this.contract,
    required this.cardBg,
    required this.borderColor,
    required this.titleColor,
    required this.onTap,
  });

  final Contract contract;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;
  final VoidCallback onTap;

  static const _primary = Color(0xFF3B309E);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Badge(
              label: 'AGUARDANDO REVISÃO',
              isDark: Theme.of(context).brightness == Brightness.dark,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    contract.projectTitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Revisar agora',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: _primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFFFFC107).withValues(alpha: 0.18)
            : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: const Color(0xFF8A6D00),
        ),
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B154A), Color(0xFF534AB7)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          const Center(
            child: Icon(
              Icons.dashboard_outlined,
              size: 44,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
