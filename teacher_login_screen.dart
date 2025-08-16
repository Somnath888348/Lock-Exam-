import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/app_logo_widget.dart';
import './widgets/biometric_login_widget.dart';
import './widgets/login_form_widget.dart';
import 'widgets/app_logo_widget.dart';
import 'widgets/biometric_login_widget.dart';
import 'widgets/login_form_widget.dart';

class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({Key? key}) : super(key: key);

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  bool _isLoading = false;
  bool _isBiometricAvailable = true; // Mock biometric availability
  final ScrollController _scrollController = ScrollController();

  // Mock teacher credentials for demonstration
  final Map<String, String> _mockCredentials = {
    'teacher@safeexam.com': 'teacher123',
    'admin@safeexam.com': 'admin123',
    'demo@safeexam.com': 'demo123',
  };

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    // Mock biometric availability check
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isBiometricAvailable = true;
      });
    }
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Check mock credentials
      if (_mockCredentials.containsKey(email.toLowerCase()) &&
          _mockCredentials[email.toLowerCase()] == password) {
        // Success - provide haptic feedback
        HapticFeedback.lightImpact();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.onPrimaryLight,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text('Login successful! Welcome back.'),
                ],
              ),
              backgroundColor: AppTheme.accentSuccess,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Navigate to teacher dashboard
          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.pushReplacementNamed(context, '/teacher-dashboard-screen');
        }
      } else {
        // Failed authentication
        if (mounted) {
          HapticFeedback.heavyImpact();

          String errorMessage = 'Invalid email or password. Please try again.';

          // Check specific error cases
          if (!_mockCredentials.containsKey(email.toLowerCase())) {
            errorMessage =
                'Account not found. Please check your email address.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'error',
                    color: AppTheme.onPrimaryLight,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(child: Text(errorMessage)),
                ],
              ),
              backgroundColor: AppTheme.accentError,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Network error. Please check your connection and try again.'),
            backgroundColor: AppTheme.accentError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    // Mock successful biometric authentication
    HapticFeedback.lightImpact();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: 'verified_user',
                color: AppTheme.onPrimaryLight,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text('Biometric authentication successful!'),
            ],
          ),
          backgroundColor: AppTheme.accentSuccess,
          behavior: SnackBarBehavior.floating,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 1000));
      Navigator.pushReplacementNamed(context, '/teacher-dashboard-screen');
    }
  }

  void _handleBackNavigation() {
    // Show confirmation dialog if user has entered credentials
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Go Back?',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to go back to role selection?',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
              ),
              child: Text('Go Back'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.backgroundLight,
                    AppTheme.primaryLight.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),

            // Main content
            SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    children: [
                      SizedBox(height: 4.h),

                      // App Logo Section
                      const AppLogoWidget(),
                      SizedBox(height: 6.h),

                      // Login Form Section
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppTheme.cardLight,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.shadowLight,
                              blurRadius: 12.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome Text
                            Text(
                              'Welcome Back!',
                              style: AppTheme.lightTheme.textTheme.headlineSmall
                                  ?.copyWith(
                                color: AppTheme.textPrimaryLight,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Sign in to access your teacher dashboard and manage exams.',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                            SizedBox(height: 4.h),

                            // Login Form
                            LoginFormWidget(
                              onLogin: _handleLogin,
                              isLoading: _isLoading,
                            ),

                            // Biometric Login Option
                            BiometricLoginWidget(
                              onBiometricLogin: _handleBiometricLogin,
                              isAvailable: _isBiometricAvailable,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),

                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New teacher? ',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.textSecondaryLight,
                            ),
                          ),
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () {
                                    // Navigate to teacher registration
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Registration feature coming soon!'),
                                        backgroundColor: AppTheme.primaryLight,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                            child: Text(
                              'Register here',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.primaryLight,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),

                      // Demo Credentials Info
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: AppTheme.primaryLight.withValues(alpha: 0.2),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'info',
                                  color: AppTheme.primaryLight,
                                  size: 20,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Demo Credentials',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelLarge
                                      ?.copyWith(
                                    color: AppTheme.primaryLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Email: teacher@safeexam.com\nPassword: teacher123',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.textSecondaryLight,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),

            // Back Button
            Positioned(
              top: 2.h,
              left: 4.w,
              child: GestureDetector(
                onTap: _isLoading ? null : _handleBackNavigation,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: AppTheme.cardLight,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowLight,
                        blurRadius: 8.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'arrow_back',
                      color: AppTheme.textPrimaryLight,
                      size: 6.w,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}