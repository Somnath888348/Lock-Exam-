import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/error_message_widget.dart';
import './widgets/exam_details_form_widget.dart';
import './widgets/offline_indicator_widget.dart';

class StudentNameEntryScreen extends StatefulWidget {
  const StudentNameEntryScreen({Key? key}) : super(key: key);

  @override
  State<StudentNameEntryScreen> createState() => _StudentNameEntryScreenState();
}

class _StudentNameEntryScreenState extends State<StudentNameEntryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _examIdController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _examIdFocusNode = FocusNode();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isOffline = false;

  // Mock exam data for validation
  final List<Map<String, dynamic>> _mockExams = [
    {
      "examId": "MATH2024",
      "examName": "Mathematics Final Exam",
      "isActive": true,
      "startTime": DateTime.now().subtract(const Duration(minutes: 30)),
      "endTime": DateTime.now().add(const Duration(hours: 2)),
    },
    {
      "examId": "ENG2024",
      "examName": "English Literature Exam",
      "isActive": true,
      "startTime": DateTime.now().subtract(const Duration(minutes: 15)),
      "endTime": DateTime.now().add(const Duration(hours: 1, minutes: 30)),
    },
    {
      "examId": "SCI2024",
      "examName": "Science Comprehensive Test",
      "isActive": false,
      "startTime": DateTime.now().add(const Duration(hours: 1)),
      "endTime": DateTime.now().add(const Duration(hours: 3)),
    },
    {
      "examId": "HIST2024",
      "examName": "History Final Assessment",
      "isActive": true,
      "startTime": DateTime.now().subtract(const Duration(hours: 2)),
      "endTime": DateTime.now().subtract(const Duration(minutes: 30)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedName();
    _checkConnectivity();
    _setupConnectivityListener();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _examIdController.dispose();
    _nameFocusNode.dispose();
    _examIdFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSavedName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('student_name');
      if (savedName != null && savedName.isNotEmpty) {
        setState(() {
          _nameController.text = savedName;
        });
      }
    } catch (e) {
      // Silent fail - not critical functionality
    }
  }

  Future<void> _saveStudentName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('student_name', name.trim());
    } catch (e) {
      // Silent fail - not critical functionality
    }
  }

  void _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = connectivityResult == ConnectivityResult.none;
    });
  }

  void _setupConnectivityListener() {
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
    });
  }

  Future<Map<String, dynamic>?> _validateExamId(String examId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final exam = _mockExams.firstWhere(
      (exam) =>
          (exam["examId"] as String).toUpperCase() == examId.toUpperCase(),
      orElse: () => {},
    );

    if (exam.isEmpty) {
      throw Exception('Invalid exam ID. Please check with your teacher.');
    }

    final now = DateTime.now();
    final startTime = exam["startTime"] as DateTime;
    final endTime = exam["endTime"] as DateTime;

    if (now.isBefore(startTime)) {
      throw Exception(
          'Exam has not started yet. Please wait until ${_formatTime(startTime)}.');
    }

    if (now.isAfter(endTime)) {
      throw Exception('Exam has ended. Contact your teacher for assistance.');
    }

    if (!(exam["isActive"] as bool)) {
      throw Exception(
          'Exam is currently inactive. Please contact your teacher.');
    }

    return exam;
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleJoinExam() async {
    if (_isOffline) {
      setState(() {
        _errorMessage =
            'Internet connection required to join exam. Please check your network.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Save student name for convenience
      await _saveStudentName(_nameController.text);

      // Validate exam ID
      final examData = await _validateExamId(_examIdController.text);

      if (examData != null) {
        // Provide haptic feedback on success
        HapticFeedback.lightImpact();

        // Navigate to camera permission screen
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/camera-permission-screen',
            arguments: {
              'studentName': _nameController.text.trim(),
              'examId': _examIdController.text.toUpperCase(),
              'examData': examData,
            },
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      HapticFeedback.heavyImpact();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleNameChanged(String value) {
    setState(() {
      _errorMessage = null;
    });
  }

  void _handleExamIdChanged(String value) {
    setState(() {
      _errorMessage = null;
    });
  }

  void _handleRetry() {
    setState(() {
      _errorMessage = null;
    });
    _handleJoinExam();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Enter Exam Details',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.appBarTheme.iconTheme?.color ??
                AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        surfaceTintColor: AppTheme.lightTheme.appBarTheme.surfaceTintColor,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),

                  // Welcome Text
                  Text(
                    'Welcome Student',
                    style:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Please enter your details to join the exam securely',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Offline Indicator
                  OfflineIndicatorWidget(isOffline: _isOffline),

                  // Error Message
                  ErrorMessageWidget(
                    errorMessage: _errorMessage,
                    onRetry: _errorMessage?.contains('network') == true ||
                            _errorMessage?.contains('connection') == true
                        ? _handleRetry
                        : null,
                  ),

                  // Form
                  ExamDetailsFormWidget(
                    nameController: _nameController,
                    examIdController: _examIdController,
                    isLoading: _isLoading,
                    onJoinExam: _handleJoinExam,
                    onNameChanged: _handleNameChanged,
                    onExamIdChanged: _handleExamIdChanged,
                  ),

                  SizedBox(height: 4.h),

                  // Security Notice
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(3.w),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.2),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomIconWidget(
                          iconName: 'security',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 5.w,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Secure Exam Environment',
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                'Your exam session will be monitored by AI to ensure academic integrity.',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 6.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}