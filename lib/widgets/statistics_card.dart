import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '/models/tally.dart';
import '/providers/tally_provider.dart';

class StatisticsCard extends StatelessWidget {
  final Tally tally;
  final String period;

  const StatisticsCard({super.key, required this.tally, required this.period});

  @override
  Widget build(BuildContext context) {
    final tallyProvider = Provider.of<TallyProvider>(context);
    switch (period) {
      case 'week':
        return _buildWeekStatistics(tallyProvider, tally);
      case 'month':
        return _buildMonthStatistics(tallyProvider, tally);
      case 'year':
        return _buildYearStatistics(tallyProvider, tally);
      default:
        return Container();
    }
  }

  Widget _buildWeekStatistics(TallyProvider provider, Tally tally) {
    final weekData = provider.getWeeklyStatistics(tally);
    final total = weekData.values.reduce((a, b) => a + b).toDouble();
    final nonZeroCount = weekData.values.where((value) => value > 0).length;
    final average = nonZeroCount > 0 ? total / nonZeroCount : 0.0;
    final maxY = weekData.isNotEmpty ? weekData.values.reduce((a, b) => a > b ? a : b).toDouble() : 0.0;
    final interval = maxY > 500 ? 100 : maxY > 100 ? 50 : 10;

    return SingleChildScrollView(
      child: Card(
        color: Color(tally.color),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tally.title, // Changed from tally.name to tally.title
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'WEEK TOTAL: $total | AVERAGE: ${average.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barGroups: weekData.entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.toDouble(),
                            color: Colors.white,
                            width: 10,
                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: maxY > 0 ? maxY : 10, // Set a default maxY if it's zero
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: interval.toDouble(),
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(0),
                              style: const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
                            return SideTitleWidget(
                              space: 4,
                              meta: meta,
                              child: Text(
                                days[value.toInt()],
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipPadding: const EdgeInsets.all(0),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            rod.toY.round().toString(),
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthStatistics(TallyProvider provider, Tally tally) {
    final monthData = provider.getMonthlyStatistics(tally);
    final total = monthData.values.reduce((a, b) => a + b).toDouble();
    final nonZeroCount = monthData.values.where((value) => value > 0).length;
    final average = nonZeroCount > 0 ? total / nonZeroCount : 0.0;
    final maxY = monthData.isNotEmpty ? monthData.values.reduce((a, b) => a > b ? a : b).toDouble() : 0.0;
    final interval = maxY > 500 ? 100 : maxY > 100 ? 50 : 10;

    return SingleChildScrollView(
      child: Card(
        color: Color(tally.color),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tally.title, // Changed from tally.name to tally.title
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'MONTH TOTAL: $total | AVERAGE: ${average.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barGroups: monthData.entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.toDouble(),
                            color: Colors.white,
                            width: 8, // Adjusted width for better spacing
                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: maxY > 0 ? maxY : 10, // Set a default maxY if it's zero
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                        barsSpace: 4, // Added spacing between bars
                      );
                    }).toList(),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: interval.toDouble(),
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(0),
                              style: const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            if (value % 3 == 0) {
                              return SideTitleWidget(
                                space: 4,
                                meta: meta,
                                child: Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipPadding: const EdgeInsets.all(0),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            rod.toY.round().toString(),
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearStatistics(TallyProvider provider, Tally tally) {
    final yearData = provider.getYearlyStatistics(tally);
    final total = yearData.values.reduce((a, b) => a + b).toDouble();
    final nonZeroCount = yearData.values.where((value) => value > 0).length;
    final average = nonZeroCount > 0 ? total / nonZeroCount : 0.0;
    final maxY = yearData.isNotEmpty ? yearData.values.reduce((a, b) => a > b ? a : b).toDouble() : 0.0;
    final interval = maxY > 500 ? 100 : maxY > 100 ? 50 : 10;

    return SingleChildScrollView(
      child: Card(
        color: Color(tally.color),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tally.title, // Changed from tally.name to tally.title
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'YEAR TOTAL: $total | AVERAGE: ${average.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barGroups: yearData.entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.toDouble(),
                            color: Colors.white,
                            width: 10,
                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: maxY > 0 ? maxY : 10, // Set a default maxY if it's zero
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: interval.toDouble(),
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(0),
                              style: const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                            return SideTitleWidget(
                              space: 4,
                              meta: meta,
                              child: Text(
                                months[value.toInt()],
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipPadding: const EdgeInsets.all(0),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            rod.toY.round().toString(),
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
