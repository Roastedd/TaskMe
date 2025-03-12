import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/theme_notifier.dart';
import '../providers/tally_provider.dart';
import '/models/tally.dart';
import '/widgets/statistics_card.dart';

class PlayerStatisticsScreen extends StatelessWidget {
  const PlayerStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final gradientColors = isDarkMode
        ? [const Color(0xFF1F1F1F), const Color(0xFF121212)]
        : [const Color(0xFF0064A0), const Color(0xFF004D7A)];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
            'Statistics',
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
            indicatorColor: Colors.orange,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 153),
            labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
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
            indicator: UnderlineTabIndicator(
              borderSide: const BorderSide(
                width: 3,
                color: Colors.orange,
              ),
              insets: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Consumer<TallyProvider>(
                builder: (context, provider, child) {
                  final tasks = provider.tallies;
                  return TabBarView(
                    children: [
                      _buildStatisticsTab(context, provider, tasks, 'week'),
                      _buildStatisticsTab(context, provider, tasks, 'month'),
                      _buildStatisticsTab(context, provider, tasks, 'year'),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsTab(BuildContext context, TallyProvider provider,
      List<Tally> tasks, String period) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 64,
              color: Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 128),
            ).animate().fadeIn(duration: 600.ms).scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 16),
            Text(
              'No habits yet',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 204),
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 600.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 600.ms,
                  curve: Curves.easeOutQuad,
                ),
            const SizedBox(height: 8),
            Text(
              'Create a habit to see your statistics',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 153),
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  duration: 600.ms,
                  curve: Curves.easeOutQuad,
                ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: StatisticsCard(tally: task, period: period)
              .animate(delay: (50 * index).ms)
              .fadeIn()
              .slideX(
                begin: 0.2,
                end: 0,
                duration: 400.ms,
                curve: Curves.easeOutQuad,
              ),
        );
      },
    );
  }
}
