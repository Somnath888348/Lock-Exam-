import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ViolationWarningWidget extends StatefulWidget {
  final String violationType;
  final int warningCount;
  final int maxWarnings;
  final Function() onDismiss;
  final Function() onExamTerminate;

  const ViolationWarningWidget({
    Key? key,
    required this.violationType,
    required this.warningCount,
    required this.maxWarnings,
    required this.onDismiss,
    required this.onExamTerminate,
  }) : super(key: key);

  @override
  State<ViolationWarningWidget> createState() => _ViolationWarningWidgetState();
}

class _ViolationWarningWidgetState extends State<ViolationWarningWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getViolationMessage() {
    switch (widget.violationType.toLowerCase()) {
      case 'multiple faces':
        return 'Multiple faces detected in camera view. Only one person should be visible during the exam.';
      case 'no face':
        return 'No face detected in camera view. Please ensure you are visible to the camera.';
      case 'external device':
        return 'External device detected in camera view. Remove all unauthorized devices.';
      case 'app minimize':
        return 'Attempt to minimize app detected. Stay in the exam application.';
      case 'screenshot':
        return 'Screenshot attempt detected. Screenshots are not allowed during the exam.';
      default:
        return 'Suspicious activity detected. Please follow exam guidelines.';
    }
  }

  IconData _getViolationIcon() {
    switch (widget.violationType.toLowerCase()) {
      case 'multiple faces':
        return Icons.group;
      case 'no face':
        return Icons.face_retouching_off;
      case 'external device':
        return Icons.devices;
      case 'app minimize':
        return Icons.fullscreen_exit;
      case 'screenshot':
        return Icons.screenshot;
      default:
        return Icons.warning;
    }
  }

  Color _getSeverityColor() {
    final remainingWarnings = widget.maxWarnings - widget.warningCount;
    if (remainingWarnings <= 1) {
      return AppTheme.accentError;
    } else if (remainingWarnings <= 2) {
      return AppTheme.accentWarning;
    } else {
      return AppTheme.accentWarning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingWarnings = widget.maxWarnings - widget.warningCount;
    final isLastWarning = remainingWarnings <= 1;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              margin: EdgeInsets.all(4.w),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getSeverityColor(),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getSeverityColor().withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getSeverityColor().withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getViolationIcon(),
                          color: _getSeverityColor(),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLastWarning
                                  ? 'FINAL WARNING'
                                  : 'VIOLATION DETECTED',
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                color: _getSeverityColor(),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Warning ${widget.warningCount} of ${widget.maxWarnings}',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onDismiss,
                        icon: Icon(
                          Icons.close,
                          color: AppTheme.textSecondaryLight,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Violation Message
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: _getSeverityColor().withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getViolationMessage(),
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Warning Progress
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: widget.warningCount / widget.maxWarnings,
                          backgroundColor: AppTheme.borderLight,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              _getSeverityColor()),
                          minHeight: 6,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        '$remainingWarnings left',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: _getSeverityColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  if (isLastWarning) ...[
                    SizedBox(height: 3.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.accentError.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.accentError.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppTheme.accentError,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'Next violation will terminate your exam automatically',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.accentError,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 3.h),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onDismiss,
                          style: OutlinedButton.styleFrom(
                            side:
                                BorderSide(color: AppTheme.textSecondaryLight),
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                          ),
                          child: Text(
                            'I Understand',
                            style: AppTheme.lightTheme.textTheme.labelLarge
                                ?.copyWith(
                              color: AppTheme.textSecondaryLight,
                            ),
                          ),
                        ),
                      ),
                      if (isLastWarning) ...[
                        SizedBox(width: 3.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onExamTerminate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentError,
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                            ),
                            child: Text(
                              'End Exam',
                              style: AppTheme.lightTheme.textTheme.labelLarge
                                  ?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
