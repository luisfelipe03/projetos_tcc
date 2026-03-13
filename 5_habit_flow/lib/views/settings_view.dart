import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../services/notification_service.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/habit_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'onboarding_view.dart';

class SettingsView extends StatelessWidget {
  final VoidCallback? onBack;

  const SettingsView({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authViewModel = context.watch<AuthViewModel>();
    final settingsViewModel = context.watch<SettingsViewModel>();
    final l10n = context.l10n;

    final strings = _SettingsStrings.fromL10n(
      l10n,
      settingsViewModel.languageCode,
    );

    return Container(
      color: _pageBackground(isDark),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark, strings),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                children: [
                  _buildSectionTitle(strings.account, isDark),
                  const SizedBox(height: 10),
                  _buildSettingsGroup(isDark, [
                    _buildItem(
                      isDark: isDark,
                      icon: Icons.person,
                      iconColor: const Color(0xFF1FC997),
                      title: strings.profile,
                      subtitle: strings.profileSubtitle,
                      onTap: () {
                        _showMessage(context, strings.profileSoon);
                      },
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionTitle(strings.preferences, isDark),
                  const SizedBox(height: 10),
                  _buildSettingsGroup(isDark, [
                    _buildItem(
                      isDark: isDark,
                      icon: Icons.notifications,
                      iconColor: const Color(0xFF3B82F6),
                      title: strings.notifications,
                      onTap: () {
                        _showNotificationsSheet(
                          context,
                          settingsViewModel,
                          strings,
                          isDark,
                        );
                      },
                    ),
                    _buildDivider(isDark),
                    _buildSwitchItem(
                      isDark: isDark,
                      icon: Icons.dark_mode,
                      iconColor: const Color(0xFF8B5CF6),
                      title: strings.darkMode,
                      value: isDark,
                      onChanged: (value) {
                        settingsViewModel.setDarkModeEnabled(value);
                      },
                    ),
                    _buildDivider(isDark),
                    _buildItem(
                      isDark: isDark,
                      icon: Icons.language,
                      iconColor: const Color(0xFFF97316),
                      title: strings.language,
                      trailingText: strings.currentLanguage,
                      onTap: () {
                        _showLanguageSheet(
                          context,
                          settingsViewModel,
                          strings,
                          isDark,
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionTitle(strings.support, isDark),
                  const SizedBox(height: 10),
                  _buildSettingsGroup(isDark, [
                    _buildItem(
                      isDark: isDark,
                      icon: Icons.info,
                      iconColor: const Color(0xFF06B6D4),
                      title: strings.about,
                      onTap: () {
                        _showAboutDialog(context, strings);
                      },
                    ),
                    _buildDivider(isDark),
                    _buildItem(
                      isDark: isDark,
                      icon: Icons.help,
                      iconColor: const Color(0xFFE11D48),
                      title: strings.helpSupport,
                      onTap: () {
                        _showMessage(context, strings.helpSoon);
                      },
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionTitle(strings.development, isDark),
                  const SizedBox(height: 10),
                  _buildSettingsGroup(isDark, [
                    _buildItem(
                      isDark: isDark,
                      icon: Icons.science,
                      iconColor: const Color(0xFF14B8A6),
                      title: strings.seedDatabase,
                      subtitle: strings.seedDatabaseSubtitle,
                      onTap: () {
                        _runSeeder(context, strings);
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildLogoutButton(context, authViewModel, strings, isDark),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      'Version 2.4.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.45)
                            : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    _SettingsStrings strings,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.chevron_left_rounded, size: 30),
            color: onBack != null
                ? (isDark ? Colors.white : const Color(0xFF0F172A))
                : Colors.transparent,
          ),
          Expanded(
            child: Text(
              strings.settings,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.9,
          color: isDark
              ? Colors.white.withValues(alpha: 0.6)
              : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2944) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.06),
    );
  }

  Widget _buildItem({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            _buildIconBubble(icon: icon, iconColor: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingText != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  trailingText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.58)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.32)
                  : const Color(0xFFCBD5E1),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _buildIconBubble(icon: icon, iconColor: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF7C3AED),
            activeThumbColor: Colors.white,
            inactiveTrackColor: isDark
                ? Colors.white.withValues(alpha: 0.22)
                : const Color(0xFFE2E8F0),
            inactiveThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildIconBubble({required IconData icon, required Color iconColor}) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.20),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 26),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    AuthViewModel authViewModel,
    _SettingsStrings strings,
    bool isDark,
  ) {
    return OutlinedButton.icon(
      onPressed: () async {
        final confirmed = await _showLogoutConfirmation(context, strings);
        if (confirmed != true || !context.mounted) {
          return;
        }

        await authViewModel.signOut();
        if (!context.mounted) {
          return;
        }

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OnboardingView()),
          (route) => false,
        );
      },
      icon: const Icon(Icons.logout, size: 26),
      label: Text(
        strings.logOut,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFF87171),
        side: BorderSide(
          color: const Color(0xFFF87171).withValues(alpha: 0.45),
        ),
        minimumSize: const Size(double.infinity, 64),
        backgroundColor: isDark
            ? const Color(0xFF1C2944)
            : Colors.white.withValues(alpha: 0.7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  Future<void> _showLanguageSheet(
    BuildContext context,
    SettingsViewModel settingsViewModel,
    _SettingsStrings strings,
    bool isDark,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C2944) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.chooseLanguage,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),
                _buildLanguageOption(
                  context,
                  settingsViewModel,
                  currentCode: settingsViewModel.languageCode,
                  code: 'en',
                  label: context.l10n.languageOptionEnglish,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildLanguageOption(
                  context,
                  settingsViewModel,
                  currentCode: settingsViewModel.languageCode,
                  code: 'pt',
                  label: context.l10n.languageOptionPortuguese,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    SettingsViewModel settingsViewModel, {
    required String currentCode,
    required String code,
    required String label,
    required bool isDark,
  }) {
    final isSelected = currentCode == code;

    return InkWell(
      onTap: () async {
        await settingsViewModel.setLanguageCode(code);
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF7C3AED).withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7C3AED)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.14)
                      : Colors.black.withValues(alpha: 0.12)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF7C3AED)),
          ],
        ),
      ),
    );
  }

  Future<void> _showNotificationsSheet(
    BuildContext context,
    SettingsViewModel settingsViewModel,
    _SettingsStrings strings,
    bool isDark,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C2944) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.notifications,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.notificationsDescription,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile.adaptive(
                      value: settingsViewModel.notificationsEnabled,
                      onChanged: (value) async {
                        await _applyNotificationPreference(context, value);
                        setState(() {});
                      },
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFF7C3AED),
                      title: Text(
                        strings.enableNotifications,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _applyNotificationPreference(
    BuildContext context,
    bool enabled,
  ) async {
    final settingsViewModel = context.read<SettingsViewModel>();
    await settingsViewModel.setNotificationsEnabled(enabled);

    if (!enabled) {
      return;
    }

    final habitViewModel = context.read<HabitViewModel>();
    if (habitViewModel.habits.isEmpty) {
      await habitViewModel.loadHabits();
    }

    final notificationService = NotificationService();
    for (final habit in habitViewModel.habits) {
      if (habit.reminder != null) {
        await notificationService.scheduleHabitReminder(habit);
      }
    }
  }

  Future<void> _runSeeder(
    BuildContext context,
    _SettingsStrings strings,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(strings.seederInProgress)));

    try {
      final result = await context
          .read<HabitViewModel>()
          .seedFakeDataForDevelopment(clearExistingData: true);

      if (!context.mounted) {
        return;
      }

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            strings.seederSuccess(
              result.habitsCreated,
              result.completionsCreated,
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.seederFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool?> _showLogoutConfirmation(
    BuildContext context,
    _SettingsStrings strings,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.logOut),
        content: Text(strings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(strings.logOut),
          ),
        ],
      ),
    );
  }

  Future<void> _showAboutDialog(
    BuildContext context,
    _SettingsStrings strings,
  ) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.about),
          content: Text(strings.aboutContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.commonOk),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Color _pageBackground(bool isDark) {
    return isDark ? const Color(0xFF071533) : const Color(0xFFF3F4F8);
  }
}

class _SettingsStrings {
  final String settings;
  final String account;
  final String profile;
  final String profileSubtitle;
  final String profileSoon;
  final String preferences;
  final String notifications;
  final String notificationsDescription;
  final String enableNotifications;
  final String darkMode;
  final String language;
  final String support;
  final String development;
  final String about;
  final String aboutContent;
  final String helpSupport;
  final String helpSoon;
  final String seedDatabase;
  final String seedDatabaseSubtitle;
  final String seederInProgress;
  final String Function(int habits, int completions) seederSuccess;
  final String seederFailed;
  final String chooseLanguage;
  final String logOut;
  final String logoutConfirm;
  final String cancel;
  final String currentLanguage;

  const _SettingsStrings({
    required this.settings,
    required this.account,
    required this.profile,
    required this.profileSubtitle,
    required this.profileSoon,
    required this.preferences,
    required this.notifications,
    required this.notificationsDescription,
    required this.enableNotifications,
    required this.darkMode,
    required this.language,
    required this.support,
    required this.development,
    required this.about,
    required this.aboutContent,
    required this.helpSupport,
    required this.helpSoon,
    required this.seedDatabase,
    required this.seedDatabaseSubtitle,
    required this.seederInProgress,
    required this.seederSuccess,
    required this.seederFailed,
    required this.chooseLanguage,
    required this.logOut,
    required this.logoutConfirm,
    required this.cancel,
    required this.currentLanguage,
  });

  factory _SettingsStrings.fromL10n(dynamic l10n, String languageCode) {
    return _SettingsStrings(
      settings: l10n.settingsTitle,
      account: l10n.settingsAccount,
      profile: l10n.settingsProfile,
      profileSubtitle: l10n.settingsProfileSubtitle,
      profileSoon: l10n.settingsProfileSoon,
      preferences: l10n.settingsPreferences,
      notifications: l10n.settingsNotifications,
      notificationsDescription: l10n.settingsNotificationsDescription,
      enableNotifications: l10n.settingsEnableNotifications,
      darkMode: l10n.settingsDarkMode,
      language: l10n.settingsLanguage,
      support: l10n.settingsSupport,
      development: l10n.settingsDevelopment,
      about: l10n.settingsAbout,
      aboutContent: l10n.settingsAboutContent,
      helpSupport: l10n.settingsHelpSupport,
      helpSoon: l10n.settingsHelpSoon,
      seedDatabase: l10n.settingsSeedDatabase,
      seedDatabaseSubtitle: l10n.settingsSeedDatabaseSubtitle,
      seederInProgress: l10n.settingsSeederInProgress,
      seederSuccess: (habits, completions) =>
          l10n.settingsSeederSuccess(habits, completions),
      seederFailed: l10n.settingsSeederFailed,
      chooseLanguage: l10n.settingsChooseLanguage,
      logOut: l10n.settingsLogOut,
      logoutConfirm: l10n.settingsLogoutConfirm,
      cancel: l10n.commonCancel,
      currentLanguage: languageCode == 'pt'
          ? l10n.languageOptionPortuguese
          : l10n.languageOptionEnglish,
    );
  }
}
