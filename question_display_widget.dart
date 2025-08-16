import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class QuestionDisplayWidget extends StatelessWidget {
  final Map<String, dynamic> question;
  final int currentQuestionIndex;
  final int totalQuestions;
  final String? selectedAnswer;
  final Function(String) onAnswerSelected;

  const QuestionDisplayWidget({
    Key? key,
    required this.question,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> options = (question['options'] as List).cast<String>();
    final String questionType = question['type'] ?? 'single';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Question ${currentQuestionIndex + 1} of $totalQuestions',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: questionType == 'multiple'
                      ? AppTheme.accentWarning.withValues(alpha: 0.1)
                      : AppTheme.accentSuccess.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  questionType == 'multiple'
                      ? 'Multiple Choice'
                      : 'Single Choice',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: questionType == 'multiple'
                        ? AppTheme.accentWarning
                        : AppTheme.accentSuccess,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Question Text
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border.all(
                color: AppTheme.borderLight,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              question['question'] ?? '',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                fontSize: 16.sp,
                height: 1.5,
                color: AppTheme.textPrimaryLight,
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Answer Options
          Text(
            'Select your answer:',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 2.h),

          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final optionLabel = String.fromCharCode(65 + index); // A, B, C, D
            final isSelected = selectedAnswer == option;

            return Container(
              margin: EdgeInsets.only(bottom: 2.h),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onAnswerSelected(option),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.1)
                          : AppTheme.lightTheme.colorScheme.surface,
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.lightTheme.primaryColor
                            : AppTheme.borderLight,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.lightTheme.primaryColor
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.lightTheme.primaryColor
                                  : AppTheme.borderLight,
                              width: 2,
                            ),
                            shape: questionType == 'multiple'
                                ? BoxShape.rectangle
                                : BoxShape.circle,
                            borderRadius: questionType == 'multiple'
                                ? BorderRadius.circular(4)
                                : null,
                          ),
                          child: isSelected
                              ? Icon(
                                  questionType == 'multiple'
                                      ? Icons.check
                                      : Icons.circle,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                        SizedBox(width: 3.w),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.lightTheme.primaryColor
                                : AppTheme.borderLight.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              optionLabel,
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            option,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: isSelected
                                  ? AppTheme.lightTheme.primaryColor
                                  : AppTheme.textPrimaryLight,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
