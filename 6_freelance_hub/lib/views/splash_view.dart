import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'onboarding_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  static const _bgLight = Color(0xFF534AB7);
  static const _bgDark = Color(0xFF26215C);
  static const _splashDuration = Duration(seconds: 3);

  late final AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    Future.delayed(_splashDuration, _goToNext);
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _bgDark : _bgLight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 64,
                      height: 64,
                      child: CustomPaint(painter: _BrandLogoPainter()),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'FreelanceHub',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Conecte. Crie. Cresça.',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 80,
                child: Column(
                  children: [
                    Text(
                      'V1.0.0',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 11,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _LoadingBar(controller: _loadingController),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: Center(
                  child: Container(
                    width: 128,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1),
        child: Stack(
          children: [
            Container(color: Colors.white.withValues(alpha: 0.2)),
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return FractionallySizedBox(
                  widthFactor: controller.value,
                  child: Container(color: Colors.white.withValues(alpha: 0.85)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandLogoPainter extends CustomPainter {
  const _BrandLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = Colors.white;
    canvas.drawCircle(const Offset(28, 18), 8, paint);

    paint.color = Colors.white.withValues(alpha: 0.9);
    final leftBody = Path()
      ..moveTo(20, 30)
      ..cubicTo(20, 30, 12, 32, 12, 40)
      ..lineTo(12, 56)
      ..lineTo(28, 56)
      ..lineTo(28, 30)
      ..close();
    canvas.drawPath(leftBody, paint);

    paint.color = Colors.white;
    canvas.drawCircle(const Offset(44, 24), 6, paint);

    paint.color = Colors.white.withValues(alpha: 0.7);
    final rightBody = Path()
      ..moveTo(36, 34)
      ..cubicTo(36, 34, 52, 34, 52, 44)
      ..lineTo(52, 56)
      ..lineTo(36, 56)
      ..close();
    canvas.drawPath(rightBody, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
