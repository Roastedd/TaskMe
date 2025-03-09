import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/tally_provider.dart';
import '/providers/theme_notifier.dart';
import '/models/tally.dart';
import '/widgets/statistics_card.dart';

class PlayerStatisticsScreen extends StatelessWidget {
  const PlayerStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final backgroundColor = isDarkMode ? Colors.black : const Color(0xFF0064A0);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('All Task Statistics'),
          backgroundColor: backgroundColor,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Week'),
              Tab(text: 'Month'),
              Tab(text: 'Year'),
            ],
          ),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
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
    );
  }

  Widget _buildStatisticsTab(BuildContext context, TallyProvider provider, List<Tally> tasks, String period) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: StatisticsCard(tally: task, period: period),
        );
      },
    );
  }
}
