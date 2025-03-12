import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/theme_notifier.dart';
import '../providers/user_provider.dart';
import '../config/theme_config.dart';
import '../config/styles.dart';
import '../widgets/common_widgets.dart';
import 'help_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CommonWidgets.buildAppBar(
          title: 'Settings',
          centerTitle: true,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppStyles.buildSettingsSection(
              title: 'APPEARANCE',
              children: [
                AppStyles.buildSettingsItem(
                  icon: Icons.dark_mode,
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: themeNotifier.isDarkMode,
                    onChanged: (value) => themeNotifier.toggleTheme(value),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms).slideX(
                  begin: -0.2,
                  end: 0,
                  duration: 300.ms,
                  curve: Curves.easeOutQuad,
                ),
            AppStyles.buildSettingsSection(
              title: 'ACCOUNT',
              children: [
                AppStyles.buildSettingsItem(
                  icon: Icons.person,
                  title: 'Profile',
                  subtitle: userProvider.supabaseUser?.email ?? 'Not signed in',
                  onTap: () {
                    // Handle profile tap
                  },
                ),
                AppStyles.buildSettingsItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  onTap: () {
                    // Handle notifications tap
                  },
                ),
                AppStyles.buildSettingsItem(
                  icon: Icons.security,
                  title: 'Privacy',
                  onTap: () {
                    // Handle privacy tap
                  },
                ),
              ],
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideX(
                  begin: -0.2,
                  end: 0,
                  duration: 300.ms,
                  curve: Curves.easeOutQuad,
                ),
            AppStyles.buildSettingsSection(
              title: 'SUPPORT',
              children: [
                AppStyles.buildSettingsItem(
                  icon: Icons.help,
                  title: 'Help & FAQ',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpScreen(),
                      ),
                    );
                  },
                ),
                AppStyles.buildSettingsItem(
                  icon: Icons.feedback,
                  title: 'Send Feedback',
                  onTap: () {
                    // Handle feedback tap
                  },
                ),
                AppStyles.buildSettingsItem(
                  icon: Icons.info,
                  title: 'About',
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
              ],
            ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideX(
                  begin: -0.2,
                  end: 0,
                  duration: 300.ms,
                  curve: Curves.easeOutQuad,
                ),
            AppStyles.buildSettingsSection(
              title: 'DANGER ZONE',
              children: [
                AppStyles.buildSettingsItem(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  onTap: () => _showSignOutDialog(context),
                  showDivider: false,
                ),
              ],
            ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideX(
                  begin: -0.2,
                  end: 0,
                  duration: 300.ms,
                  curve: Curves.easeOutQuad,
                ),
            const SizedBox(height: AppStyles.spacing24),
          ],
        ),
      ),
    );
  }

  Future<void> _showSignOutDialog(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              userProvider.signOut();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'About TaskMe',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppStyles.spacing8),
            Text(
              'TaskMe is your personal task management companion, designed to help you stay organized and productive.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
