import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class QuestionPreviewCardWidget extends StatefulWidget {
  final Map<String, dynamic> question;
  final bool isSelected;
  final Function(bool) onSelectionChanged;
  final VoidCallback onEdit;
  final VoidCallback onRegenerate;

  const QuestionPreviewCardWidget({
    Key? key,
    required this.question,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.onEdit,
    required this.onRegenerate,
  }) : super(key: key);

  @override
  State<QuestionPreviewCardWidget> createState() =>
      _QuestionPreviewCardWidgetState();
}

class _QuestionPreviewCardWidgetState extends State<QuestionPreviewCardWidget> {
  @override
  Widget build(BuildContext context) {
    final questionText = widget.question['question'] as String? ?? '';
    final options = widget.question['options'] as List<dynamic>? ?? [];
    final correctAnswer = widget.question['correctAnswer'] as String? ?? '';
    final difficulty = widget.question['difficulty'] as String? ?? 'Medium';
    final subject = widget.question['subject'] as String? ?? 'General';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: widget.isSelected ? 4.0 : 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: widget.isSelected
              ? AppTheme.lightTheme.colorScheme.primary
              : Colors.transparent,
          width: 2.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with checkbox and metadata
            Row(
              children: [
                Checkbox(
                  value: widget.isSelected,
                  onChanged: (bool? value) {
                    widget.onSelectionChanged(value ?? false);
                  },
                  activeColor: AppTheme.lightTheme.colorScheme.primary,
                ),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(difficulty)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          difficulty,
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: _getDifficultyColor(difficulty),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.secondary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          subject,
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: CustomIconWidget(
                    iconName: 'more_vert',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onSelected: (String value) {
                    if (value == 'edit') {
                      widget.onEdit();
                    } else if (value == 'regenerate') {
                      widget.onRegenerate();
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'edit',
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            size: 16,
                          ),
                          SizedBox(width: 2.w),
                          Text('Edit Question'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'regenerate',
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'refresh',
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            size: 16,
                          ),
                          SizedBox(width: 2.w),
                          Text('Regenerate'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Question Text
            Text(
              questionText,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            SizedBox(height: 2.h),

            // Options
            ...options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value as String;
              final optionLabel = String.fromCharCode(65 + index); // A, B, C, D
              final isCorrect = option == correctAnswer;

              return Container(
                margin: EdgeInsets.only(bottom: 1.h),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? AppTheme.lightTheme.colorScheme.tertiary
                          .withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.surface,
                  border: Border.all(
                    color: isCorrect
                        ? AppTheme.lightTheme.colorScheme.tertiary
                        : AppTheme.lightTheme.colorScheme.outline,
                    width: isCorrect ? 2.0 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? AppTheme.lightTheme.colorScheme.tertiary
                            : AppTheme.lightTheme.colorScheme.outline,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          optionLabel,
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: isCorrect
                                ? AppTheme.lightTheme.colorScheme.onTertiary
                                : AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        option,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isCorrect ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (isCorrect)
                      CustomIconWidget(
                        iconName: 'check_circle',
                        color: AppTheme.lightTheme.colorScheme.tertiary,
                        size: 20,
                      ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'hard':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}
