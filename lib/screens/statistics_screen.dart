import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '/models/tally.dart';
import '/providers/tally_provider.dart';
import '/providers/theme_notifier.dart';
import '/widgets/progress_chart.dart';

class StatisticsScreen extends StatefulWidget {
  final Tally tally;

  const StatisticsScreen({super.key, required this.tally});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'Statistics for ${widget.tally.title}',
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orange,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.white.withAlpha(179),
          tabs: const [
            Tab(
              child: Text('Week'),
            ),
            Tab(
              child: Text('Month'),
            ),
            Tab(
              child: Text('Year'),
            ),
          ],
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
          child: Consumer<TallyProvider>(
            builder: (context, provider, child) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildProgressChart(provider, 'week'),
                  _buildProgressChart(provider, 'month'),
                  _buildProgressChart(provider, 'year'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProgressChart(TallyProvider provider, String period) {
    return Container(
      margin: const EdgeInsets.all(16.0),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ProgressChart(
                  weeklyData: provider.getWeeklyStatistics(widget.tally),
                  monthlyData: provider.getMonthlyStatistics(widget.tally),
                  yearlyData: provider.getYearlyStatistics(widget.tally),
                  period: period,
                )
                    .animate()
                    .fadeIn(
                      duration: 600.ms,
                    )
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
