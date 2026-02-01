import 'package:flutter/material.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF1A1625)
          : const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Imagem com badges flutuantes
              _buildHeroImage(),

              const Spacer(),

              // Título
              _buildTitle(),

              const SizedBox(height: 20),

              // Descrição
              _buildDescription(isDarkMode),

              const SizedBox(height: 48),

              // Botão Get Started
              _buildGetStartedButton(context),

              const SizedBox(height: 24),

              // Link "I already have an account"
              _buildLoginLink(context, isDarkMode),

              const SizedBox(height: 32),

              // Indicadores de página
              _buildPageIndicators(),

              const SizedBox(height: 24),

              // Rodapé
              _buildFooter(isDarkMode),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          // Imagem principal
          Center(
            child: Container(
              width: 320,
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
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
            top: 120,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2D3E5F).withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF3D4E6F), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F7FFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Study',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Badge "Health" (direita)
          Positioned(
            right: 0,
            top: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
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
                      color: const Color(0xFF4ADE80),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Health',
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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

  Widget _buildTitle() {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        style: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          height: 1.1,
          letterSpacing: -0.5,
        ),
        children: [
          TextSpan(
            text: 'Master Your\n',
            style: TextStyle(color: Colors.white),
          ),
          TextSpan(
            text: 'Routine.',
            style: TextStyle(color: Color(0xFF8B5CF6)),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(bool isDarkMode) {
    return Text(
      'Build lasting habits and track your progress with our vibrant student-focused platform.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Navegar para próxima tela
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context, bool isDarkMode) {
    return TextButton(
      onPressed: () {
        // TODO: Navegar para tela de login
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
          width: 32,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF4B5563),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF4B5563),
            borderRadius: BorderRadius.circular(4),
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
}
