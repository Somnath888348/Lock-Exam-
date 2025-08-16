import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FooterLinksWidget extends StatelessWidget {
  const FooterLinksWidget({Key? key}) : super(key: key);

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Privacy Policy',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              'SafeExam AI Proctor collects and processes examination data including camera feeds, device information, and user responses to ensure academic integrity. All data is encrypted and stored securely. Camera feeds are processed in real-time and not permanently stored. User data is retained only for examination purposes and deleted as per institutional policies.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Terms of Service',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              'By using SafeExam AI Proctor, you agree to: 1) Provide accurate information during registration, 2) Allow camera and microphone access for examination monitoring, 3) Not attempt to circumvent security measures, 4) Accept that violations may result in exam termination, 5) Comply with your institution\'s academic integrity policies.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'info_outline',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 3.w,
              ),
              SizedBox(width: 1.w),
              Text(
                'Secure • Encrypted • GDPR Compliant',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => _showPrivacyPolicy(context),
                borderRadius: BorderRadius.circular(8.0),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  child: Text(
                    'Privacy Policy',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 3.h,
                color: AppTheme.lightTheme.colorScheme.outline,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
              ),
              InkWell(
                onTap: () => _showTermsOfService(context),
                borderRadius: BorderRadius.circular(8.0),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  child: Text(
                    'Terms of Service',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            '© 2025 SafeExam AI Proctor. All rights reserved.',
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
