import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/project.dart';

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
  String _activeFilter = 'Todos os filtros';
  final Set<String> _bookmarked = <String>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: 'Todos os filtros',
                    icon: Icons.tune,
                    active: _activeFilter == 'Todos os filtros',
                    onTap: () =>
                        setState(() => _activeFilter = 'Todos os filtros'),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Categoria',
                    icon: Icons.expand_more,
                    iconTrailing: true,
                    active: _activeFilter == 'Categoria',
                    onTap: () => setState(() => _activeFilter = 'Categoria'),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Orçamento',
                    icon: Icons.expand_more,
                    iconTrailing: true,
                    active: _activeFilter == 'Orçamento',
                    onTap: () => setState(() => _activeFilter = 'Orçamento'),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverList.separated(
            itemCount: mockProjects.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final project = mockProjects[i];
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
  });

  final TextEditingController controller;
  final Color bg;
  final Color hintColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: const Color(0xFF3B309E),
      style: GoogleFonts.inter(fontSize: 14, color: textColor),
      decoration: InputDecoration(
        filled: true,
        fillColor: bg,
        hintText: 'Buscar projetos, habilidades…',
        hintStyle: GoogleFonts.inter(fontSize: 14, color: hintColor),
        prefixIcon: Icon(Icons.search, color: hintColor, size: 20),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    required this.isDark,
    this.iconTrailing = false,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final bool isDark;
  final bool iconTrailing;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF3B309E);
    final bg = active
        ? primary
        : (isDark ? const Color(0xFF1E293B) : Colors.white);
    final textColor = active
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF334155));
    final iconColor = active
        ? Colors.white
        : (isDark ? Colors.white70 : const Color(0xFF64748B));
    final borderColor = active
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
            if (!iconTrailing) ...[
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (iconTrailing) ...[
              const SizedBox(width: 6),
              Icon(icon, size: 18, color: iconColor),
            ],
          ],
        ),
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
      onTap: () {},
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
