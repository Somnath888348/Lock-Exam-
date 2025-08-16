import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ResultsAnalyticsChart extends StatefulWidget {
  final List<Map<String, dynamic>> examData;
  final bool isPremium;

  const ResultsAnalyticsChart({
    Key? key,
    required this.examData,
    this.isPremium = false,
  }) : super(key: key);

  @override
  State<ResultsAnalyticsChart> createState() => _ResultsAnalyticsChartState();
}

class _ResultsAnalyticsChartState extends State<ResultsAnalyticsChart>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedChartIndex = 0;

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
    if (!widget.isPremium) {
      return _buildPremiumPrompt();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'analytics',
                  size: 24,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Analytics Dashboard',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            onTap: (index) => setState(() => _selectedChartIndex = index),
            tabs: const [
              Tab(text: 'Score Distribution'),
              Tab(text: 'Completion Times'),
              Tab(text: 'Question Analysis'),
            ],
          ),
          SizedBox(
            height: 40.h,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildScoreDistributionChart(),
                _buildCompletionTimesChart(),
                _buildQuestionAnalysisChart(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumPrompt() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'analytics',
            size: 48,
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.7),
          ),
          SizedBox(height: 2.h),
          Text(
            'Premium Analytics',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Unlock detailed charts and insights about student performance, score distributions, and question analysis.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, '/premium-subscription-screen'),
            icon: CustomIconWidget(
              iconName: 'upgrade',
              size: 20,
              color: AppTheme.lightTheme.colorScheme.onPrimary,
            ),
            label: Text('Upgrade to Premium'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDistributionChart() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score Distribution',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = [
                          '0-20',
                          '21-40',
                          '41-60',
                          '61-80',
                          '81-100'
                        ];
                        if (value.toInt() < titles.length) {
                          return Text(
                            titles[value.toInt()],
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                      x: 0,
                      barRods: [BarChartRodData(toY: 5, color: Colors.red)]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(toY: 12, color: Colors.orange)
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(toY: 25, color: Colors.yellow)
                  ]),
                  BarChartGroupData(x: 3, barRods: [
                    BarChartRodData(toY: 35, color: Colors.lightGreen)
                  ]),
                  BarChartGroupData(x: 4, barRods: [
                    BarChartRodData(
                        toY: 45,
                        color: AppTheme.lightTheme.colorScheme.tertiary)
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionTimesChart() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Average Completion Times',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
                        if (value.toInt() < titles.length) {
                          return Text(
                            titles[value.toInt()],
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}m',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 25),
                      FlSpot(1, 22),
                      FlSpot(2, 28),
                      FlSpot(3, 20),
                    ],
                    isCurved: true,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionAnalysisChart() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question Difficulty Analysis',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: 40,
                    title: 'Easy\n40%',
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    radius: 60,
                    titleStyle:
                        AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  PieChartSectionData(
                    value: 35,
                    title: 'Medium\n35%',
                    color: Colors.orange,
                    radius: 60,
                    titleStyle:
                        AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  PieChartSectionData(
                    value: 25,
                    title: 'Hard\n25%',
                    color: Colors.red,
                    radius: 60,
                    titleStyle:
                        AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
