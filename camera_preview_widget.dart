import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class CameraPreviewWidget extends StatefulWidget {
  final Function(String) onViolationDetected;
  final Function(bool) onCameraStatusChanged;

  const CameraPreviewWidget({
    Key? key,
    required this.onViolationDetected,
    required this.onCameraStatusChanged,
  }) : super(key: key);

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _hasPermission = false;
  String _aiStatus = 'normal'; // normal, warning, violation
  int _faceCount = 0;
  bool _externalDeviceDetected = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      _hasPermission = await _requestCameraPermission();
      if (!_hasPermission) {
        widget.onCameraStatusChanged(false);
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        widget.onCameraStatusChanged(false);
        return;
      }

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
          camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        widget.onCameraStatusChanged(true);
        _startAIMonitoring();
      }
    } catch (e) {
      widget.onCameraStatusChanged(false);
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {
      // Ignore focus mode errors on web
    }

    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.off);
      } catch (e) {
        // Ignore flash mode errors
      }
    }
  }

  void _startAIMonitoring() {
    // Simulate AI monitoring with periodic checks
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _performAIAnalysis();
      }
    });
  }

  void _performAIAnalysis() {
    if (!mounted ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return;
    }

    // Simulate AI analysis results
    final now = DateTime.now();
    final random = now.millisecond % 100;

    // Simulate face detection (90% chance of 1 face, 8% chance of multiple, 2% chance of none)
    if (random < 90) {
      _faceCount = 1;
      _aiStatus = 'normal';
    } else if (random < 98) {
      _faceCount = random < 94 ? 2 : 3;
      _aiStatus = 'violation';
      widget.onViolationDetected('Multiple faces detected: $_faceCount faces');
    } else {
      _faceCount = 0;
      _aiStatus = 'warning';
      widget.onViolationDetected('No face detected in camera');
    }

    // Simulate external device detection (5% chance)
    if (random < 5) {
      _externalDeviceDetected = true;
      _aiStatus = 'violation';
      widget.onViolationDetected('External device detected in camera view');
    } else {
      _externalDeviceDetected = false;
    }

    if (mounted) {
      setState(() {});
    }

    // Continue monitoring
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _performAIAnalysis();
      }
    });
  }

  Color _getStatusColor() {
    switch (_aiStatus) {
      case 'normal':
        return AppTheme.accentSuccess;
      case 'warning':
        return AppTheme.accentWarning;
      case 'violation':
        return AppTheme.accentError;
      default:
        return AppTheme.accentSuccess;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25.w,
      height: 20.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            if (_isInitialized && _cameraController != null)
              SizedBox.expand(
                child: CameraPreview(_cameraController!),
              )
            else
              Container(
                color: AppTheme.lightTheme.colorScheme.surface,
                child: Center(
                  child: _hasPermission
                      ? CircularProgressIndicator(
                          color: AppTheme.lightTheme.primaryColor,
                          strokeWidth: 2,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'camera_alt',
                              color: AppTheme.textSecondaryLight,
                              size: 24,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Camera\nAccess\nRequired',
                              textAlign: TextAlign.center,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                fontSize: 8.sp,
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

            // AI Status Indicator
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor().withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),

            // Face Count Indicator
            if (_isInitialized && _faceCount > 0)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface
                        .withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_faceCount',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w600,
                      color: _faceCount == 1
                          ? AppTheme.accentSuccess
                          : AppTheme.accentError,
                    ),
                  ),
                ),
              ),

            // External Device Warning
            if (_externalDeviceDetected)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentError,
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'warning',
                    color: Colors.white,
                    size: 8,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
