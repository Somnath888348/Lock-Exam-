import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class TroubleshootingWidget extends StatelessWidget {
  const TroubleshootingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.accentWarning.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentWarning.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'build',
                color: AppTheme.accentWarning,
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Troubleshooting Tips',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.accentWarning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildTroubleshootingTip(
            'Camera not working?',
            'Check if another app is using the camera and close it',
          ),
          SizedBox(height: 1.5.h),
          _buildTroubleshootingTip(
            'Permission denied?',
            'Go to Settings > Apps > SafeExam AI > Permissions > Camera',
          ),
          SizedBox(height: 1.5.h),
          _buildTroubleshootingTip(
            'Poor lighting?',
            'Ensure you are in a well-lit area facing the camera',
          ),
          SizedBox(height: 1.5.h),
          _buildTroubleshootingTip(
            'Multiple faces detected?',
            'Make sure you are alone in the camera frame',
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingTip(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          description,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
