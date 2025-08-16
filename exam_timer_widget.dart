import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ExamTimerWidget extends StatefulWidget {
  final int totalMinutes;
  final Function() onTimeUp;

  const ExamTimerWidget({
    Key? key,
    required this.totalMinutes,
    required this.onTimeUp,
  }) : super(key: key);

  @override
  State<ExamTimerWidget> createState() => _ExamTimerWidgetState();
}

class _ExamTimerWidgetState extends State<ExamTimerWidget> {
  late Timer _timer;
  late int _remainingSeconds;
  bool _isWarning = false;
  bool _isCritical = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalMinutes * 60;
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          _updateWarningStates();
        });
      } else {
        _timer.cancel();
        widget.onTimeUp();
      }
    });
  }

  void _updateWarningStates() {
    final totalSeconds = widget.totalMinutes * 60;
    final warningThreshold = totalSeconds * 0.2; // 20% remaining
    final criticalThreshold = totalSeconds * 0.05; // 5% remaining

    _isWarning = _remainingSeconds <= warningThreshold &&
        _remainingSeconds > criticalThreshold;
    _isCritical = _remainingSeconds <= criticalThreshold;
  }

  String _formatTime() {
    final hours = _remainingSeconds ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final seconds = _remainingSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  Color _getTimerColor() {
    if (_isCritical) {
      return AppTheme.accentError;
    } else if (_isWarning) {
      return AppTheme.accentWarning;
    } else {
      return AppTheme.lightTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getTimerColor(),
          width: _isCritical ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getTimerColor().withValues(alpha: 0.2),
            blurRadius: _isCritical ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'timer',
            color: _getTimerColor(),
            size: 18,
          ),
          SizedBox(width: 2.w),
          Text(
            _formatTime(),
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: _getTimerColor(),
              fontWeight: FontWeight.w600,
              fontSize: _isCritical ? 16.sp : 14.sp,
            ),
          ),
          if (_isCritical) ...[
            SizedBox(width: 1.w),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.accentError,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
