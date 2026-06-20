import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/services/auth_service.dart';
import '../core/services/notifications_service.dart';
import '../main.dart' show rootMessengerKey, rootNavigatorKey;
import '../models/user_role.dart';
import '../models/app_user.dart';
import '../widgets/rating_stars.dart';
import 'client_dashboard_view.dart';
import 'edit_profile_view.dart';
import 'feed_view.dart';
import 'login_view.dart';
import 'messages_view.dart';
import 'my_contracts_view.dart';
import 'my_proposals_view.dart';
import 'received_proposals_view.dart';
import 'wallet_view.dart';

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

  late final UserRole _role = widget.initialRole;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _initPushNotifications();
  }

  Future<void> _initPushNotifications() async {
    // Guard pra ambiente de teste sem Firebase.initializeApp.
    if (Firebase.apps.isEmpty) return;
    final user = await AuthService.instance.currentAppUser();
    if (user == null || !mounted) return;
    await NotificationsService.instance.initialize(
      uid: user.uid,
      messengerKey: rootMessengerKey,
      navigatorKey: rootNavigatorKey,
    );
  }

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
        onSignOut: _handleSignOut,
      );
    }
    if (_currentTab == 1 && _role == UserRole.freelancer) {
      return const MyProposalsView();
    }
    if (_currentTab == 1 && _role == UserRole.client) {
      return const ReceivedProposalsView();
    }
    // Mensagens é a tab índice 2 em ambos os roles.
    if (_currentTab == 2) {
      return const MessagesView();
    }
    return _PlaceholderTab(label: _tabs[_currentTab].label);
  }

  Future<void> _handleSignOut() async {
    final user = await AuthService.instance.currentAppUser();
    if (user != null) {
      await NotificationsService.instance.dispose(user.uid);
    }
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
      (route) => false,
    );
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

class _ProfileTab extends StatefulWidget {
  const _ProfileTab({required this.currentRole, required this.onSignOut});

  final UserRole currentRole;
  final Future<void> Function() onSignOut;

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  static const _primary = Color(0xFF3B309E);

  AppUser? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (!Firebase.apps.isNotEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final user = await AuthService.instance.currentAppUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _openEdit() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const EditProfileView()),
    );
    if (updated == true) {
      await _loadUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? Colors.white60 : const Color(0xFF94A3B8);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }

    final name = _user?.displayName ?? '';
    final email = _user?.email ?? '';
    final photoUrl = _user?.photoUrl;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ProfileAvatar(
            photoUrl: photoUrl,
            name: name,
            size: 96,
          ),
          const SizedBox(height: 16),
          Text(
            name.isEmpty ? 'Perfil' : name,
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              email,
              style: GoogleFonts.inter(fontSize: 13, color: muted),
            ),
          ],
          if (_user?.ratingAverage != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RatingStars(
                  value: _user!.ratingAverage!.round(),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_user!.ratingAverage!.toStringAsFixed(1)} '
                  '(${_user!.ratingCount} '
                  '${_user!.ratingCount == 1 ? "avaliação" : "avaliações"})',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: muted,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Você está como ${widget.currentRole.displayName}.',
            style: GoogleFonts.inter(fontSize: 13, color: muted),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Editar perfil'),
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WalletView()),
              ),
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
              label: const Text('Carteira'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: const BorderSide(color: _primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyContractsView()),
              ),
              icon: const Icon(Icons.assignment_outlined, size: 18),
              label: const Text('Meus contratos'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: const BorderSide(color: _primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onSignOut,
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sair'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFBA1A1A),
                side: const BorderSide(color: Color(0xFFBA1A1A)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.photoUrl,
    required this.name,
    required this.size,
  });

  final String? photoUrl;
  final String name;
  final double size;

  static const _primary = Color(0xFF3B309E);

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _initialsFallback(),
        ),
      );
    }
    return _initialsFallback();
  }

  Widget _initialsFallback() {
    final initials = _initialsOf(name);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _primary.withValues(alpha: 0.18),
        border: Border.all(color: _primary, width: 2),
      ),
      child: Text(
        initials,
        style: GoogleFonts.dmSans(
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
          color: _primary,
        ),
      ),
    );
  }

  static String _initialsOf(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
