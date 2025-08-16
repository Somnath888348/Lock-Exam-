import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/current_plan_status.dart';
import './widgets/feature_comparison_table.dart';
import './widgets/premium_code_section.dart';
import './widgets/subscription_plan_card.dart';

class PremiumSubscriptionScreen extends StatefulWidget {
  const PremiumSubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<PremiumSubscriptionScreen> createState() =>
      _PremiumSubscriptionScreenState();
}

class _PremiumSubscriptionScreenState extends State<PremiumSubscriptionScreen> {
  bool _isPremiumUser = false;
  String? _currentPlan;
  DateTime? _expiryDate;
  bool _isProcessingPayment = false;

  final List<Map<String, dynamic>> _mockUserData = [
    {
      "userId": "user_001",
      "isPremium": false,
      "planName": null,
      "expiryDate": null,
    },
    {
      "userId": "user_002",
      "isPremium": true,
      "planName": "Annual Premium",
      "expiryDate": DateTime.now().add(const Duration(days: 300)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserSubscriptionStatus();
  }

  void _loadUserSubscriptionStatus() {
    // Simulate loading current user subscription status
    final currentUser = _mockUserData[0]; // Using first user as current user
    setState(() {
      _isPremiumUser = currentUser["isPremium"] as bool;
      _currentPlan = currentUser["planName"] as String?;
      _expiryDate = currentUser["expiryDate"] as DateTime?;
    });
  }

  Future<void> _handleSubscription(String planType) async {
    if (_isProcessingPayment) return;

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 3));

      // Show success dialog
      if (mounted) {
        _showSubscriptionSuccessDialog(planType);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Payment failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  Future<void> _handlePremiumCodeActivation(String code) async {
    // Mock premium codes for testing
    final List<String> validCodes = [
      'PREMIUM2024',
      'EDUCATION50',
      'TEACHER123',
      'STUDENT99',
    ];

    if (validCodes.contains(code.toUpperCase())) {
      setState(() {
        _isPremiumUser = true;
        _currentPlan = 'Premium Code Activation';
        _expiryDate = DateTime.now().add(const Duration(days: 365));
      });

      _showSuccessDialog('Premium code activated successfully!');
    } else {
      _showErrorDialog('Invalid premium code. Please check and try again.');
    }
  }

  void _showSubscriptionSuccessDialog(String planType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.tertiary
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 48,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Subscription Successful!',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Welcome to $planType! All premium features are now unlocked.',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontSize: 12.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _isPremiumUser = true;
                      _currentPlan = planType;
                      _expiryDate = planType.contains('Annual')
                          ? DateTime.now().add(const Duration(days: 365))
                          : DateTime.now().add(const Duration(days: 30));
                    });
                  },
                  child: Text('Continue'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 48,
              ),
              SizedBox(height: 2.h),
              Text(
                message,
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'error',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 48,
              ),
              SizedBox(height: 2.h),
              Text(
                message,
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSubscriptionManagement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(5.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Subscription Management',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3.h),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'visibility',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                title: Text('View Current Plan'),
                subtitle: Text(_currentPlan ?? 'Free Plan'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'restore',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                title: Text('Restore Purchases'),
                subtitle: Text('Restore previous subscriptions'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No purchases to restore')),
                  );
                },
              ),
              if (_isPremiumUser)
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'cancel',
                    color: AppTheme.lightTheme.colorScheme.error,
                    size: 24,
                  ),
                  title: Text('Cancel Subscription'),
                  subtitle: Text('Manage subscription settings'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Premium Subscription',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          if (_isPremiumUser)
            IconButton(
              onPressed: _showSubscriptionManagement,
              icon: CustomIconWidget(
                iconName: 'settings',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),

                // Current Plan Status
                CurrentPlanStatus(
                  isPremium: _isPremiumUser,
                  planName: _currentPlan,
                  expiryDate: _expiryDate,
                ),

                if (!_isPremiumUser) ...[
                  SizedBox(height: 3.h),

                  // Hero Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unlock Premium Features',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 24.sp,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Get unlimited access to AI-powered question generation, advanced analytics, and export capabilities.',
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Subscription Plans
                  SubscriptionPlanCard(
                    planName: 'Monthly Premium',
                    price: '₹89',
                    billingCycle: '/month',
                    features: [
                      'Unlimited MCQ questions per exam',
                      'AI question generation from text & images',
                      'Advanced analytics & detailed reports',
                      'Export to PDF, CSV, Excel formats',
                      'Priority customer support',
                    ],
                    isPopular: false,
                    isYearly: false,
                    onSubscribe: () => _handleSubscription('Monthly Premium'),
                  ),

                  SubscriptionPlanCard(
                    planName: 'Annual Premium',
                    price: '₹999',
                    billingCycle: '/year',
                    features: [
                      'All monthly premium features',
                      'Save ₹69 compared to monthly billing',
                      'Extended exam time limits',
                      'Complete student attempt history',
                      'Premium badge & priority features',
                    ],
                    isPopular: true,
                    isYearly: true,
                    onSubscribe: () => _handleSubscription('Annual Premium'),
                  ),

                  SizedBox(height: 4.h),

                  // Feature Comparison Table
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      'Feature Comparison',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  const FeatureComparisonTable(),

                  SizedBox(height: 4.h),

                  // Premium Code Section
                  PremiumCodeSection(
                    onActivateCode: _handlePremiumCodeActivation,
                  ),
                ],

                SizedBox(height: 4.h),

                // Terms and Privacy
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'security',
                            color: AppTheme.lightTheme.colorScheme.tertiary,
                            size: 16,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Indian Data Protection Compliant',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.tertiary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Navigate to terms of service
                            },
                            child: Text(
                              'Terms of Service',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.primaryColor,
                                fontSize: 11.sp,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Text(
                            ' • ',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to privacy policy
                            },
                            child: Text(
                              'Privacy Policy',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.primaryColor,
                                fontSize: 11.sp,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 4.h),
              ],
            ),
          ),

          // Loading Overlay
          if (_isProcessingPayment)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      SizedBox(height: 2.h),
                      Text(
                        'Processing Payment...',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Please wait while we process your subscription',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
