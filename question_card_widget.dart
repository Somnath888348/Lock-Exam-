import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuestionCardWidget extends StatelessWidget {
  final Map<String, dynamic> question;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDragging;

  const QuestionCardWidget({
    Key? key,
    required this.question,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    this.isDragging = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final questionText = question['text'] as String? ?? '';
    final options = (question['options'] as List<dynamic>?) ?? [];
    final correctAnswer = question['correctAnswer'] as int? ?? 0;
    final questionType = question['type'] as String? ?? 'multiple_choice';

    return Card(
      elevation: isDragging ? 8 : 2,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDragging
              ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3)
              : Colors.transparent,
          width: isDragging ? 2 : 0,
        ),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        childrenPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        leading: Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
        title: Text(
          questionText.length > 80
              ? '${questionText.substring(0, 80)}...'
              : questionText,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 1.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getTypeColor(questionType).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getTypeLabel(questionType),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _getTypeColor(questionType),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.accentSuccess,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                'Option ${String.fromCharCode(65 + correctAnswer)}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.accentSuccess,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'drag_handle',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 2.w),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  _showDeleteConfirmation(context);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'edit',
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 18,
                      ),
                      SizedBox(width: 2.w),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'delete',
                        color: AppTheme.accentError,
                        size: 18,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Delete',
                        style: TextStyle(color: AppTheme.accentError),
                      ),
                    ],
                  ),
                ),
              ],
              child: CustomIconWidget(
                iconName: 'more_vert',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ],
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 1.h),
              Container(
                width: double.infinity,
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
                child: Text(
                  questionText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Options:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 1.h),
              ...options.asMap().entries.map((entry) {
                final optionIndex = entry.key;
                final optionText = entry.value as String;
                final isCorrect = optionIndex == correctAnswer;

                return Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? AppTheme.accentSuccess.withValues(alpha: 0.1)
                        : Theme.of(context)
                            .colorScheme
                            .surface
                            .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCorrect
                          ? AppTheme.accentSuccess.withValues(alpha: 0.3)
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? AppTheme.accentSuccess
                              : Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + optionIndex),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: isCorrect
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          optionText,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: isCorrect
                                    ? AppTheme.accentSuccess
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: isCorrect
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                        ),
                      ),
                      if (isCorrect)
                        CustomIconWidget(
                          iconName: 'check_circle',
                          color: AppTheme.accentSuccess,
                          size: 20,
                        ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'multiple_choice':
        return AppTheme.lightTheme.primaryColor;
      case 'true_false':
        return AppTheme.accentWarning;
      case 'short_answer':
        return AppTheme.accentSuccess;
      default:
        return AppTheme.lightTheme.primaryColor;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'MCQ';
      case 'true_false':
        return 'T/F';
      case 'short_answer':
        return 'Short';
      default:
        return 'Other';
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Question'),
        content: Text(
            'Are you sure you want to delete this question? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentError,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}