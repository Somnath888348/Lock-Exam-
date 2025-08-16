import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StudentAttemptItem extends StatelessWidget {
  final Map<String, dynamic> attemptData;
  final VoidCallback? onViewDetails;
  final VoidCallback? onFlag;

  const StudentAttemptItem({
    Key? key,
    required this.attemptData,
    this.onViewDetails,
    this.onFlag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = attemptData['status'] as String? ?? 'unknown';
    final score = attemptData['score'] as double? ?? 0.0;
    final studentName =
        attemptData['studentName'] as String? ?? 'Unknown Student';
    final timeTaken = attemptData['timeTaken'] as String? ?? 'N/A';
    final submittedAt = attemptData['submittedAt'] as String? ?? 'N/A';

    return Dismissible(
      key: Key(
          'attempt_${attemptData['id'] ?? DateTime.now().millisecondsSinceEpoch}'),
      background: Container(
        color: AppTheme.lightTheme.colorScheme.tertiary,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'visibility',
              size: 24,
              color: Colors.white,
            ),
            SizedBox(width: 2.w),
            Text(
              'View Details',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Colors.orange,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Flag for Review',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'flag',
              size: 24,
              color: Colors.white,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onViewDetails?.call();
        } else if (direction == DismissDirection.endToStart) {
          onFlag?.call();
        }
        return false; // Don't actually dismiss
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: _getStatusColor(status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusColor(status).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _getStatusIcon(status),
                  size: 20,
                  color: _getStatusColor(status),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          studentName,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getScoreColor(score).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status == 'completed'
                              ? '${score.toStringAsFixed(0)}%'
                              : status.toUpperCase(),
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: _getScoreColor(score),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        size: 14,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Time: $timeTaken',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                      SizedBox(width: 4.w),
                      CustomIconWidget(
                        iconName: 'access_time',
                        size: 14,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          submittedAt,
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'details':
                    onViewDetails?.call();
                    break;
                  case 'flag':
                    onFlag?.call();
                    break;
                  case 'export':
                    _exportAttempt();
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'details',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'visibility',
                        size: 18,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                      SizedBox(width: 3.w),
                      Text('View Details'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'flag',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'flag',
                        size: 18,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 3.w),
                      Text('Flag for Review'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'download',
                        size: 18,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                      SizedBox(width: 3.w),
                      Text('Export Results'),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: EdgeInsets.all(2.w),
                child: CustomIconWidget(
                  iconName: 'more_vert',
                  size: 20,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'terminated':
      case 'cheating':
        return Colors.red;
      case 'in_progress':
      case 'active':
        return Colors.orange;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'check_circle';
      case 'terminated':
      case 'cheating':
        return 'error';
      case 'in_progress':
      case 'active':
        return 'schedule';
      default:
        return 'help';
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) {
      return AppTheme.lightTheme.colorScheme.tertiary;
    } else if (score >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _exportAttempt() {
    // Implementation for exporting individual attempt
  }
}
