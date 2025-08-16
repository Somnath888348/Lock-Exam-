import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsCardWidget extends StatelessWidget {
  final VoidCallback onCreateExam;
  final VoidCallback onGenerateQuestions;
  final VoidCallback onViewQuestionBank;

  const QuickActionsCardWidget({
    Key? key,
    required this.onCreateExam,
    required this.onGenerateQuestions,
    required this.onViewQuestionBank,
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
              children: [
                CustomIconWidget(
                  iconName: 'flash_on',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Quick Actions',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            _buildActionButton(
              title: 'Create New Exam',
              subtitle: 'Set up a new examination',
              iconName: 'add_circle',
              color: AppTheme.lightTheme.primaryColor,
              onTap: onCreateExam,
              isPrimary: true,
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    title: 'Generate Questions',
                    subtitle: 'AI-powered questions',
                    iconName: 'auto_awesome',
                    color: AppTheme.accentSuccess,
                    onTap: onGenerateQuestions,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildActionButton(
                    title: 'Question Bank',
                    subtitle: 'Manage questions',
                    iconName: 'library_books',
                    color: AppTheme.accentWarning,
                    onTap: onViewQuestionBank,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required String iconName,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isPrimary ? 4.w : 3.w),
        decoration: BoxDecoration(
          color: isPrimary ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.0),
          border: isPrimary
              ? null
              : Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1.0,
                ),
        ),
        child: isPrimary
            ? _buildPrimaryActionContent(title, subtitle, iconName, color)
            : _buildSecondaryActionContent(title, subtitle, iconName, color),
      ),
    );
  }

  Widget _buildPrimaryActionContent(
      String title, String subtitle, String iconName, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: Colors.white,
            size: 28,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                subtitle,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        CustomIconWidget(
          iconName: 'arrow_forward',
          color: Colors.white,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildSecondaryActionContent(
      String title, String subtitle, String iconName, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 0.5.h),
        Text(
          subtitle,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
