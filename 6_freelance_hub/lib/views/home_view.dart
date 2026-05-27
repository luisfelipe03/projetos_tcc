import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'feed_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const _primary = Color(0xFF3B309E);
  static const _surfaceCream = Color(0xFFFBF9F2);
  static const _bgDark = Color(0xFF0B1020);

  int _currentTab = 0;

  static const _tabs = [
    _TabSpec(
      label: 'Feed',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    _TabSpec(
      label: 'Meus Trabalhos',
      icon: Icons.work_outline,
      activeIcon: Icons.work,
    ),
    _TabSpec(
      label: 'Mensagens',
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
    ),
    _TabSpec(
      label: 'Perfil',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _bgDark : _surfaceCream;
    final navBg = isDark
        ? const Color(0xFF111827)
        : Colors.white;
    final inactiveColor = isDark ? Colors.white60 : const Color(0xFF94A3B8);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: navBg,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          bottom: false,
          child: switch (_currentTab) {
            0 => const FeedView(),
            _ => _PlaceholderTab(label: _tabs[_currentTab].label),
          },
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: navBg,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : _primary.withValues(alpha: 0.10),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final tab = _tabs[i];
                  final active = i == _currentTab;
                  return Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _currentTab = i),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              active ? tab.activeIcon : tab.icon,
                              size: 22,
                              color: active ? _primary : inactiveColor,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tab.label,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: active ? _primary : inactiveColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? Colors.white60 : const Color(0xFF94A3B8);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 48, color: muted),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Em breve.',
            style: GoogleFonts.inter(fontSize: 14, color: muted),
          ),
        ],
      ),
    );
  }
}
