import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClientDashboardView extends StatelessWidget {
  const ClientDashboardView({super.key});

  static const _primary = Color(0xFF3B309E);
  static const _slate900 = Color(0xFF0F172A);
  static const _slate500 = Color(0xFF64748B);
  static const _slate800 = Color(0xFF1E293B);

  static const _metrics = <_Metric>[
    _Metric(
      label: 'Projetos ativos',
      value: '12',
      icon: Icons.trending_up,
      accent: Color(0xFF3B309E),
    ),
    _Metric(
      label: 'Aguardando revisão',
      value: '4',
      icon: Icons.hourglass_top_outlined,
      accent: Color(0xFFFFC107),
    ),
    _Metric(
      label: 'Total de propostas',
      value: '48',
      icon: Icons.people_outline,
      accent: Color(0xFF086B53),
    ),
  ];

  static const _active = <_ActiveProject>[
    _ActiveProject(
      title: 'Reformulação da plataforma de e-commerce',
      proposalCount: 14,
      badge: 'MAIS DISCUTIDO',
      hasHero: true,
    ),
    _ActiveProject(
      title: 'Dashboard de analytics em tempo real',
      proposalCount: 8,
      badge: null,
      hasHero: true,
    ),
  ];

  static const _pending = <_PendingProject>[
    _PendingProject(
      title: 'Kit de UI para app mobile',
      badge: 'AGUARDANDO REVISÃO',
    ),
    _PendingProject(
      title: 'Auditoria e estratégia de SEO',
      badge: 'AGUARDANDO REVISÃO',
    ),
  ];

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
            itemCount: _metrics.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _MetricCard(
              metric: _metrics[i],
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Tela de criar projeto virá numa próxima iteração.',
                      ),
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
            actionLabel: 'Ver tudo',
            titleColor: titleColor,
            actionColor: _primary,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: _active.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _ActiveProjectCard(
              project: _active[i],
              cardBg: cardBg,
              borderColor: borderColor,
              titleColor: titleColor,
              mutedColor: mutedColor,
              isDark: isDark,
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
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: _pending.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _PendingProjectCard(
              project: _pending[i],
              cardBg: cardBg,
              borderColor: borderColor,
              titleColor: titleColor,
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
                    fontWeight: FontWeight.w600,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  metric.value,
                  style: GoogleFonts.dmSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
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
              color: metric.accent.withValues(alpha: 0.12),
            ),
            child: Icon(metric.icon, size: 22, color: metric.accent),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 4,
                ),
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

class _ActiveProject {
  const _ActiveProject({
    required this.title,
    required this.proposalCount,
    required this.badge,
    required this.hasHero,
  });

  final String title;
  final int proposalCount;
  final String? badge;
  final bool hasHero;
}

class _ActiveProjectCard extends StatelessWidget {
  const _ActiveProjectCard({
    required this.project,
    required this.cardBg,
    required this.borderColor,
    required this.titleColor,
    required this.mutedColor,
    required this.isDark,
  });

  final _ActiveProject project;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;
  final Color mutedColor;
  final bool isDark;

  static const _primary = Color(0xFF3B309E);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (project.hasHero) const _HeroPlaceholder(),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (project.badge != null) ...[
                  _Badge(label: project.badge!, isDark: isDark),
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
                          '${project.proposalCount} propostas',
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
    );
  }
}

class _PendingProject {
  const _PendingProject({required this.title, required this.badge});

  final String title;
  final String badge;
}

class _PendingProjectCard extends StatelessWidget {
  const _PendingProjectCard({
    required this.project,
    required this.cardBg,
    required this.borderColor,
    required this.titleColor,
  });

  final _PendingProject project;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;

  static const _primary = Color(0xFF3B309E);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Badge(label: project.badge, isDark: Theme.of(context).brightness == Brightness.dark),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  project.title,
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
                  const Icon(Icons.arrow_forward, size: 14, color: _primary),
                ],
              ),
            ],
          ),
        ],
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
