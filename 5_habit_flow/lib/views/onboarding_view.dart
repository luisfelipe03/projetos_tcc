import 'package:flutter/material.dart';
import 'package:habit_flow/views/auth/login_view.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A1625), Color(0xFF0F0D15)],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF8F9FA), Color(0xFFFFFFFF)],
                ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          SizedBox(height: constraints.maxHeight * 0.05),

                          // Imagem com badges flutuantes
                          _buildHeroImage(isDarkMode, constraints),

                          const Spacer(flex: 2),

                          // Título
                          _buildTitle(isDarkMode),

                          const SizedBox(height: 16),

                          // Descrição
                          _buildDescription(isDarkMode),

                          const Spacer(flex: 3),

                          // Botão Get Started
                          _buildGetStartedButton(context),

                          const SizedBox(height: 20),

                          // Link "I already have an account"
                          _buildLoginLink(context, isDarkMode),

                          const Spacer(flex: 2),

                          // Indicadores de página
                          _buildPageIndicators(),

                          const SizedBox(height: 20),

                          // Rodapé
                          _buildFooter(isDarkMode),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage(bool isDarkMode, BoxConstraints constraints) {
    final imageHeight = constraints.maxHeight * 0.35;
    final imageWidth = constraints.maxWidth * 0.85;

    return SizedBox(
      height: imageHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Imagem principal
          Center(
            child: Container(
              width: imageWidth,
              height: imageHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.asset(
                  'assets/imgs/grafico_plantas.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Badge "Study" (esquerda)
          Positioned(
            left: 0,
            top: imageHeight * 0.45,
            child: _buildBadge(
              icon: Icons.menu_book_rounded,
              label: 'Study',
              iconColor: const Color(0xFF5B8DEF),
              isDarkMode: isDarkMode,
            ),
          ),

          // Badge "Health" (direita)
          Positioned(
            right: 0,
            top: imageHeight * 0.15,
            child: _buildBadge(
              icon: Icons.fitness_center,
              label: 'Health',
              iconColor: const Color(0xFF4ADE80),
              isDarkMode: isDarkMode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color iconColor,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2D3E5F).withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode
              ? const Color(0xFF3D4E6F).withOpacity(0.5)
              : Colors.white.withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(bool isDarkMode) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.w800,
          height: 1.15,
          letterSpacing: -1,
        ),
        children: [
          TextSpan(
            text: 'Master Your\n',
            style: TextStyle(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.95)
                  : const Color(0xFF1F2937),
            ),
          ),
          const TextSpan(
            text: 'Routine.',
            style: TextStyle(color: Color(0xFF8B5CF6)),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        'Build lasting habits and track your progress with our vibrant student-focused platform.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          color: isDarkMode ? const Color(0xFFA1A8B3) : const Color(0xFF6B7280),
          height: 1.6,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9B6FFF), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(_createSlideUpRoute(initialTab: 1));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context, bool isDarkMode) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(_createSlideUpRoute(initialTab: 0));
      },
      style: TextButton.styleFrom(
        foregroundColor: isDarkMode ? Colors.white : const Color(0xFF1F2937),
      ),
      child: const Text(
        'I already have an account',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 6,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9B6FFF), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFF4B5563).withOpacity(0.4),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFF4B5563).withOpacity(0.4),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isDarkMode) {
    return Text(
      'JOIN 10K+ STUDENTS TODAY',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: isDarkMode ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
      ),
    );
  }

  Route _createSlideUpRoute({int initialTab = 1}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          LoginView(initialTab: initialTab),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.fastOutSlowIn;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
          ),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}
