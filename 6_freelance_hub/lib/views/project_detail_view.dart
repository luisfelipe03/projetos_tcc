import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/project.dart';

class ProjectDetailView extends StatefulWidget {
  const ProjectDetailView({super.key, required this.project});

  final Project project;

  @override
  State<ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends State<ProjectDetailView> {
  static const _primary = Color(0xFF3B309E);
  static const _surfaceCream = Color(0xFFFBF9F2);
  static const _slate900 = Color(0xFF0F172A);
  static const _slate500 = Color(0xFF64748B);
  static const _slate200 = Color(0xFFE2E8F0);
  static const _slate800 = Color(0xFF1E293B);
  static const _bgDark = Color(0xFF0B1020);

  bool _bookmarked = false;

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
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : _slate200;

    final project = widget.project;

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
              _TopBar(
                titleColor: titleColor,
                bookmarked: _bookmarked,
                onBookmark: () => setState(() => _bookmarked = !_bookmarked),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (project.hasHeroImage) const _HeroImage(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.title,
                              style: GoogleFonts.dmSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                height: 1.2,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: project.skills
                                  .map((s) => _SkillChip(label: s, isDark: isDark))
                                  .toList(),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              project.formattedBudget(),
                              style: GoogleFonts.dmSans(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: _primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              project.budgetTypeLabel(),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: mutedColor,
                              ),
                            ),
                            const SizedBox(height: 14),
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
                                    fontWeight: FontWeight.w600,
                                    color: mutedColor,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    '•',
                                    style: TextStyle(color: mutedColor),
                                  ),
                                ),
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: mutedColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  project.relativePostedLabel(),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: mutedColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: dividerColor),
                      _Section(
                        title: 'Sobre o projeto',
                        titleColor: titleColor,
                        child: Text(
                          project.description,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            height: 1.6,
                            color: mutedColor,
                          ),
                        ),
                      ),
                      Divider(height: 1, color: dividerColor),
                      _Section(
                        title: 'Cliente',
                        titleColor: titleColor,
                        child: _ClientCard(
                          name: project.clientName,
                          rating: project.clientRating,
                          projectsCount: project.clientProjectsCount,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          titleColor: titleColor,
                          mutedColor: mutedColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              _BottomActionBar(
                navBg: cardBg,
                borderColor: borderColor,
                onSendProposal: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Tela de envio de proposta virá na próxima iteração.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.titleColor,
    required this.bookmarked,
    required this.onBookmark,
  });

  final Color titleColor;
  final bool bookmarked;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: Icon(Icons.arrow_back, color: titleColor),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Detalhes do projeto',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: titleColor,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onBookmark,
            icon: Icon(
              bookmarked ? Icons.bookmark : Icons.bookmark_outline,
              color: bookmarked ? const Color(0xFF3B309E) : titleColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
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
            right: -40,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          const Center(
            child: Icon(Icons.dns_outlined, size: 56, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.titleColor,
    required this.child,
  });

  final String title;
  final Color titleColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: titleColor,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({
    required this.name,
    required this.rating,
    required this.projectsCount,
    required this.cardBg,
    required this.borderColor,
    required this.titleColor,
    required this.mutedColor,
  });

  final String name;
  final double rating;
  final int projectsCount;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;
  final Color mutedColor;

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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primary.withValues(alpha: 0.18),
              border: Border.all(color: _primary, width: 2),
            ),
            child: const Icon(Icons.person, color: _primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFC107), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '•',
                        style: TextStyle(color: mutedColor, fontSize: 12),
                      ),
                    ),
                    Text(
                      '$projectsCount projetos publicados',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: mutedColor,
                      ),
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

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.navBg,
    required this.borderColor,
    required this.onSendProposal,
  });

  final Color navBg;
  final Color borderColor;
  final VoidCallback onSendProposal;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(top: BorderSide(color: borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: onSendProposal,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF3B309E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Enviar proposta'),
            ),
          ),
        ),
      ),
    );
  }
}
