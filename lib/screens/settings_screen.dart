import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';
import '../providers/user_provider.dart';
import '../providers/tally_provider.dart';
import '../widgets/about_screen.dart';
import '../screens/help_screen.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late String weekStart = 'Sunday'; // Set default value
  bool notificationsEnabled = true;
  bool soundEnabled = true;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          weekStart =
              Provider.of<TallyProvider>(context, listen: false).weekStart;
        });
      }
    });
  }

  Future<void> _handleSignOut() async {
    setState(() => _isSigningOut = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.signOut();
      if (mounted) {
        Phoenix.rebirth(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign out failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final dropdownColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final backgroundColor = isDarkMode ? Colors.black : const Color(0xFF0064A0);
    final cardColor = isDarkMode ? Colors.grey[850]! : const Color(0xFF0088CC);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
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
                value: isDarkMode,
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
                style: TextStyle(color: textColor),
                items: ['Sunday', 'Monday'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      weekStart = value;
                      Provider.of<TallyProvider>(context, listen: false)
                          .setWeekStart(value);
                    });
                  }
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
                  });
                },
              ),
              cardColor: cardColor,
              textColor: textColor,
            ),
            _buildSettingCard(
              context,
              title: 'Sign Out',
              trailing: _isSigningOut
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    )
                  : Icon(Icons.logout, color: textColor),
              onTap: _isSigningOut ? null : _handleSignOut,
              cardColor: cardColor,
              textColor: textColor,
            ),
            _buildSettingCard(
              context,
              title: 'About',
              trailing: Icon(Icons.info, color: textColor),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              ),
              cardColor: cardColor,
              textColor: textColor,
            ),
            _buildSettingCard(
              context,
              title: 'Help',
              trailing: Icon(Icons.help, color: textColor),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              ),
              cardColor: cardColor,
              textColor: textColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required String title,
    required Widget trailing,
    required Color cardColor,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return Card(
      color: cardColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
