import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class CameraTestWidget extends StatefulWidget {
  final VoidCallback onTestSuccess;

  const CameraTestWidget({
    Key? key,
    required this.onTestSuccess,
  }) : super(key: key);

  @override
  State<CameraTestWidget> createState() => _CameraTestWidgetState();
}

class _CameraTestWidgetState extends State<CameraTestWidget> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _hasPermission = false;
  bool _faceDetected = false;
  bool _multipleFaces = false;
  bool _externalDevice = false;
  String _statusMessage = 'Initializing camera...';

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
    setState(() {
      _isLoading = true;
      _statusMessage = 'Requesting camera permission...';
    });

    try {
      _hasPermission = await _requestCameraPermission();

      if (!_hasPermission) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Camera permission denied';
        });
        return;
      }

      setState(() {
        _statusMessage = 'Setting up camera...';
      });

      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'No camera found on device';
        });
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
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      setState(() {
        _isInitialized = true;
        _isLoading = false;
        _statusMessage = 'Camera ready - Testing AI detection...';
      });

      _startAIDetectionSimulation();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Camera setup failed. Please try again.';
      });
    }
  }

  void _startAIDetectionSimulation() {
    // Simulate AI detection process
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _faceDetected = true;
          _statusMessage = 'Single face detected ✓';
        });
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _statusMessage = 'Checking for multiple faces...';
        });
      }
    });

    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _multipleFaces = false;
          _statusMessage = 'No multiple faces detected ✓';
        });
      }
    });

    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _externalDevice = false;
          _statusMessage = 'Camera Test Successful';
        });
        widget.onTestSuccess();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _buildCameraPreview(),
            ),
          ),
          SizedBox(height: 3.h),
          _buildDetectionIndicators(),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: _statusMessage == 'Camera Test Successful'
                  ? AppTheme.accentSuccess.withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _statusMessage == 'Camera Test Successful'
                    ? AppTheme.accentSuccess.withValues(alpha: 0.3)
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (_isLoading)
                  SizedBox(
                    width: 5.w,
                    height: 5.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  )
                else if (_statusMessage == 'Camera Test Successful')
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.accentSuccess,
                    size: 5.w,
                  )
                else
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: _statusMessage == 'Camera Test Successful'
                          ? AppTheme.accentSuccess
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: _statusMessage == 'Camera Test Successful'
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Setting up camera...',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'camera_alt',
              color: AppTheme.lightTheme.colorScheme.outline,
              size: 15.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'Camera permission required',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _cameraController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'camera_alt',
              color: AppTheme.lightTheme.colorScheme.outline,
              size: 15.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'Camera not available',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CameraPreview(_cameraController!),
        ),
        if (_faceDetected)
          Positioned(
            top: 4.w,
            left: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.accentSuccess.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'face',
                    color: Colors.white,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Face Detected',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetectionIndicators() {
    return Row(
      children: [
        Expanded(
          child: _buildIndicator(
            'Single Face',
            _faceDetected,
            'person',
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: _buildIndicator(
            'No Multiple Faces',
            !_multipleFaces && _faceDetected,
            'group',
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: _buildIndicator(
            'No External Device',
            !_externalDevice && _faceDetected,
            'devices',
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator(String label, bool isValid, String iconName) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: isValid
            ? AppTheme.accentSuccess.withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid
              ? AppTheme.accentSuccess.withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: isValid ? 'check_circle' : iconName,
            color: isValid
                ? AppTheme.accentSuccess
                : AppTheme.lightTheme.colorScheme.outline,
            size: 5.w,
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: isValid
                  ? AppTheme.accentSuccess
                  : AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: isValid ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
