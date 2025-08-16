import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/exam_timer_widget.dart';
import './widgets/question_display_widget.dart';
import './widgets/question_progress_widget.dart';
import './widgets/security_warning_overlay.dart';

class StudentExamInterfaceScreen extends StatefulWidget {
  const StudentExamInterfaceScreen({Key? key}) : super(key: key);

  @override
  State<StudentExamInterfaceScreen> createState() =>
      _StudentExamInterfaceScreenState();
}

class _StudentExamInterfaceScreenState extends State<StudentExamInterfaceScreen>
    with WidgetsBindingObserver {
  // Exam state variables
  int _currentQuestionIndex = 0;
  Map<int, String> _selectedAnswers = {};
  bool _isExamActive = true;
  bool _faceDetected = true;
  bool _multipleFacesDetected = false;
  bool _showSecurityWarning = false;
  String _warningMessage = '';
  String _warningType = '';
  Timer? _faceAbsenceTimer;

  // Mock exam data
  final List<Map<String, dynamic>> _examQuestions = [
    {
      "id": 1,
      "question": "What is the capital of France?",
      "options": ["London", "Berlin", "Paris", "Madrid"],
      "correctAnswer": "Paris"
    },
    {
      "id": 2,
      "question": "Which planet is known as the Red Planet?",
      "options": ["Venus", "Mars", "Jupiter", "Saturn"],
      "correctAnswer": "Mars"
    },
    {
      "id": 3,
      "question": "What is the largest mammal in the world?",
      "options": ["African Elephant", "Blue Whale", "Giraffe", "Hippopotamus"],
      "correctAnswer": "Blue Whale"
    },
    {
      "id": 4,
      "question": "In which year did World War II end?",
      "options": ["1944", "1945", "1946", "1947"],
      "correctAnswer": "1945"
    },
    {
      "id": 5,
      "question": "What is the chemical symbol for gold?",
      "options": ["Go", "Gd", "Au", "Ag"],
      "correctAnswer": "Au"
    },
    {
      "id": 6,
      "question": "Who wrote the novel '1984'?",
      "options": [
        "Aldous Huxley",
        "George Orwell",
        "Ray Bradbury",
        "H.G. Wells"
      ],
      "correctAnswer": "George Orwell"
    },
    {
      "id": 7,
      "question": "What is the smallest unit of matter?",
      "options": ["Molecule", "Atom", "Proton", "Electron"],
      "correctAnswer": "Atom"
    },
    {
      "id": 8,
      "question":
          "Which programming language is known for its use in artificial intelligence?",
      "options": ["Java", "C++", "Python", "JavaScript"],
      "correctAnswer": "Python"
    },
    {
      "id": 9,
      "question": "What is the speed of light in vacuum?",
      "options": [
        "299,792,458 m/s",
        "300,000,000 m/s",
        "299,000,000 m/s",
        "298,792,458 m/s"
      ],
      "correctAnswer": "299,792,458 m/s"
    },
    {
      "id": 10,
      "question": "Who painted the Mona Lisa?",
      "options": [
        "Vincent van Gogh",
        "Pablo Picasso",
        "Leonardo da Vinci",
        "Michelangelo"
      ],
      "correctAnswer": "Leonardo da Vinci"
    }
  ];

  final Map<String, dynamic> _examInfo = {
    "examName": "General Knowledge Test",
    "duration": 30, // minutes
    "studentName": "John Doe",
    "examId": "GK2025001",
    "teacherWatermark": "Prof. Sarah Wilson - SafeExam AI"
  };

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
    _faceAbsenceTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _handleAppMinimization();
    }
  }

  void _initializeExam() {
    // Randomize questions and options
    _examQuestions.shuffle(Random());
    for (var question in _examQuestions) {
      final options = (question['options'] as List).cast<String>();
      options.shuffle(Random());
      question['options'] = options;
    }
  }

  void _preventScreenshots() {
    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  void _handleAppMinimization() {
    if (_isExamActive) {
      _terminateExam(
          'App minimization detected. Exam terminated for security reasons.');
    }
  }

  void _onFaceDetectionChanged(bool detected) {
    setState(() {
      _faceDetected = detected;
    });

    if (!detected) {
      _faceAbsenceTimer = Timer(const Duration(seconds: 10), () {
        if (!_faceDetected && _isExamActive) {
          _terminateExam(
              'Face not detected for extended period. Exam terminated.');
        }
      });
    } else {
      _faceAbsenceTimer?.cancel();
    }
  }

  void _onMultipleFacesDetected(bool detected) {
    setState(() {
      _multipleFacesDetected = detected;
    });

    if (detected) {
      _showWarning('multiple_faces',
          'Multiple faces detected. Please ensure you are alone during the exam.');
    }
  }

  void _showWarning(String type, String message) {
    setState(() {
      _showSecurityWarning = true;
      _warningType = type;
      _warningMessage = message;
    });
  }

  void _dismissWarning() {
    setState(() {
      _showSecurityWarning = false;
    });
  }

  void _terminateExam(String reason) {
    setState(() {
      _isExamActive = false;
    });

    _saveExamResults();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Exam Terminated'),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(
                  context, '/student-results-screen');
            },
            child: Text('View Results'),
          ),
        ],
      ),
    );
  }

  void _onAnswerSelected(String answer) {
    if (!_isExamActive) return;

    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answer;
    });

    _saveAnswerLocally();
    HapticFeedback.selectionClick();
  }

  void _saveAnswerLocally() {
    // In real implementation, this would save to encrypted local storage
    final answerData = {
      'questionId': _examQuestions[_currentQuestionIndex]['id'],
      'selectedAnswer': _selectedAnswers[_currentQuestionIndex],
      'timestamp': DateTime.now().toIso8601String(),
      'watermark': _examInfo['teacherWatermark'],
    };

    debugPrint('Answer saved locally: ${jsonEncode(answerData)}');
  }

  void _saveExamResults() {
    int correctAnswers = 0;

    for (int i = 0; i < _examQuestions.length; i++) {
      if (_selectedAnswers[i] == _examQuestions[i]['correctAnswer']) {
        correctAnswers++;
      }
    }

    final results = {
      'studentName': _examInfo['studentName'],
      'examId': _examInfo['examId'],
      'examName': _examInfo['examName'],
      'totalQuestions': _examQuestions.length,
      'correctAnswers': correctAnswers,
      'score': ((correctAnswers / _examQuestions.length) * 100).round(),
      'completedAt': DateTime.now().toIso8601String(),
      'watermark': _examInfo['teacherWatermark'],
      'answers': _selectedAnswers,
    };

    debugPrint('Exam results saved: ${jsonEncode(results)}');
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _examQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _submitExam() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Submit Exam'),
        content: Text(
            'Are you sure you want to submit your exam? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveExamResults();
              Navigator.pushReplacementNamed(
                  context, '/student-results-screen');
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _onTimeUp() {
    _terminateExam('Time limit exceeded. Exam submitted automatically.');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header with timer and camera
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _examInfo['examName'] as String,
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              ExamTimerWidget(
                                totalMinutes: _examInfo['duration'] as int,
                                onTimeUp: _onTimeUp,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 4.w),
                        CameraPreviewWidget(
                          onFaceDetectionChanged: _onFaceDetectionChanged,
                          onMultipleFacesDetected: _onMultipleFacesDetected,
                        ),
                      ],
                    ),
                  ),

                  // Progress indicator
                  Container(
                    padding: EdgeInsets.all(4.w),
                    child: QuestionProgressWidget(
                      currentQuestion: _currentQuestionIndex + 1,
                      totalQuestions: _examQuestions.length,
                    ),
                  ),

                  // Question content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: QuestionDisplayWidget(
                        question: _examQuestions[_currentQuestionIndex],
                        selectedAnswer: _selectedAnswers[_currentQuestionIndex],
                        onAnswerSelected: _onAnswerSelected,
                      ),
                    ),
                  ),

                  // Navigation buttons
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (_currentQuestionIndex > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousQuestion,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'arrow_back',
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text('Previous'),
                                ],
                              ),
                            ),
                          ),
                        if (_currentQuestionIndex > 0) SizedBox(width: 4.w),
                        Expanded(
                          child: _currentQuestionIndex <
                                  _examQuestions.length - 1
                              ? ElevatedButton(
                                  onPressed: _nextQuestion,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Next'),
                                      SizedBox(width: 2.w),
                                      CustomIconWidget(
                                        iconName: 'arrow_forward',
                                        color: AppTheme
                                            .lightTheme.colorScheme.onPrimary,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _submitExam,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme
                                        .lightTheme.colorScheme.tertiary,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'check_circle',
                                        color: AppTheme
                                            .lightTheme.colorScheme.onPrimary,
                                        size: 20,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text('Submit Exam'),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Security warning overlay
              if (_showSecurityWarning)
                SecurityWarningOverlay(
                  warningType: _warningType,
                  message: _warningMessage,
                  onDismiss: _dismissWarning,
                  isBlocking: _warningType == 'exam_terminated',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
