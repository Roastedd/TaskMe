import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../providers/theme_notifier.dart';
import '../providers/tally_provider.dart';
import '../models/tally.dart';

class TallyDetailScreen extends StatelessWidget {
  final Tally tally;

  const TallyDetailScreen({super.key, required this.tally});

  @override
  Widget build(BuildContext context) {
    final tallyProvider = Provider.of<TallyProvider>(context);
    final tallyFromProvider = tallyProvider.getTallyById(tally.id);
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
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
          tallyFromProvider?.title ?? 'Tally Details',
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  context: context,
                  title: 'Statistics',
                  icon: Icons.bar_chart,
                  children: [
                    _buildStatRow(context, 'Total Count',
                        tallyFromProvider?.currentValue.toString() ?? ''),
                    _buildStatRow(context, 'Target',
                        tallyFromProvider?.targetValue.toString() ?? 'None'),
                    _buildStatRow(context, 'Increment Value',
                        tallyFromProvider?.incrementValue.toString() ?? ''),
                    _buildStatRow(context, 'Reset Interval',
                        tallyFromProvider?.resetInterval.toString() ?? ''),
                  ],
                ),
                const SizedBox(height: 16.0),
                _buildSection(
                  context: context,
                  title: 'Schedule',
                  icon: Icons.calendar_today,
                  children: [
                    _buildStatRow(context, 'Start Date',
                        tallyFromProvider?.startDate.toString() ?? ''),
                    _buildStatRow(context, 'Track Days',
                        tallyFromProvider?.trackDays.toString() ?? ''),
                    if (tallyFromProvider?.reminderTimes.isNotEmpty ?? false)
                      _buildStatRow(context, 'Reminders',
                          tallyFromProvider?.reminderTimes.toString() ?? ''),
                  ],
                ),
              ].animate(interval: 100.ms).fadeIn().slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOutQuad,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(77),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha(26),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: Colors.orange,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withAlpha(204),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ).animate().shimmer(
          duration: 1.seconds,
          color: Colors.orange.withAlpha(77),
        );
  }
}
