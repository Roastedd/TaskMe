import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/tally.dart';
import '/providers/tally_provider.dart';
import '/widgets/progress_chart.dart';

class StatisticsScreen extends StatefulWidget {
  final Tally tally;

  const StatisticsScreen({super.key, required this.tally});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics for ${widget.tally.title}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Week'),
            Tab(text: 'Month'),
            Tab(text: 'Year'),
          ],
        ),
      ),
      body: Consumer<TallyProvider>(
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
    );
  }

  Widget _buildProgressChart(TallyProvider provider, String period) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ProgressChart(
          weeklyData: provider.getWeeklyStatistics(widget.tally),
          monthlyData: provider.getMonthlyStatistics(widget.tally),
          yearlyData: provider.getYearlyStatistics(widget.tally),
          period: period,
        ),
      ),
    );
  }
}
