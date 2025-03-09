import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskme/providers/tally_provider.dart';

import '../models/tally.dart';

class TallyDetailScreen extends StatelessWidget {
  final Tally tally;

  const TallyDetailScreen({super.key, required this.tally});

  @override
  Widget build(BuildContext context) {
    final tallyProvider = Provider.of<TallyProvider>(context);
    final tallyFromProvider = tallyProvider.getTallyById(tally.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(tallyFromProvider?.title ?? 'Tally Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16.0),
                    _buildStatRow('Total Count',
                        tallyFromProvider?.currentValue.toString() ?? ''),
                    _buildStatRow('Target',
                        tallyFromProvider?.targetValue.toString() ?? 'None'),
                    _buildStatRow('Increment Value',
                        tallyFromProvider?.incrementValue.toString() ?? ''),
                    _buildStatRow('Reset Interval',
                        tallyFromProvider?.resetInterval.toString() ?? ''),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16.0),
                    _buildStatRow('Start Date',
                        tallyFromProvider?.startDate.toString() ?? ''),
                    _buildStatRow('Track Days',
                        tallyFromProvider?.trackDays.toString() ?? ''),
                    if (tallyFromProvider?.reminderTimes.isNotEmpty ?? false)
                      _buildStatRow('Reminders',
                          tallyFromProvider?.reminderTimes.toString() ?? ''),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }
}
