import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ImageUploadTabWidget extends StatefulWidget {
  final Function(List<int> fileBytes, String fileName, String difficulty,
      int questionCount, String subject) onGenerate;
  final bool isGenerating;

  const ImageUploadTabWidget({
    Key? key,
    required this.onGenerate,
    required this.isGenerating,
  }) : super(key: key);

  @override
  State<ImageUploadTabWidget> createState() => _ImageUploadTabWidgetState();
}

class _ImageUploadTabWidgetState extends State<ImageUploadTabWidget> {
  List<int>? _selectedFileBytes;
  String? _selectedFileName;
  String _selectedDifficulty = 'Medium';
  int _questionCount = 5;
  String _selectedSubject = 'General';
  bool _isProcessing = false;

  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];
  final List<String> _subjects = [
    'General',
    'Mathematics',
    'Science',
    'History',
    'Geography',
    'Literature',
    'Computer Science',
    'Physics',
    'Chemistry',
    'Biology'
  ];

  Future<void> _pickFile() async {
    try {
      setState(() => _isProcessing = true);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        List<int>? bytes;

        if (kIsWeb) {
          bytes = file.bytes;
        } else {
          if (file.path != null) {
            bytes = await File(file.path!).readAsBytes();
          }
        }

        if (bytes != null) {
          setState(() {
            _selectedFileBytes = bytes;
            _selectedFileName = file.name;
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick file. Please try again.');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _captureImage() async {
    try {
      setState(() => _isProcessing = true);

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        List<int> bytes = await image.readAsBytes();
        setState(() {
          _selectedFileBytes = bytes;
          _selectedFileName = image.name;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture image. Please try again.');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFileBytes = null;
      _selectedFileName = null;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
      ),
    );
  }

  String _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return 'picture_as_pdf';
      case 'doc':
      case 'docx':
        return 'description';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'image';
      default:
        return 'insert_drive_file';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upload Section
          Text(
            'Upload File',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Upload Area
          _selectedFileBytes == null
              ? Container(
                  width: double.infinity,
                  height: 25.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline,
                      width: 2.0,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                    color: AppTheme.lightTheme.colorScheme.surface,
                  ),
                  child: _isProcessing
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Processing file...',
                                style: AppTheme.lightTheme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'cloud_upload',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 48,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Drag & drop files here',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Supports: JPG, PNG, PDF, DOC, DOCX',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _pickFile,
                                  icon: CustomIconWidget(
                                    iconName: 'folder_open',
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  label: Text('Browse Files'),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 1.5.h,
                                    ),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: _captureImage,
                                  icon: CustomIconWidget(
                                    iconName: 'camera_alt',
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  label: Text('Camera'),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.w,
                                      vertical: 1.5.h,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                )
              : Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.05),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: CustomIconWidget(
                          iconName: _getFileIcon(_selectedFileName!),
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFileName!,
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              '${(_selectedFileBytes!.length / 1024).toStringAsFixed(1)} KB',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _removeFile,
                        icon: CustomIconWidget(
                          iconName: 'close',
                          color: AppTheme.lightTheme.colorScheme.error,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
          SizedBox(height: 3.h),

          // Difficulty Level Section
          Text(
            'Difficulty Level',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDifficulty,
                isExpanded: true,
                items: _difficulties.map((String difficulty) {
                  return DropdownMenuItem<String>(
                    value: difficulty,
                    child: Text(
                      difficulty,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedDifficulty = newValue;
                    });
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Subject Category Section
          Text(
            'Subject Category',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSubject,
                isExpanded: true,
                items: _subjects.map((String subject) {
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(
                      subject,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedSubject = newValue;
                    });
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Question Count Section
          Text(
            'Number of Questions: $_questionCount',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.lightTheme.colorScheme.primary,
              thumbColor: AppTheme.lightTheme.colorScheme.primary,
              overlayColor: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.2),
              inactiveTrackColor: AppTheme.lightTheme.colorScheme.outline,
              trackHeight: 4.0,
            ),
            child: Slider(
              value: _questionCount.toDouble(),
              min: 1,
              max: 20,
              divisions: 19,
              label: _questionCount.toString(),
              onChanged: (double value) {
                setState(() {
                  _questionCount = value.round();
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              Text(
                '20',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // Generate Button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: widget.isGenerating || _selectedFileBytes == null
                  ? null
                  : () {
                      widget.onGenerate(
                        _selectedFileBytes!,
                        _selectedFileName!,
                        _selectedDifficulty,
                        _questionCount,
                        _selectedSubject,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
                disabledBackgroundColor:
                    AppTheme.lightTheme.colorScheme.outline,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: widget.isGenerating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          'Processing & Generating...',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'auto_awesome',
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Generate Questions',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
