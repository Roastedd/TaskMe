import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';
import '../providers/tally_provider.dart';
import '../providers/social_auth_provider.dart';
import '../widgets/about_screen.dart';
import '../screens/help_screen.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart'; // Add this import

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late String weekStart;
  bool notificationsEnabled = true;
  bool soundEnabled = true;

  @override
  void initState() {
    super.initState();
    weekStart = Provider.of<TallyProvider>(context, listen: false).weekStart;
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final socialAuthProvider = Provider.of<SocialAuthProvider>(context);
    final isDarkMode = themeNotifier.isDarkMode;
    const textColor = Colors.white;
    final dropdownColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final backgroundColor = isDarkMode ? Colors.black : const Color(0xFF0064A0);
    final cardColor = isDarkMode ? Colors.grey[850]! : const Color(0xFF0088CC);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: backgroundColor,
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSettingCard(
              context,
              title: 'Dark Mode',
              trailing: Switch(
                value: themeNotifier.isDarkMode,
                onChanged: (value) {
                  themeNotifier.toggleTheme(value);
                },
              ),
              cardColor: cardColor,
              textColor: textColor,
            ),
            _buildSettingCard(
              context,
              title: 'Week Start',
              trailing: DropdownButton<String>(
                value: weekStart,
                dropdownColor: dropdownColor,
                style: const TextStyle(color: textColor),
                items: ['Sunday', 'Monday'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    weekStart = value!;
                    Provider.of<TallyProvider>(context, listen: false).setWeekStart(value);
                  });
                },
              ),
              cardColor: cardColor,
              textColor: textColor,
            ),
            _buildSettingCard(
              context,
              title: 'Notifications',
              trailing: Switch(
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                    // Implement notification toggle logic
                  });
                },
              ),
              cardColor: cardColor,
              textColor: textColor,
            ),
            _buildSettingCard(
              context,
              title: 'Sound',
              trailing: Switch(
                value: soundEnabled,
                onChanged: (value) {
                  setState(() {
                    soundEnabled = value;
                    // Implement sound toggle logic
                  });
                },
              ),
              cardColor: cardColor,
              textColor: textColor,
            ),
            _buildSettingCard(
              context,
              title: 'Backup and Restore',
              trailing: const Icon(Icons.backup, color: textColor),
              onTap: () async {
                await socialAuthProvider.handleGoogleSignIn();

                final driveApi = await socialAuthProvider.getDriveApi();  // Updated to public method
                if (driveApi == null) {
                  // Handle the case where sign-in fails
                  return;
                }

                // Example to back up data
                await socialAuthProvider.backupToDrive(context, Provider.of<TallyProvider>(context, listen: false).tallies);

                // Example to restore data
                final restoredTallies = await socialAuthProvider.restoreFromDrive(context);
                if (restoredTallies != null) {
                  Provider.of<TallyProvider>(context, listen: false).setTallies(restoredTallies);
                }

                // Restart the app after restoring data
                Phoenix.rebirth(context);
              },
              cardColor: cardColor,
              textColor: textColor,
            ),
            _buildSettingCard(
              context,
              title: 'About',
              trailing: const Icon(Icons.info, color: textColor),
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                    const AboutScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;

                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      final offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              cardColor: cardColor,
              textColor: textColor,
            ),
            _buildSettingCard(
              context,
              title: 'Help',
              trailing: const Icon(Icons.help, color: textColor),
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                    const HelpScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;

                      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      final offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              cardColor: cardColor,
              textColor: textColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context,
      {required String title,
        required Widget trailing,
        required Color cardColor,
        required Color textColor,
        VoidCallback? onTap}) {
    return Card(
      color: cardColor,
      child: ListTile(
        title: Text(title, style: TextStyle(color: textColor)),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
