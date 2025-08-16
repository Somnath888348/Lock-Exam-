import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentExamsCardWidget extends StatelessWidget {
  final List<Map<String, dynamic>> recentExams;
  final Function(Map<String, dynamic>) onExamTap;
  final Function(Map<String, dynamic>) onExamLongPress;

  const RecentExamsCardWidget({
    Key? key,
    required this.recentExams,
    required this.onExamTap,
    required this.onExamLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'history',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 24,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Recent Exams',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all exams view
                  },
                  child: Text(
                    'View All',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            recentExams.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentExams.length > 5 ? 5 : recentExams.length,
                    separatorBuilder: (context, index) => SizedBox(height: 1.h),
                    itemBuilder: (context, index) {
                      final exam = recentExams[index];
                      return _buildExamItem(context, exam);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 15.h,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'quiz',
            color: AppTheme.textDisabledLight,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No exams created yet',
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Create your first exam to get started',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textDisabledLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamItem(BuildContext context, Map<String, dynamic> exam) {
    final examName = exam['name'] as String? ?? 'Untitled Exam';
    final status = exam['status'] as String? ?? 'draft';
    final studentsCount = exam['studentsCount'] as int? ?? 0;
    final createdDate = exam['createdDate'] as String? ?? '';

    return InkWell(
      onTap: () => onExamTap(exam),
      onLongPress: () => onExamLongPress(exam),
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: CustomIconWidget(
                iconName: _getStatusIcon(status),
                color: _getStatusColor(status),
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    examName,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'people',
                        color: AppTheme.textSecondaryLight,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '$studentsCount students',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      CustomIconWidget(
                        iconName: 'calendar_today',
                        color: AppTheme.textSecondaryLight,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          createdDate,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                _buildStatusBadge(status),
                SizedBox(height: 1.h),
                CustomIconWidget(
                  iconName: 'more_vert',
                  color: AppTheme.textSecondaryLight,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppTheme.accentSuccess;
      case 'completed':
        return AppTheme.lightTheme.primaryColor;
      case 'draft':
      default:
        return AppTheme.accentWarning;
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'play_circle_filled';
      case 'completed':
        return 'check_circle';
      case 'draft':
      default:
        return 'edit';
    }
  }
}
