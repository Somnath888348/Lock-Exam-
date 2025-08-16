import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/exam_form_widget.dart';
import './widgets/exam_settings_widget.dart';
import './widgets/question_card_widget.dart';
import './widgets/question_creation_modal.dart';

class ExamCreationScreen extends StatefulWidget {
  const ExamCreationScreen({Key? key}) : super(key: key);

  @override
  State<ExamCreationScreen> createState() => _ExamCreationScreenState();
}

class _ExamCreationScreenState extends State<ExamCreationScreen>
    with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  late TabController _tabController;

  // Form data
  Map<String, dynamic> _examFormData = {
    'name': '',
    'description': '',
    'instructions': '',
    'duration': 60, // minutes
    'startDate': DateTime.now().add(Duration(days: 1)),
    'startTime': TimeOfDay(hour: 9, minute: 0),
  };

  // Questions data
  List<Map<String, dynamic>> _questions = [];

  // Settings data
  Map<String, bool> _examSettings = {
    'randomizeQuestions': false,
    'randomizeAnswers': false,
    'allowReview': true,
    'showResultsImmediately': false,
    'strictProctoring': true,
    'autoSubmit': true,
  };

  bool _isDraft = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMockData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    // Mock questions data
    _questions = [
      {
        'id': 1,
        'text':
            'What is the primary purpose of AI proctoring in online examinations?',
        'type': 'multiple_choice',
        'options': [
          'To replace human teachers completely',
          'To monitor and prevent cheating during exams',
          'To grade exams automatically',
          'To create exam questions'
        ],
        'correctAnswer': 1,
        'createdAt': DateTime.now().subtract(Duration(hours: 2)),
        'updatedAt': DateTime.now().subtract(Duration(hours: 1)),
      },
      {
        'id': 2,
        'text':
            'Machine learning algorithms can be trained to recognize patterns in data.',
        'type': 'true_false',
        'options': ['True', 'False'],
        'correctAnswer': 0,
        'createdAt': DateTime.now().subtract(Duration(hours: 3)),
        'updatedAt': DateTime.now().subtract(Duration(hours: 2)),
      },
      {
        'id': 3,
        'text':
            'Which of the following are key features of SafeExam AI Proctor?',
        'type': 'multiple_choice',
        'options': [
          'Real-time camera monitoring',
          'Multi-face detection',
          'Screenshot prevention',
          'All of the above'
        ],
        'correctAnswer': 3,
        'createdAt': DateTime.now().subtract(Duration(hours: 1)),
        'updatedAt': DateTime.now().subtract(Duration(minutes: 30)),
      },
    ];
  }

  void _onFormChanged(Map<String, dynamic> formData) {
    setState(() {
      _examFormData = {..._examFormData, ...formData};
    });
  }

  void _onSettingsChanged(Map<String, bool> settings) {
    setState(() {
      _examSettings = settings;
    });
  }

  void _addQuestion() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuestionCreationModal(
        onSave: (questionData) {
          setState(() {
            _questions.add(questionData);
          });
        },
      ),
    );
  }

  void _editQuestion(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuestionCreationModal(
        existingQuestion: _questions[index],
        onSave: (questionData) {
          setState(() {
            _questions[index] = questionData;
          });
        },
      ),
    );
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _reorderQuestions(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _questions.removeAt(oldIndex);
      _questions.insert(newIndex, item);
    });
  }

  bool _validateForm() {
    if (_examFormData['name']?.toString().trim().isEmpty ?? true) {
      _showErrorSnackBar('Exam name is required');
      return false;
    }

    if (_questions.isEmpty) {
      _showErrorSnackBar('At least one question is required');
      return false;
    }

    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.accentError,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.accentSuccess,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveExam({bool publish = false}) async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      final examData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'formData': _examFormData,
        'questions': _questions,
        'settings': _examSettings,
        'status': publish ? 'published' : 'draft',
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };

      if (publish) {
        _showExamPublishedDialog(examData['id'] as String);
      } else {
        _showSuccessSnackBar('Exam saved as draft successfully');
        setState(() {
          _isDraft = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to save exam. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showExamPublishedDialog(String examId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.accentSuccess,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text('Exam Published!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your exam has been published successfully.'),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exam ID',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          examId,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Copy to clipboard functionality would go here
                      _showSuccessSnackBar('Exam ID copied to clipboard');
                    },
                    icon: CustomIconWidget(
                      iconName: 'content_copy',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Share this Exam ID with your students to allow them to take the exam.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/teacher-dashboard-screen');
            },
            child: Text('Go to Dashboard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Share functionality would go here
              _showSuccessSnackBar('Exam ID shared successfully');
            },
            child: Text('Share Exam ID'),
          ),
        ],
      ),
    );
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unsaved Changes'),
        content: Text(
            'You have unsaved changes. Do you want to save them before leaving?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Discard'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveExam();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_examFormData['name']?.toString().isNotEmpty == true ||
            _questions.isNotEmpty) {
          _showUnsavedChangesDialog();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('Create Exam'),
          leading: IconButton(
            onPressed: () {
              if (_examFormData['name']?.toString().isNotEmpty == true ||
                  _questions.isNotEmpty) {
                _showUnsavedChangesDialog();
              } else {
                Navigator.pop(context);
              }
            },
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
          ),
          actions: [
            if (_isDraft)
              Container(
                margin: EdgeInsets.only(right: 2.w),
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.accentWarning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Draft',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.accentWarning,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'save_draft') {
                  _saveExam(publish: false);
                } else if (value == 'import_questions') {
                  _showSuccessSnackBar('Import questions feature coming soon');
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'save_draft',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'save',
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 18,
                      ),
                      SizedBox(width: 2.w),
                      Text('Save as Draft'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'import_questions',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'file_upload',
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 18,
                      ),
                      SizedBox(width: 2.w),
                      Text('Import Questions'),
                    ],
                  ),
                ),
              ],
              child: Padding(
                padding: EdgeInsets.all(2.w),
                child: CustomIconWidget(
                  iconName: 'more_vert',
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 24,
                ),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: CustomIconWidget(
                  iconName: 'info',
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
                text: 'Details',
              ),
              Tab(
                icon: CustomIconWidget(
                  iconName: 'quiz',
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
                text: 'Questions',
              ),
              Tab(
                icon: CustomIconWidget(
                  iconName: 'settings',
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
                text: 'Settings',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Exam Details Tab
            SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(4.w),
              child: ExamFormWidget(
                onFormChanged: _onFormChanged,
                initialData: _examFormData,
              ),
            ),

            // Questions Tab
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .shadowColor
                            .withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
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
                              'Questions (${_questions.length})',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            if (_questions.isNotEmpty)
                              Text(
                                'Drag to reorder questions',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addQuestion,
                        icon: CustomIconWidget(
                          iconName: 'add',
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text('Add Question'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _questions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'quiz',
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha: 0.5),
                                size: 64,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'No questions added yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Add your first question to get started',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              SizedBox(height: 3.h),
                              ElevatedButton.icon(
                                onPressed: _addQuestion,
                                icon: CustomIconWidget(
                                  iconName: 'add',
                                  color: Colors.white,
                                  size: 18,
                                ),
                                label: Text('Add Question'),
                              ),
                            ],
                          ),
                        )
                      : ReorderableListView.builder(
                          padding: EdgeInsets.all(4.w),
                          itemCount: _questions.length,
                          onReorder: _reorderQuestions,
                          itemBuilder: (context, index) {
                            return QuestionCardWidget(
                              key: ValueKey(_questions[index]['id']),
                              question: _questions[index],
                              index: index,
                              onEdit: () => _editQuestion(index),
                              onDelete: () => _deleteQuestion(index),
                            );
                          },
                        ),
                ),
              ],
            ),

            // Settings Tab
            SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: ExamSettingsWidget(
                settings: _examSettings,
                onSettingsChanged: _onSettingsChanged,
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isLoading ? null : () => _saveExam(publish: false),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          )
                        : Text('Save Draft'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ? null : () => _saveExam(publish: true),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text('Publish Exam'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
