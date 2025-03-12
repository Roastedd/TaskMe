import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../providers/theme_notifier.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.black : const Color(0xFF0064A0);
    final gradientColors = isDarkMode
        ? [const Color(0xFF1F1F1F), const Color(0xFF121212)]
        : [const Color(0xFF0064A0), const Color(0xFF004D7A)];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ).animate().fadeIn(duration: 300.ms).scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              duration: 400.ms,
              curve: Curves.easeOutBack,
            ),
        title: Text(
          'Help',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ).animate().fadeIn(duration: 400.ms).slideX(
              begin: -0.2,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOutQuad,
            ),
      ),
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 16),
            Expanded(
              child: PageView(
                controller: _controller,
                children: [
                  _buildHelpCard(
                    icon: Icons.create,
                    title: 'Creating a Habit',
                    content:
                        'To create a habit, navigate to the "Create Habit" screen. Fill out the necessary details including the task name, frequency, start date, goal, and reminders. Once complete, tap "Done" to save your new habit.',
                    color: Colors.orange,
                    index: 0,
                  ),
                  _buildHelpCard(
                    icon: Icons.list,
                    title: 'Managing Habits',
                    content:
                        'You can view and manage your habits on the main screen. Tap on a habit to increment its count or modify its settings. Long press to delete a habit.',
                    color: Colors.blue,
                    index: 1,
                  ),
                  _buildHelpCard(
                    icon: Icons.alarm,
                    title: 'Setting Reminders',
                    content:
                        'To set reminders, go to the "Create Habit" or "Edit Habit" screen. Tap the "Reminders" section and add the desired times. You will receive notifications to update your habit at the set times.',
                    color: Colors.green,
                    index: 2,
                  ),
                  _buildHelpCard(
                    icon: Icons.show_chart,
                    title: 'Tracking Progress',
                    content:
                        'The app tracks your progress and provides statistics. View daily, weekly, and monthly statistics to monitor your habits and achievements.',
                    color: Colors.purple,
                    index: 3,
                  ),
                  _buildHelpCard(
                    icon: Icons.settings,
                    title: 'Customizing Settings',
                    content:
                        'In the settings screen, you can customize various options including dark mode, week start day, notifications, sound, and haptic feedback. Personalize the app to suit your preferences.',
                    color: Colors.pink,
                    index: 4,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24.0),
              child: SmoothPageIndicator(
                controller: _controller,
                count: 5,
                effect: WormEffect(
                  activeDotColor: Colors.orange,
                  dotColor: Colors.white.withAlpha(51),
                  dotHeight: 12,
                  dotWidth: 12,
                  spacing: 16,
                ),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(red: 0, green: 0, blue: 0, alpha: 77),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withAlpha(26),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 64,
                    color: color,
                  ).animate(delay: (100 * index).ms).fadeIn().scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1, 1),
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ).animate(delay: (200 * index).ms).fadeIn().slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOutQuad,
                      ),
                  const SizedBox(height: 16),
                  Text(
                    content,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withAlpha(204),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ).animate(delay: (300 * index).ms).fadeIn().slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOutQuad,
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
