import 'package:flutter/material.dart';
import '/models/tally.dart';
import '/widgets/statistics_card.dart';
import 'package:provider/provider.dart';
import '/providers/theme_notifier.dart';

class StatisticsScreen extends StatelessWidget {
  final Tally tally;

  const StatisticsScreen({super.key, required this.tally});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final backgroundColor = isDarkMode ? Colors.black : const Color(0xFF0064A0);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Statistics'),
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
          child: TabBarView(
            children: [
              StatisticsCard(tally: tally, period: 'week'),
              StatisticsCard(tally: tally, period: 'month'),
              StatisticsCard(tally: tally, period: 'year'),
            ],
          ),
        ),
      ),
    );
  }
}
