import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/image_upload_tab_widget.dart';
import './widgets/premium_upgrade_dialog_widget.dart';
import './widgets/question_preview_card_widget.dart';
import './widgets/text_input_tab_widget.dart';

class AiQuestionGeneratorScreen extends StatefulWidget {
  const AiQuestionGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<AiQuestionGeneratorScreen> createState() =>
      _AiQuestionGeneratorScreenState();
}

class _AiQuestionGeneratorScreenState extends State<AiQuestionGeneratorScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isGenerating = false;
  bool _hasGeneratedQuestions = false;
  bool _isPremiumUser = false; // Mock premium status
  List<Map<String, dynamic>> _generatedQuestions = [];
  List<bool> _selectedQuestions = [];
  bool _selectAll = false;

  // Mock generated questions data
  final List<Map<String, dynamic>> _mockQuestions = [
    {
      "id": 1,
      "question":
          "What is the primary function of chlorophyll in photosynthesis?",
      "options": [
        "To absorb carbon dioxide from the atmosphere",
        "To capture light energy from the sun",
        "To release oxygen as a byproduct",
        "To transport water from roots to leaves"
      ],
      "correctAnswer": "To capture light energy from the sun",
      "difficulty": "Medium",
      "subject": "Biology",
    },
    {
      "id": 2,
      "question":
          "Which of the following is the chemical equation for photosynthesis?",
      "options": [
        "6CO₂ + 6H₂O + light energy → C₆H₁₂O₆ + 6O₂",
        "C₆H₁₂O₆ + 6O₂ → 6CO₂ + 6H₂O + ATP",
        "2H₂O + light energy → 4H⁺ + 4e⁻ + O₂",
        "CO₂ + H₂O → CH₂O + O₂"
      ],
      "correctAnswer": "6CO₂ + 6H₂O + light energy → C₆H₁₂O₆ + 6O₂",
      "difficulty": "Hard",
      "subject": "Biology",
    },
    {
      "id": 3,
      "question":
          "In which part of the plant cell does photosynthesis primarily occur?",
      "options": ["Nucleus", "Mitochondria", "Chloroplasts", "Ribosomes"],
      "correctAnswer": "Chloroplasts",
      "difficulty": "Easy",
      "subject": "Biology",
    },
    {
      "id": 4,
      "question": "What are the two main stages of photosynthesis?",
      "options": [
        "Light reactions and Calvin cycle",
        "Glycolysis and Krebs cycle",
        "Transcription and translation",
        "Mitosis and meiosis"
      ],
      "correctAnswer": "Light reactions and Calvin cycle",
      "difficulty": "Medium",
      "subject": "Biology",
    },
    {
      "id": 5,
      "question": "Which gas is released as a byproduct of photosynthesis?",
      "options": ["Carbon dioxide", "Nitrogen", "Oxygen", "Hydrogen"],
      "correctAnswer": "Oxygen",
      "difficulty": "Easy",
      "subject": "Biology",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _generateQuestionsFromText(
    String text,
    String difficulty,
    int questionCount,
    String subject,
  ) async {
    if (!_isPremiumUser) {
      _showPremiumDialog();
      return;
    }

    setState(() {
      _isGenerating = true;
      _hasGeneratedQuestions = false;
    });

    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _generatedQuestions = _mockQuestions.take(questionCount).map((q) {
        return {
          ...q,
          'difficulty': difficulty,
          'subject': subject,
        };
      }).toList();
      _selectedQuestions = List.filled(_generatedQuestions.length, true);
      _selectAll = true;
      _isGenerating = false;
      _hasGeneratedQuestions = true;
    });

    _showSuccessSnackBar(
        'Successfully generated ${_generatedQuestions.length} questions!');
  }

  Future<void> _generateQuestionsFromImage(
    List<int> fileBytes,
    String fileName,
    String difficulty,
    int questionCount,
    String subject,
  ) async {
    if (!_isPremiumUser) {
      _showPremiumDialog();
      return;
    }

    setState(() {
      _isGenerating = true;
      _hasGeneratedQuestions = false;
    });

    // Simulate OCR processing and AI generation
    await Future.delayed(const Duration(seconds: 5));

    setState(() {
      _generatedQuestions = _mockQuestions.take(questionCount).map((q) {
        return {
          ...q,
          'difficulty': difficulty,
          'subject': subject,
        };
      }).toList();
      _selectedQuestions = List.filled(_generatedQuestions.length, true);
      _selectAll = true;
      _isGenerating = false;
      _hasGeneratedQuestions = true;
    });

    _showSuccessSnackBar(
        'Successfully processed image and generated ${_generatedQuestions.length} questions!');
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PremiumUpgradeDialogWidget(
          onUpgrade: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, '/premium-subscription-screen');
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleQuestionSelection(int index, bool isSelected) {
    setState(() {
      _selectedQuestions[index] = isSelected;
      _selectAll = _selectedQuestions.every((selected) => selected);
    });
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      _selectedQuestions = List.filled(_generatedQuestions.length, _selectAll);
    });
  }

  void _editQuestion(int index) {
    // Mock edit functionality
    _showSuccessSnackBar('Question editing feature coming soon!');
  }

  void _regenerateQuestion(int index) {
    // Mock regenerate functionality
    _showSuccessSnackBar('Question regenerated successfully!');
  }

  void _addSelectedQuestionsToExam() {
    final selectedCount =
        _selectedQuestions.where((selected) => selected).length;
    if (selectedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one question to add.'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
      return;
    }

    // Mock adding to exam
    _showSuccessSnackBar('Added $selectedCount questions to your exam!');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'AI Question Generator',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          if (!_isPremiumUser)
            Container(
              margin: EdgeInsets.only(right: 4.w),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/premium-subscription-screen');
                },
                icon: CustomIconWidget(
                  iconName: 'workspace_premium',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                label: Text(
                  'Premium',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
        bottom: !_hasGeneratedQuestions
            ? TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'text_fields',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text('Text Input'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'image',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text('Image Upload'),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
      body: _hasGeneratedQuestions ? _buildResultsView() : _buildInputView(),
      bottomNavigationBar:
          _hasGeneratedQuestions ? _buildBottomActionBar() : null,
    );
  }

  Widget _buildInputView() {
    return TabBarView(
      controller: _tabController,
      children: [
        TextInputTabWidget(
          onGenerate: _generateQuestionsFromText,
          isGenerating: _isGenerating,
        ),
        ImageUploadTabWidget(
          onGenerate: _generateQuestionsFromImage,
          isGenerating: _isGenerating,
        ),
      ],
    );
  }

  Widget _buildResultsView() {
    return Column(
      children: [
        // Results Header
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generated Questions',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${_generatedQuestions.length} questions ready for review',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _selectAll,
                    onChanged: (bool? value) => _toggleSelectAll(),
                    activeColor: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  Text(
                    'Select All',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Questions List
        Expanded(
          child: ListView.builder(
            itemCount: _generatedQuestions.length,
            itemBuilder: (context, index) {
              return QuestionPreviewCardWidget(
                question: _generatedQuestions[index],
                isSelected: _selectedQuestions[index],
                onSelectionChanged: (isSelected) =>
                    _toggleQuestionSelection(index, isSelected),
                onEdit: () => _editQuestion(index),
                onRegenerate: () => _regenerateQuestion(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    final selectedCount =
        _selectedQuestions.where((selected) => selected).length;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$selectedCount questions selected',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (selectedCount > 0)
                    Text(
                      'Ready to add to your exam',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 4.w),
            ElevatedButton(
              onPressed: selectedCount > 0 ? _addSelectedQuestionsToExam : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'add',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Add to Exam',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
