import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/services/projects_service.dart';
import '../models/project.dart';
import '../widgets/feed_filters_sheet.dart';
import 'project_detail_view.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  static const _primary = Color(0xFF3B309E);
  static const _surfaceCream = Color(0xFFFBF9F2);
  static const _slate900 = Color(0xFF0F172A);
  static const _slate500 = Color(0xFF64748B);
  static const _slate400 = Color(0xFF94A3B8);
  static const _slate800 = Color(0xFF1E293B);

  final _searchController = TextEditingController();
  ProjectFilters _filters = const ProjectFilters();
  final Set<String> _bookmarked = <String>{};
  late final Stream<List<Project>> _projectsStream;

  @override
  void initState() {
    super.initState();
    // Guard pra ambiente de teste sem Firebase.initializeApp: cai pra mock.
    _projectsStream = Firebase.apps.isNotEmpty
        ? ProjectsService.instance.streamOpenProjects()
        : Stream<List<Project>>.value(mockProjects);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final q = _searchController.text;
    if (q == _filters.searchQuery) return;
    setState(() => _filters = _filters.copyWith(searchQuery: q));
  }

  Future<void> _openFiltersSheet() async {
    final result = await showModalBottomSheet<ProjectFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FeedFiltersSheet(initial: _filters),
    );
    if (!mounted || result == null) return;
    setState(() => _filters = result);
  }

  void _clearSearch() {
    _searchController.clear();
    // Listener já chama setState pelo _onSearchChanged.
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<Widget> _buildFilterChips(bool isDark) {
    final chips = <Widget>[
      _FiltersButton(
        activeCount: _filters.activeCount,
        onTap: _openFiltersSheet,
        isDark: isDark,
      ),
    ];
    for (final c in _filters.categories) {
      chips
        ..add(const SizedBox(width: 8))
        ..add(_ActiveChip(
          label: c,
          onRemove: () =>
              setState(() => _filters = _filters.removeCategory(c)),
          isDark: isDark,
        ));
    }
    for (final r in _filters.budgetRanges) {
      chips
        ..add(const SizedBox(width: 8))
        ..add(_ActiveChip(
          label: r.label,
          onRemove: () =>
              setState(() => _filters = _filters.removeBudgetRange(r)),
          isDark: isDark,
        ));
    }
    if (_filters.budgetType != BudgetTypeFilter.any) {
      chips
        ..add(const SizedBox(width: 8))
        ..add(_ActiveChip(
          label: _filters.budgetType == BudgetTypeFilter.fixed
              ? 'Preço fixo'
              : 'Por hora',
          onRemove: () => setState(() =>
              _filters = _filters.copyWith(budgetType: BudgetTypeFilter.any)),
          isDark: isDark,
        ));
    }
    return chips;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1020) : _surfaceCream;
    final cardBg = isDark ? _slate800 : Colors.white;
    final titleColor = isDark ? Colors.white : _slate900;
    final mutedColor = isDark ? Colors.white70 : _slate500;
    final inputBg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : _primary.withValues(alpha: 0.05);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : _primary.withValues(alpha: 0.10);

    return Container(
      color: bg,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _TopHeader(
              titleColor: titleColor,
              isDark: isDark,
              dividerColor: dividerColor,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: _SearchBar(
                controller: _searchController,
                bg: inputBg,
                hintColor: _slate400,
                textColor: titleColor,
                onClear: _searchController.text.isEmpty ? null : _clearSearch,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _buildFilterChips(isDark),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          StreamBuilder<List<Project>>(
            stream: _projectsStream,
            builder: (context, snap) {
              if (snap.hasError) {
                return SliverToBoxAdapter(
                  child: _StateMessage(
                    icon: Icons.error_outline,
                    title: 'Não foi possível carregar os projetos',
                    subtitle: '${snap.error}',
                    color: mutedColor,
                    titleColor: titleColor,
                  ),
                );
              }
              if (snap.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF3B309E),
                      ),
                    ),
                  ),
                );
              }
              final allProjects = snap.data ?? const <Project>[];
              if (allProjects.isEmpty) {
                return SliverToBoxAdapter(
                  child: _StateMessage(
                    icon: Icons.inbox_outlined,
                    title: 'Nenhum projeto disponível',
                    subtitle:
                        'Os projetos publicados pelos clientes aparecerão aqui.',
                    color: mutedColor,
                    titleColor: titleColor,
                  ),
                );
              }
              final projects = _filters.isEmpty
                  ? allProjects
                  : allProjects.where((p) => p.matchesFilters(_filters)).toList();
              if (projects.isEmpty) {
                return SliverToBoxAdapter(
                  child: _StateMessage(
                    icon: Icons.search_off,
                    title: 'Nenhum projeto encontrado',
                    subtitle:
                        'Ajuste os filtros ou a busca para ver outros projetos.',
                    color: mutedColor,
                    titleColor: titleColor,
                  ),
                );
              }
              return SliverList.separated(
                itemCount: projects.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final project = projects[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _ProjectCard(
                      project: project,
                      bookmarked: _bookmarked.contains(project.id),
                      onBookmarkToggle: () => setState(() {
                        if (!_bookmarked.add(project.id)) {
                          _bookmarked.remove(project.id);
                        }
                      }),
                      cardBg: cardBg,
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                      isDark: isDark,
                    ),
                  );
                },
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.titleColor,
    required this.isDark,
    required this.dividerColor,
  });

  final Color titleColor;
  final bool isDark;
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
          _IconBubble(
            icon: Icons.menu,
            onTap: () {},
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Feed de Projetos',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: titleColor,
              ),
            ),
          ),
          _IconBubble(
            icon: Icons.notifications_outlined,
            badge: true,
            onTap: () {},
            isDark: isDark,
          ),
          const SizedBox(width: 8),
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

class _IconBubble extends StatelessWidget {
  const _IconBubble({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.badge = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF3B309E).withValues(alpha: 0.10),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: const Color(0xFF3B309E), size: 22),
            if (badge)
              Positioned(
                top: 8,
                right: 10,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4D4F),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF0B1020)
                          : const Color(0xFFFBF9F2),
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.bg,
    required this.hintColor,
    required this.textColor,
    this.onClear,
  });

  final TextEditingController controller;
  final Color bg;
  final Color hintColor;
  final Color textColor;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: const Color(0xFF3B309E),
      style: GoogleFonts.inter(fontSize: 14, color: textColor),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        filled: true,
        fillColor: bg,
        hintText: 'Buscar projetos, habilidades…',
        hintStyle: GoogleFonts.inter(fontSize: 14, color: hintColor),
        prefixIcon: Icon(Icons.search, color: hintColor, size: 20),
        suffixIcon: onClear == null
            ? null
            : IconButton(
                icon: Icon(Icons.close, color: hintColor, size: 18),
                onPressed: onClear,
                tooltip: 'Limpar busca',
              ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3B309E), width: 1.5),
        ),
      ),
    );
  }
}

/// Botão "Filtros" no topo do feed — abre o FeedFiltersSheet. Mostra badge
/// com a contagem de filtros ativos (sem contar a busca).
class _FiltersButton extends StatelessWidget {
  const _FiltersButton({
    required this.activeCount,
    required this.onTap,
    required this.isDark,
  });

  final int activeCount;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF3B309E);
    final hasActive = activeCount > 0;
    final bg = hasActive
        ? primary
        : (isDark ? const Color(0xFF1E293B) : Colors.white);
    final textColor = hasActive
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF334155));
    final iconColor = hasActive
        ? Colors.white
        : (isDark ? Colors.white70 : const Color(0xFF64748B));
    final borderColor = hasActive
        ? primary
        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(
              'Filtros',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            if (hasActive) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$activeCount',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Chip de um filtro ativo (categoria, faixa, tipo) — mostra o label + X
/// pra remover. Sempre roxo claro pra indicar "ativo".
class _ActiveChip extends StatelessWidget {
  const _ActiveChip({
    required this.label,
    required this.onRemove,
    required this.isDark,
  });

  final String label;
  final VoidCallback onRemove;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF3B309E);
    final bg = isDark
        ? primary.withValues(alpha: 0.30)
        : primary.withValues(alpha: 0.12);
    final textColor = isDark ? Colors.white : primary;

    return Container(
      padding: const EdgeInsets.only(left: 12, right: 4, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          InkResponse(
            onTap: onRemove,
            radius: 16,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close, size: 14, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.bookmarked,
    required this.onBookmarkToggle,
    required this.cardBg,
    required this.titleColor,
    required this.mutedColor,
    required this.isDark,
  });

  final Project project;
  final bool bookmarked;
  final VoidCallback onBookmarkToggle;
  final Color cardBg;
  final Color titleColor;
  final Color mutedColor;
  final bool isDark;

  static const _primary = Color(0xFF3B309E);

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : _primary.withValues(alpha: 0.10);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProjectDetailView(project: project),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project.hasHeroImage) const _HeroImagePlaceholder(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          project.title,
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                            height: 1.25,
                          ),
                        ),
                      ),
                      InkResponse(
                        onTap: onBookmarkToggle,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            bookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_outline,
                            color: bookmarked
                                ? _primary
                                : mutedColor.withValues(alpha: 0.7),
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: project.skills
                        .map((s) => _SkillChip(label: s, isDark: isDark))
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.formattedBudget(),
                              style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              project.budgetTypeLabel(),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: mutedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${project.proposalCount} propostas',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            project.relativePostedLabel(),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: mutedColor,
                            ),
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

class _HeroImagePlaceholder extends StatelessWidget {
  const _HeroImagePlaceholder();

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
              Icons.dns_outlined,
              size: 44,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF3B309E);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: isDark ? 0.20 : 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: primary,
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.titleColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
      child: Column(
        children: [
          Icon(icon, size: 44, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: color,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
