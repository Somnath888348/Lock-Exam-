import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExamDetailsFormWidget extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController examIdController;
  final bool isLoading;
  final VoidCallback onJoinExam;
  final Function(String) onNameChanged;
  final Function(String) onExamIdChanged;

  const ExamDetailsFormWidget({
    Key? key,
    required this.nameController,
    required this.examIdController,
    required this.isLoading,
    required this.onJoinExam,
    required this.onNameChanged,
    required this.onExamIdChanged,
  }) : super(key: key);

  @override
  State<ExamDetailsFormWidget> createState() => _ExamDetailsFormWidgetState();
}

class _ExamDetailsFormWidgetState extends State<ExamDetailsFormWidget> {
  String? _nameError;
  String? _examIdError;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    widget.nameController.addListener(_validateForm);
    widget.examIdController.addListener(_validateForm);
  }

  @override
  void dispose() {
    widget.nameController.removeListener(_validateForm);
    widget.examIdController.removeListener(_validateForm);
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _nameError = _validateName(widget.nameController.text);
      _examIdError = _validateExamId(widget.examIdController.text);
      _isFormValid = _nameError == null &&
          _examIdError == null &&
          widget.nameController.text.isNotEmpty &&
          widget.examIdController.text.isNotEmpty;
    });
  }

  String? _validateName(String value) {
    if (value.isEmpty) return null;
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? _validateExamId(String value) {
    if (value.isEmpty) return null;
    if (value.length < 6) {
      return 'Exam ID must be at least 6 characters';
    }
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value.toUpperCase())) {
      return 'Exam ID can only contain letters and numbers';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full Name Input Field
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 3.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: widget.nameController,
                enabled: !widget.isLoading,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                onChanged: widget.onNameChanged,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'person',
                      color: _nameError != null
                          ? AppTheme.lightTheme.colorScheme.error
                          : AppTheme.lightTheme.colorScheme.primary,
                      size: 6.w,
                    ),
                  ),
                  errorText: _nameError,
                  errorMaxLines: 2,
                ),
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),

        // Exam ID Input Field
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: widget.examIdController,
                enabled: !widget.isLoading,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                onChanged: widget.onExamIdChanged,
                decoration: InputDecoration(
                  labelText: 'Exam ID',
                  hintText: 'Enter exam ID',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'key',
                      color: _examIdError != null
                          ? AppTheme.lightTheme.colorScheme.error
                          : AppTheme.lightTheme.colorScheme.primary,
                      size: 6.w,
                    ),
                  ),
                  errorText: _examIdError,
                  errorMaxLines: 2,
                ),
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              SizedBox(height: 1.h),
              Text(
                'Get Exam ID from your teacher',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Join Exam Button
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 2.h),
          child: ElevatedButton(
            onPressed:
                _isFormValid && !widget.isLoading ? widget.onJoinExam : null,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.w),
              ),
            ),
            child: widget.isLoading
                ? SizedBox(
                    height: 6.w,
                    width: 6.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    'Join Exam',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
