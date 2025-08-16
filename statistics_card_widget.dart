import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StatisticsCardWidget extends StatelessWidget {
  final Map<String, dynamic> statisticsData;

  const StatisticsCardWidget({
    Key? key,
    required this.statisticsData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalExams = statisticsData['totalExams'] ?? 0;
    final activeStudents = statisticsData['activeStudents'] ?? 0;
    final completionRate = (statisticsData['completionRate'] ?? 0.0) as double;

    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'analytics',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Statistics Overview',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Exams',
                    totalExams.toString(),
                    'quiz',
                    AppTheme.lightTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Active Students',
                    activeStudents.toString(),
                    'people',
                    AppTheme.accentSuccess,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Completion Rate',
                    '${completionRate.toStringAsFixed(1)}%',
                    'trending_up',
                    AppTheme.accentWarning,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Container(
              height: 20.h,
              width: double.infinity,
              child: Semantics(
                label: "Completion Rate Chart",
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: completionRate,
                        color: AppTheme.lightTheme.primaryColor,
                        title: '${completionRate.toStringAsFixed(1)}%',
                        radius: 8.w,
                        titleStyle:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      PieChartSectionData(
                        value: 100 - completionRate,
                        color: AppTheme.lightTheme.colorScheme.outline,
                        title: '${(100 - completionRate).toStringAsFixed(1)}%',
                        radius: 6.w,
                        titleStyle:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    centerSpaceRadius: 8.w,
                    sectionsSpace: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, String iconName, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
