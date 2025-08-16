import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class BiometricLoginWidget extends StatefulWidget {
  final VoidCallback? onBiometricLogin;
  final bool isAvailable;

  const BiometricLoginWidget({
    Key? key,
    this.onBiometricLogin,
    required this.isAvailable,
  }) : super(key: key);

  @override
  State<BiometricLoginWidget> createState() => _BiometricLoginWidgetState();
}

class _BiometricLoginWidgetState extends State<BiometricLoginWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleBiometricAuth() async {
    if (!widget.isAvailable || _isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Simulate biometric authentication
      await Future.delayed(const Duration(milliseconds: 1500));

      // Mock successful authentication
      if (mounted) {
        HapticFeedback.mediumImpact();
        widget.onBiometricLogin?.call();
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric authentication failed. Please try again.'),
            backgroundColor: AppTheme.accentError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAvailable) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: 3.h),

        // Divider with "OR" text
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1.0,
                color: AppTheme.borderLight,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'OR',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1.0,
                color: AppTheme.borderLight,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),

        // Biometric Login Button
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTap: _handleBiometricAuth,
                child: Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    color: _isAuthenticating
                        ? AppTheme.primaryLight.withValues(alpha: 0.1)
                        : AppTheme.cardLight,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: _isAuthenticating
                          ? AppTheme.primaryLight
                          : AppTheme.borderLight,
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowLight,
                        blurRadius: 8.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isAuthenticating
                      ? Center(
                          child: SizedBox(
                            width: 6.w,
                            height: 6.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryLight,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: CustomIconWidget(
                            iconName: 'fingerprint',
                            color: AppTheme.primaryLight,
                            size: 8.w,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 2.h),

        // Biometric Login Text
        Text(
          _isAuthenticating ? 'Authenticating...' : 'Use Biometric Login',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: _isAuthenticating
                ? AppTheme.primaryLight
                : AppTheme.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),

        // Instruction Text
        if (!_isAuthenticating)
          Text(
            'Touch the fingerprint sensor or use Face ID',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textDisabledLight,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}