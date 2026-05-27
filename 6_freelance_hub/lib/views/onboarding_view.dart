import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  static const _primary = Color(0xFF3B309E);
  static const _primaryContainer = Color(0xFF534AB7);
  static const _surfaceLight = Color(0xFFFBF9F2);
  static const _onSurfaceLight = Color(0xFF1B1C18);
  static const _bgDark = Color(0xFF1A1A18);

  final _pageController = PageController();
  int _currentPage = 0;

  late final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      hero: const _HeroTalent(),
      title: 'Encontre o talento certo',
      description:
          'Publique seu projeto e receba propostas de freelancers qualificados em minutos.',
    ),
    _OnboardingPageData(
      hero: const _HeroSecurity(),
      title: 'Trabalhe com segurança',
      description:
          'Pagamento em escrow protege clientes e freelancers em cada projeto.',
    ),
    _OnboardingPageData(
      hero: const _HeroReputation(),
      title: 'Construa sua reputação',
      description:
          'Avaliações reais e portfólio verificado ajudam você a se destacar no mercado.',
    ),
  ];

  bool get _isLastPage => _currentPage == _pages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePrimary() {
    if (_isLastPage) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _bgDark : _surfaceLight;
    final onSurface = isDark ? Colors.white : _onSurfaceLight;
    final buttonColor = isDark ? _primaryContainer : _primary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: bg,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(onSkip: _finish, isDark: isDark),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, i) {
                    final page = _pages[i];
                    return _OnboardingPageBody(
                      hero: page.hero,
                      title: page.title,
                      description: page.description,
                      onSurfaceColor: onSurface,
                      isDark: isDark,
                    );
                  },
                ),
              ),
              _PageIndicator(
                count: _pages.length,
                current: _currentPage,
                activeColor: buttonColor,
                inactiveColor: onSurface.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: _PrimaryButton(
                  label: _isLastPage ? 'Começar' : 'Próximo',
                  showArrow: !_isLastPage,
                  color: buttonColor,
                  onPressed: _handlePrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.hero,
    required this.title,
    required this.description,
  });

  final Widget hero;
  final String title;
  final String description;
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSkip, required this.isDark});

  final VoidCallback onSkip;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language,
                  size: 18,
                  color: isDark ? Colors.white70 : const Color(0xFF3B309E),
                ),
                const SizedBox(width: 6),
                Text(
                  'PT',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: isDark ? Colors.white : const Color(0xFF1B1C18),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.white70 : Colors.black54,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: Text(
              'Pular',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageBody extends StatelessWidget {
  const _OnboardingPageBody({
    required this.hero,
    required this.title,
    required this.description,
    required this.onSurfaceColor,
    required this.isDark,
  });

  final Widget hero;
  final String title;
  final String description;
  final Color onSurfaceColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Center(child: hero),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: -0.5,
                    color: onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    height: 1.5,
                    color: onSurfaceColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.count,
    required this.current,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int count;
  final int current;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.showArrow,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final bool showArrow;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (showArrow) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Hero illustrations ────────────────────────────────────────────────────

class _HeroTalent extends StatelessWidget {
  const _HeroTalent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white;
    final shadow = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.08);

    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              color: const Color(0xFF3B309E).withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            left: 10,
            top: 60,
            child: _AvatarCard(
              cardColor: cardColor,
              shadow: shadow,
              avatarColor: const Color(0xFFE3DFFF),
              icon: Icons.person,
              isDark: isDark,
            ),
          ),
          Positioned(
            right: 10,
            top: 30,
            child: _AvatarCard(
              cardColor: cardColor,
              shadow: shadow,
              avatarColor: const Color(0xFF086B53),
              icon: Icons.person,
              isDark: isDark,
              elevated: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({
    required this.cardColor,
    required this.shadow,
    required this.avatarColor,
    required this.icon,
    required this.isDark,
    this.elevated = false,
  });

  final Color cardColor;
  final Color shadow;
  final Color avatarColor;
  final IconData icon;
  final bool isDark;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadow,
            blurRadius: elevated ? 24 : 12,
            offset: Offset(0, elevated ? 12 : 6),
          ),
        ],
        border: isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.08))
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: avatarColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: avatarColor, width: 2),
            ),
            child: Icon(icon, color: avatarColor, size: 22),
          ),
          const SizedBox(height: 10),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF3B309E).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 6,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF086B53).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSecurity extends StatelessWidget {
  const _HeroSecurity();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white;
    final chipShadow = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.08);

    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF086B53).withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
          ),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF086B53).withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFA0F3D4).withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFF086B53),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user,
              color: Colors.white,
              size: 36,
            ),
          ),
          Positioned(
            top: 30,
            right: 0,
            child: _Chip(
              label: 'ESCROW',
              icon: Icons.account_balance_wallet,
              bg: chipBg,
              shadow: chipShadow,
              isDark: isDark,
            ),
          ),
          Positioned(
            left: 0,
            bottom: 70,
            child: _Chip(
              label: 'CONTRATO',
              icon: Icons.description,
              bg: chipBg,
              shadow: chipShadow,
              isDark: isDark,
            ),
          ),
          Positioned(
            right: 30,
            bottom: 40,
            child: _Chip(
              label: 'AVALIAÇÃO',
              icon: Icons.star,
              bg: chipBg,
              shadow: chipShadow,
              isDark: isDark,
              iconColor: const Color(0xFFFFC107),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.bg,
    required this.shadow,
    required this.isDark,
    this.iconColor,
  });

  final String label;
  final IconData icon;
  final Color bg;
  final Color shadow;
  final bool isDark;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(color: shadow, blurRadius: 12, offset: const Offset(0, 4)),
        ],
        border: isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.08))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor ?? const Color(0xFF3B309E),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: isDark ? Colors.white : const Color(0xFF1B1C18),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroReputation extends StatelessWidget {
  const _HeroReputation();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white;
    final shadow = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.08);
    final mutedText = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.5);

    return Container(
      width: 240,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: shadow, blurRadius: 32, offset: const Offset(0, 16)),
        ],
        border: isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.08))
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE3DFFF),
              border: Border.all(
                color: const Color(0xFF3B309E).withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 44,
              color: Color(0xFF3B309E),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFA0F3D4),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified,
                  size: 12,
                  color: Color(0xFF086B53),
                ),
                const SizedBox(width: 4),
                Text(
                  'VERIFICADO',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: const Color(0xFF086B53),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (_) => const Icon(
                Icons.star,
                size: 16,
                color: Color(0xFFFFC107),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Taxa de conclusão',
                style: GoogleFonts.inter(fontSize: 10, color: mutedText),
              ),
              Text(
                '98%',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3B309E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: 0.98,
              minHeight: 6,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE3DFFF),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF3B309E)),
            ),
          ),
        ],
      ),
    );
  }
}
