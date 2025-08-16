import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/exam_timer_widget.dart';
import './widgets/question_display_widget.dart';
import './widgets/violation_warning_widget.dart';

class ExamTakingScreen extends StatefulWidget {
  const ExamTakingScreen({Key? key}) : super(key: key);

  @override
  State<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen>
    with WidgetsBindingObserver {
  // Exam Data
  final List<Map<String, dynamic>> _examQuestions = [
    {
      "id": 1,
      "question":
          "What is the primary function of the CPU in a computer system?",
      "options": [
        "To store data permanently",
        "To execute instructions and perform calculations",
        "To display graphics on the screen",
        "To connect to the internet"
      ],
      "correctAnswer": "To execute instructions and perform calculations",
      "type": "single"
    },
    {
      "id": 2,
      "question":
          "Which of the following are programming languages? (Select all that apply)",
      "options": ["Python", "HTML", "JavaScript", "CSS"],
      "correctAnswer": "Python",
      "type": "multiple"
    },
    {
      "id": 3,
      "question": "What does RAM stand for in computer terminology?",
      "options": [
        "Random Access Memory",
        "Read Access Memory",
        "Rapid Access Memory",
        "Remote Access Memory"
      ],
      "correctAnswer": "Random Access Memory",
      "type": "single"
    },
    {
      "id": 4,
      "question":
          "Which protocol is primarily used for secure web communication?",
      "options": ["HTTP", "HTTPS", "FTP", "SMTP"],
      "correctAnswer": "HTTPS",
      "type": "single"
    },
    {
      "id": 5,
      "question": "What is the time complexity of binary search algorithm?",
      "options": ["O(n)", "O(log n)", "O(n²)", "O(1)"],
      "correctAnswer": "O(log n)",
      "type": "single"
    }
  ];

  // Exam State
  int _currentQuestionIndex = 0;
  Map<int, String> _selectedAnswers = {};
  bool _isExamActive = true;
  bool _cameraActive = false;

  // Timer State
  final int _examDurationMinutes = 30;

  // Violation Tracking
  int _violationCount = 0;
  final int _maxViolations = 3;
  String? _currentViolation;
  bool _showViolationWarning = false;

  // App Lifecycle Monitoring
  bool _isAppInForeground = true;
  DateTime? _lastMinimizeTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeExam();
    _preventScreenshots();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        if (_isExamActive) {
          _isAppInForeground = false;
          _lastMinimizeTime = DateTime.now();
          _handleViolation('App Minimize');
        }
        break;
      case AppLifecycleState.resumed:
        if (_isExamActive && !_isAppInForeground) {
          _isAppInForeground = true;
          if (_lastMinimizeTime != null) {
            final minimizeDuration =
                DateTime.now().difference(_lastMinimizeTime!);
            if (minimizeDuration.inSeconds > 5) {
              _handleViolation('App Minimize');
            }
          }
        }
        break;
      default:
        break;
    }
  }

  void _initializeExam() {
    // Randomize questions and options
    _examQuestions.shuffle();
    for (var question in _examQuestions) {
      final options = List<String>.from(question['options']);
      options.shuffle();
      question['options'] = options;
    }

    // Set full screen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _preventScreenshots() {
    if (!kIsWeb) {
      // Prevent screenshots on mobile platforms
      try {
        SystemChrome.setApplicationSwitcherDescription(
          const ApplicationSwitcherDescription(
            label: 'SafeExam AI Proctor',
            primaryColor: 0xFF1E3A8A,
          ),
        );
      } catch (e) {
        // Handle screenshot prevention error silently
      }
    }
  }

  void _handleViolation(String violationType) {
    if (!_isExamActive) return;

    setState(() {
      _violationCount++;
      _currentViolation = violationType;
      _showViolationWarning = true;
    });

    if (_violationCount >= _maxViolations) {
      _terminateExam('Maximum violations reached');
    }
  }

  void _onCameraViolation(String violation) {
    _handleViolation(violation);
  }

  void _onCameraStatusChanged(bool isActive) {
    setState(() {
      _cameraActive = isActive;
    });

    if (!isActive && _isExamActive) {
      _handleViolation('Camera Access Lost');
    }
  }

  void _dismissViolationWarning() {
    setState(() {
      _showViolationWarning = false;
      _currentViolation = null;
    });
  }

  void _onAnswerSelected(String answer) {
    if (!_isExamActive) return;

    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answer;
    });
  }

  void _navigateToQuestion(int index) {
    if (!_isExamActive || index < 0 || index >= _examQuestions.length) return;

    setState(() {
      _currentQuestionIndex = index;
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _navigateToQuestion(_currentQuestionIndex - 1);
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _examQuestions.length - 1) {
      _navigateToQuestion(_currentQuestionIndex + 1);
    }
  }

  void _onTimeUp() {
    _terminateExam('Time expired');
  }

  void _submitExam() {
    _showSubmitConfirmation();
  }

  void _showSubmitConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'assignment_turned_in',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Submit Exam',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to submit your exam?',
              style: AppTheme.lightTheme.textTheme.bodyLarge,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Questions Answered:',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      Text(
                        '${_selectedAnswers.length}/${_examQuestions.length}',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Violations:',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      Text(
                        '$_violationCount/$_maxViolations',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _violationCount > 0
                              ? AppTheme.accentWarning
                              : AppTheme.accentSuccess,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'This action cannot be undone.',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
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
              _terminateExam('Submitted by user');
            },
            child: Text('Submit Exam'),
          ),
        ],
      ),
    );
  }

  void _terminateExam(String reason) {
    setState(() {
      _isExamActive = false;
    });

    // Save exam data with encryption
    _saveExamData(reason);

    // Show completion dialog
    _showExamCompletionDialog(reason);
  }

  void _saveExamData(String reason) {
    final examData = {
      'examId': 'EXAM_001',
      'studentName': 'John Doe',
      'submissionTime': DateTime.now().toIso8601String(),
      'reason': reason,
      'answers': _selectedAnswers,
      'violations': _violationCount,
      'duration': _examDurationMinutes,
      'watermark':
          'SafeExam_AI_Proctor_${DateTime.now().millisecondsSinceEpoch}',
    };

    // In a real app, this would be encrypted and stored securely
    final jsonData = jsonEncode(examData);
    debugPrint('Exam data saved: $jsonData');
  }

  void _showExamCompletionDialog(String reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: reason.contains('violation') ||
                      reason.contains('Time expired')
                  ? 'error'
                  : 'check_circle',
              color: reason.contains('violation') ||
                      reason.contains('Time expired')
                  ? AppTheme.accentError
                  : AppTheme.accentSuccess,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Exam Completed',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your exam has been completed and submitted.',
              style: AppTheme.lightTheme.textTheme.bodyLarge,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                border: Border.all(color: AppTheme.borderLight),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Reason:',
                          style: AppTheme.lightTheme.textTheme.bodyMedium),
                      Text(
                        reason,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Questions Answered:',
                          style: AppTheme.lightTheme.textTheme.bodyMedium),
                      Text(
                        '${_selectedAnswers.length}/${_examQuestions.length}',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(
                  context, '/student-name-entry-screen');
            },
            child: Text('Return to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isExamActive) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.primaryColor,
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        _handleViolation('Navigation Attempt');
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              // Main Content
              Column(
                children: [
                  // Top Bar
                  Container(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      children: [
                        // Camera Preview
                        CameraPreviewWidget(
                          onViolationDetected: _onCameraViolation,
                          onCameraStatusChanged: _onCameraStatusChanged,
                        ),

                        Spacer(),

                        // Timer
                        ExamTimerWidget(
                          totalMinutes: _examDurationMinutes,
                          onTimeUp: _onTimeUp,
                        ),
                      ],
                    ),
                  ),

                  // Question Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: QuestionDisplayWidget(
                        question: _examQuestions[_currentQuestionIndex],
                        currentQuestionIndex: _currentQuestionIndex,
                        totalQuestions: _examQuestions.length,
                        selectedAnswer: _selectedAnswers[_currentQuestionIndex],
                        onAnswerSelected: _onAnswerSelected,
                      ),
                    ),
                  ),

                  // Navigation Bar
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowLight,
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Previous Button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _currentQuestionIndex > 0
                                ? _previousQuestion
                                : null,
                            icon: CustomIconWidget(
                              iconName: 'arrow_back',
                              color: _currentQuestionIndex > 0
                                  ? AppTheme.lightTheme.primaryColor
                                  : AppTheme.textDisabledLight,
                              size: 18,
                            ),
                            label: Text('Previous'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                            ),
                          ),
                        ),

                        SizedBox(width: 4.w),

                        // Next/Submit Button
                        Expanded(
                          child:
                              _currentQuestionIndex == _examQuestions.length - 1
                                  ? ElevatedButton.icon(
                                      onPressed: _submitExam,
                                      icon: CustomIconWidget(
                                        iconName: 'assignment_turned_in',
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      label: Text('Submit Exam'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.accentSuccess,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 2.h),
                                      ),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: _nextQuestion,
                                      icon: CustomIconWidget(
                                        iconName: 'arrow_forward',
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      label: Text('Next'),
                                      style: ElevatedButton.styleFrom(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 2.h),
                                      ),
                                    ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Violation Warning Overlay
              if (_showViolationWarning && _currentViolation != null)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.7),
                    child: Center(
                      child: ViolationWarningWidget(
                        violationType: _currentViolation!,
                        warningCount: _violationCount,
                        maxWarnings: _maxViolations,
                        onDismiss: _dismissViolationWarning,
                        onExamTerminate: () =>
                            _terminateExam('User terminated exam'),
                      ),
                    ),
                  ),
                ),

              // Camera Status Indicator
              if (!_cameraActive)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.accentError,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'camera_alt',
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'Camera monitoring is required for this exam',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
