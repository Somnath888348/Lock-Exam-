import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/camera_explanation_widget.dart';
import './widgets/camera_permission_header_widget.dart';
import './widgets/camera_test_widget.dart';
import './widgets/permission_info_widget.dart';
import './widgets/troubleshooting_widget.dart';

class CameraPermissionScreen extends StatefulWidget {
  const CameraPermissionScreen({Key? key}) : super(key: key);

  @override
  State<CameraPermissionScreen> createState() => _CameraPermissionScreenState();
}

class _CameraPermissionScreenState extends State<CameraPermissionScreen> {
  bool _permissionGranted = false;
  bool _showCameraTest = false;
  bool _cameraTestPassed = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkExistingPermission();
  }

  Future<void> _checkExistingPermission() async {
    if (kIsWeb) {
      setState(() {
        _permissionGranted = true;
      });
      return;
    }

    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        _permissionGranted = true;
      });
    }
  }

  Future<void> _requestCameraPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (kIsWeb) {
        setState(() {
          _permissionGranted = true;
          _showCameraTest = true;
          _isLoading = false;
        });
        return;
      }

      final status = await Permission.camera.request();

      if (status.isGranted) {
        setState(() {
          _permissionGranted = true;
          _showCameraTest = true;
        });
      } else if (status.isPermanentlyDenied) {
        _showSettingsDialog();
      } else {
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      _showErrorDialog(
          'Failed to request camera permission. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Camera Permission Required',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Camera access has been permanently denied. Please enable it in Settings to continue with the exam.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Camera Access Denied',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Camera access is required for AI proctoring. Please grant permission to continue.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Try Again',
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Error',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.accentError,
            ),
          ),
          content: Text(
            message,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _onCameraTestSuccess() {
    setState(() {
      _cameraTestPassed = true;
    });
  }

  void _continueToExam() {
    Navigator.pushNamed(context, '/exam-taking-screen');
  }

  void _showBackConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Leave Camera Setup?',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'You need to complete camera setup to take the exam. Are you sure you want to go back?',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Stay',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
              child: Text(
                'Go Back',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.accentError,
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
    return WillPopScope(
      onWillPop: () async {
        _showBackConfirmation();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Column(
          children: [
            const CameraPermissionHeaderWidget(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    if (!_showCameraTest) ...[
                      SizedBox(height: 2.h),
                      const CameraExplanationWidget(),
                      SizedBox(height: 3.h),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        child: ElevatedButton(
                          onPressed:
                              _isLoading ? null : _requestCameraPermission,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 5.w,
                                  width: 5.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.lightTheme.colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'camera_alt',
                                      color: AppTheme
                                          .lightTheme.colorScheme.onPrimary,
                                      size: 5.w,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      'Enable Camera',
                                      style: AppTheme
                                          .lightTheme.textTheme.labelLarge
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      const PermissionInfoWidget(),
                      SizedBox(height: 3.h),
                      const TroubleshootingWidget(),
                    ] else ...[
                      SizedBox(height: 2.h),
                      CameraTestWidget(
                        onTestSuccess: _onCameraTestSuccess,
                      ),
                      if (_cameraTestPassed) ...[
                        SizedBox(height: 3.h),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                          child: ElevatedButton(
                            onPressed: _continueToExam,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              backgroundColor: AppTheme.accentSuccess,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'arrow_forward',
                                  color: Colors.white,
                                  size: 5.w,
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  'Continue to Exam',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelLarge
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
