import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class CurrentPlanStatus extends StatelessWidget {
  final bool isPremium;
  final String? planName;
  final DateTime? expiryDate;

  const CurrentPlanStatus({
    Key? key,
    required this.isPremium,
    this.planName,
    this.expiryDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: isPremium
            ? LinearGradient(
                colors: [
                  AppTheme.lightTheme.primaryColor,
                  AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  AppTheme.lightTheme.colorScheme.surface,
                  AppTheme.lightTheme.colorScheme.surface
                      .withValues(alpha: 0.9),
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        border: !isPremium
            ? Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isPremium
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: isPremium ? 'workspace_premium' : 'account_circle',
                  color: isPremium
                      ? Colors.white
                      : AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPremium ? 'Premium Plan' : 'Free Plan',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        color: isPremium
                            ? Colors.white
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                      ),
                    ),
                    if (isPremium && planName != null)
                      Text(
                        planName!,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12.sp,
                        ),
                      ),
                  ],
                ),
              ),
              if (isPremium)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ACTIVE',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 3.h),
          if (isPremium && expiryDate != null) ...[
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Expires on ${_formatDate(expiryDate!)}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
          ],
          Row(
            children: [
              Expanded(
                child: _buildFeatureItem(
                  icon: 'quiz',
                  text: isPremium ? 'Unlimited Questions' : '10 Questions/Exam',
                  isPremium: isPremium,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildFeatureItem(
                  icon: 'auto_awesome',
                  text: isPremium ? 'AI Generation' : 'Manual Only',
                  isPremium: isPremium,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildFeatureItem(
                  icon: 'analytics',
                  text: isPremium ? 'Advanced Analytics' : 'Basic Reports',
                  isPremium: isPremium,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildFeatureItem(
                  icon: 'file_download',
                  text: isPremium ? 'Export Options' : 'View Only',
                  isPremium: isPremium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required String icon,
    required String text,
    required bool isPremium,
  }) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: isPremium
              ? Colors.white.withValues(alpha: 0.8)
              : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 16,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            text,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: isPremium
                  ? Colors.white.withValues(alpha: 0.8)
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontSize: 10.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
