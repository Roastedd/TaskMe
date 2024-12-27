import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../providers/theme_notifier.dart';
import '../widgets/help_card.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.black : const Color(0xFF0064A0);
    final PageController controller = PageController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
        backgroundColor: backgroundColor,
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller,
              children: const [
                HelpCard(
                  icon: Icons.create,
                  title: 'Creating a Tally',
                  content: 'To create a tally, navigate to the "Create Habit" screen. Fill out the necessary details including the task name, frequency, start date, goal, and reminders. Once complete, tap "Done" to save your new tally.',
                  backgroundColor: Colors.blue,
                ),
                HelpCard(
                  icon: Icons.list,
                  title: 'Managing Tallies',
                  content: 'You can view and manage your tallies on the main screen. Tap on a tally to increment its count or modify its settings. Long press to delete a tally.',
                  backgroundColor: Colors.green,
                ),
                HelpCard(
                  icon: Icons.alarm,
                  title: 'Setting Reminders',
                  content: 'To set reminders, go to the "Create Habit" or "Edit Habit" screen. Tap the "Reminders" section and add the desired times. You will receive notifications to update your tally at the set times.',
                  backgroundColor: Colors.red,
                ),
                HelpCard(
                  icon: Icons.show_chart,
                  title: 'Tracking Progress',
                  content: 'The app tracks your progress and provides statistics. View daily, weekly, and monthly statistics to monitor your habits and achievements.',
                  backgroundColor: Colors.orange,
                ),
                HelpCard(
                  icon: Icons.settings,
                  title: 'Customizing Settings',
                  content: 'In the settings screen, you can customize various options including dark mode, week start day, notifications, sound, and haptic feedback. Personalize the app to suit your preferences.',
                  backgroundColor: Colors.purple,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SmoothPageIndicator(
              controller: controller, // PageController
              count: 5,
              effect: const WormEffect(
                activeDotColor: Colors.white,
                dotColor: Colors.grey,
                dotHeight: 12,
                dotWidth: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
