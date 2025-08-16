import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuestionCreationModal extends StatefulWidget {
  final Map<String, dynamic>? existingQuestion;
  final Function(Map<String, dynamic>) onSave;

  const QuestionCreationModal({
    Key? key,
    this.existingQuestion,
    required this.onSave,
  }) : super(key: key);

  @override
  State<QuestionCreationModal> createState() => _QuestionCreationModalState();
}

class _QuestionCreationModalState extends State<QuestionCreationModal> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];

  String _selectedType = 'multiple_choice';
  int _correctAnswer = 0;
  int _numberOfOptions = 4;

  @override
  void initState() {
    super.initState();

    // Initialize with existing question data if editing
    if (widget.existingQuestion != null) {
      final question = widget.existingQuestion!;
      _questionController.text = question['text'] ?? '';
      _selectedType = question['type'] ?? 'multiple_choice';
      _correctAnswer = question['correctAnswer'] ?? 0;

      final options = (question['options'] as List<dynamic>?) ?? [];
      _numberOfOptions = options.length > 0 ? options.length : 4;

      for (int i = 0; i < _numberOfOptions; i++) {
        _optionControllers.add(TextEditingController(
          text: i < options.length ? options[i] : '',
        ));
      }
    } else {
      // Initialize with default empty options
      for (int i = 0; i < _numberOfOptions; i++) {
        _optionControllers.add(TextEditingController());
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateNumberOfOptions(int newCount) {
    setState(() {
      if (newCount > _optionControllers.length) {
        // Add new controllers
        for (int i = _optionControllers.length; i < newCount; i++) {
          _optionControllers.add(TextEditingController());
        }
      } else if (newCount < _optionControllers.length) {
        // Remove controllers
        for (int i = _optionControllers.length - 1; i >= newCount; i--) {
          _optionControllers[i].dispose();
          _optionControllers.removeAt(i);
        }
        // Adjust correct answer if needed
        if (_correctAnswer >= newCount) {
          _correctAnswer = newCount - 1;
        }
      }
      _numberOfOptions = newCount;
    });
  }

  void _saveQuestion() {
    if (_formKey.currentState!.validate()) {
      final questionData = {
        'id': widget.existingQuestion?['id'] ??
            DateTime.now().millisecondsSinceEpoch,
        'text': _questionController.text.trim(),
        'type': _selectedType,
        'options': _optionControllers
            .map((controller) => controller.text.trim())
            .toList(),
        'correctAnswer': _correctAnswer,
        'createdAt': widget.existingQuestion?['createdAt'] ?? DateTime.now(),
        'updatedAt': DateTime.now(),
      };

      widget.onSave(questionData);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 24,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    widget.existingQuestion != null
                        ? 'Edit Question'
                        : 'Add New Question',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _saveQuestion,
                  child: Text('Save'),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Type Selector
                    Text(
                      'Question Type',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedType,
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value!;
                              if (_selectedType == 'true_false') {
                                _updateNumberOfOptions(2);
                                _optionControllers[0].text = 'True';
                                _optionControllers[1].text = 'False';
                              } else if (_selectedType == 'multiple_choice' &&
                                  _numberOfOptions < 3) {
                                _updateNumberOfOptions(4);
                              }
                            });
                          },
                          items: [
                            DropdownMenuItem(
                              value: 'multiple_choice',
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'radio_button_checked',
                                    color: AppTheme.lightTheme.primaryColor,
                                    size: 20,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text('Multiple Choice'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'true_false',
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'check_box',
                                    color: AppTheme.accentWarning,
                                    size: 20,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text('True/False'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // Question Text
                    Text(
                      'Question Text *',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 1.h),
                    TextFormField(
                      controller: _questionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter your question here...',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'help_outline',
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Question text is required';
                        }
                        if (value.trim().length < 10) {
                          return 'Question must be at least 10 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 3.h),

                    // Number of Options (for multiple choice)
                    if (_selectedType == 'multiple_choice') ...[
                      Row(
                        children: [
                          Text(
                            'Number of Options',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.outline),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: _numberOfOptions > 2
                                      ? () => _updateNumberOfOptions(
                                          _numberOfOptions - 1)
                                      : null,
                                  icon: CustomIconWidget(
                                    iconName: 'remove',
                                    color: _numberOfOptions > 2
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.3),
                                    size: 20,
                                  ),
                                ),
                                Text(
                                  '$_numberOfOptions',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                IconButton(
                                  onPressed: _numberOfOptions < 6
                                      ? () => _updateNumberOfOptions(
                                          _numberOfOptions + 1)
                                      : null,
                                  icon: CustomIconWidget(
                                    iconName: 'add',
                                    color: _numberOfOptions < 6
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.3),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                    ],

                    // Answer Options
                    Text(
                      'Answer Options *',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Select the correct answer by tapping the option',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    SizedBox(height: 2.h),

                    // Options List
                    ...List.generate(_numberOfOptions, (index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 2.h),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _correctAnswer = index;
                                });
                              },
                              child: Container(
                                width: 10.w,
                                height: 10.w,
                                decoration: BoxDecoration(
                                  color: _correctAnswer == index
                                      ? AppTheme.accentSuccess
                                      : Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _correctAnswer == index
                                        ? AppTheme.accentSuccess
                                        : Theme.of(context).colorScheme.outline,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: _correctAnswer == index
                                      ? CustomIconWidget(
                                          iconName: 'check',
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : Text(
                                          String.fromCharCode(65 + index),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: TextFormField(
                                controller: _optionControllers[index],
                                decoration: InputDecoration(
                                  hintText:
                                      'Option ${String.fromCharCode(65 + index)}',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: _correctAnswer == index
                                          ? AppTheme.accentSuccess
                                          : Theme.of(context)
                                              .colorScheme
                                              .outline,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: _correctAnswer == index
                                          ? AppTheme.accentSuccess
                                          : AppTheme.lightTheme.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Option ${String.fromCharCode(65 + index)} is required';
                                  }
                                  return null;
                                },
                                readOnly: _selectedType == 'true_false',
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
