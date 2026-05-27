import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_role.dart';
import 'client_dashboard_view.dart';
import 'feed_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, this.initialRole = UserRole.freelancer});

  final UserRole initialRole;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const _primary = Color(0xFF3B309E);
  static const _surfaceCream = Color(0xFFFBF9F2);
  static const _bgDark = Color(0xFF0B1020);

  late UserRole _role = widget.initialRole;
  int _currentTab = 0;

  static const _freelancerTabs = [
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

  static const _clientTabs = [
    _TabSpec(
      label: 'Painel',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    _TabSpec(
      label: 'Projetos',
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder,
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

  List<_TabSpec> get _tabs =>
      _role == UserRole.freelancer ? _freelancerTabs : _clientTabs;

  Widget _bodyForCurrentTab() {
    if (_currentTab == 0) {
      return _role == UserRole.freelancer
          ? const FeedView()
          : const ClientDashboardView();
    }
    if (_currentTab == _tabs.length - 1) {
      return _ProfileTab(
        currentRole: _role,
        onSwitchRole: () => setState(() {
          _role = _role == UserRole.freelancer
              ? UserRole.client
              : UserRole.freelancer;
          _currentTab = 0;
        }),
      );
    }
    return _PlaceholderTab(label: _tabs[_currentTab].label);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _bgDark : _surfaceCream;
    final navBg = isDark ? const Color(0xFF111827) : Colors.white;
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
        body: SafeArea(bottom: false, child: _bodyForCurrentTab()),
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

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.currentRole, required this.onSwitchRole});

  final UserRole currentRole;
  final VoidCallback onSwitchRole;

  static const _primary = Color(0xFF3B309E);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? Colors.white60 : const Color(0xFF94A3B8);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final other = currentRole == UserRole.freelancer
        ? UserRole.client
        : UserRole.freelancer;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 48, color: muted),
          const SizedBox(height: 12),
          Text(
            'Perfil',
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Em breve.',
            style: GoogleFonts.inter(fontSize: 14, color: muted),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: isDark ? 0.18 : 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _primary.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'MODO DEMO',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Você está como ${currentRole.displayName}.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Roteamento por papel será automatizado quando o Firebase Auth entrar.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: muted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onSwitchRole,
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: Text('Trocar para ${other.displayName}'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primary,
                      side: const BorderSide(color: _primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
