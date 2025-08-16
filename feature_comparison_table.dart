import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class FeatureComparisonTable extends StatelessWidget {
  const FeatureComparisonTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {
        'feature': 'MCQ Questions per Exam',
        'free': '10 questions',
        'premium': 'Unlimited',
        'freeAvailable': true,
        'premiumAvailable': true,
      },
      {
        'feature': 'AI Question Generation',
        'free': 'Not Available',
        'premium': 'Unlimited',
        'freeAvailable': false,
        'premiumAvailable': true,
      },
      {
        'feature': 'Advanced Analytics',
        'free': 'Basic Reports',
        'premium': 'Detailed Analytics',
        'freeAvailable': true,
        'premiumAvailable': true,
      },
      {
        'feature': 'Export Options',
        'free': 'Not Available',
        'premium': 'PDF, CSV, Excel',
        'freeAvailable': false,
        'premiumAvailable': true,
      },
      {
        'feature': 'Exam Time Limit',
        'free': 'Max 60 minutes',
        'premium': 'Unlimited',
        'freeAvailable': true,
        'premiumAvailable': true,
      },
      {
        'feature': 'Student Attempts Tracking',
        'free': 'Last 10 attempts',
        'premium': 'Complete History',
        'freeAvailable': true,
        'premiumAvailable': true,
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Features',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Free',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Premium',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.primaryColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;

            return Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: index % 2 == 0
                    ? AppTheme.lightTheme.colorScheme.surface
                    : AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.5),
                borderRadius: index == features.length - 1
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      feature['feature'] as String,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: feature['freeAvailable'] as bool
                          ? feature['free'] == 'Not Available'
                              ? CustomIconWidget(
                                  iconName: 'close',
                                  color: AppTheme.lightTheme.colorScheme.error,
                                  size: 18,
                                )
                              : Text(
                                  feature['free'] as String,
                                  textAlign: TextAlign.center,
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    fontSize: 10.sp,
                                  ),
                                )
                          : CustomIconWidget(
                              iconName: 'close',
                              color: AppTheme.lightTheme.colorScheme.error,
                              size: 18,
                            ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: feature['premiumAvailable'] as bool
                          ? feature['premium'] == 'Unlimited' ||
                                  feature['premium'] == 'PDF, CSV, Excel' ||
                                  feature['premium'] == 'Detailed Analytics' ||
                                  feature['premium'] == 'Complete History'
                              ? CustomIconWidget(
                                  iconName: 'check_circle',
                                  color:
                                      AppTheme.lightTheme.colorScheme.tertiary,
                                  size: 18,
                                )
                              : Text(
                                  feature['premium'] as String,
                                  textAlign: TextAlign.center,
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    fontSize: 10.sp,
                                    color: AppTheme.lightTheme.primaryColor,
                                  ),
                                )
                          : CustomIconWidget(
                              iconName: 'close',
                              color: AppTheme.lightTheme.colorScheme.error,
                              size: 18,
                            ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
