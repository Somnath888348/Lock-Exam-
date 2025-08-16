import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './student_attempt_item.dart';

class ExamResultsCard extends StatefulWidget {
  final Map<String, dynamic> examData;
  final VoidCallback? onExport;
  final VoidCallback? onViewDetails;

  const ExamResultsCard({
    Key? key,
    required this.examData,
    this.onExport,
    this.onViewDetails,
  }) : super(key: key);

  @override
  State<ExamResultsCard> createState() => _ExamResultsCardState();
}

class _ExamResultsCardState extends State<ExamResultsCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final attempts = (widget.examData['attempts'] as List? ?? []);
    final completedAttempts = attempts
        .where((attempt) =>
            (attempt as Map<String, dynamic>)['status'] == 'completed')
        .length;
    final averageScore = attempts.isNotEmpty
        ? attempts
                .where((attempt) =>
                    (attempt as Map<String, dynamic>)['status'] == 'completed')
                .map((attempt) =>
                    (attempt as Map<String, dynamic>)['score'] as double)
                .fold(0.0, (sum, score) => sum + score) /
            completedAttempts
        : 0.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.examData['name'] as String? ??
                                  'Untitled Exam',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 1.h),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'schedule',
                                  size: 16,
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  '${widget.examData['duration'] ?? 60} min',
                                  style:
                                      AppTheme.lightTheme.textTheme.bodySmall,
                                ),
                                SizedBox(width: 4.w),
                                CustomIconWidget(
                                  iconName: 'quiz',
                                  size: 16,
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  '${widget.examData['totalQuestions'] ?? 0} questions',
                                  style:
                                      AppTheme.lightTheme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: widget.examData['status'] == 'active'
                                  ? AppTheme.lightTheme.colorScheme.tertiary
                                      .withValues(alpha: 0.1)
                                  : AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.examData['status'] == 'active'
                                  ? 'Active'
                                  : 'Completed',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: widget.examData['status'] == 'active'
                                    ? AppTheme.lightTheme.colorScheme.tertiary
                                    : AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: CustomIconWidget(
                              iconName: 'keyboard_arrow_down',
                              size: 24,
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Total Attempts',
                          attempts.length.toString(),
                          'people',
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Completed',
                          completedAttempts.toString(),
                          'check_circle',
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Avg Score',
                          completedAttempts > 0
                              ? '${averageScore.toStringAsFixed(1)}%'
                              : 'N/A',
                          'trending_up',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  if (attempts.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Student Attempts',
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: widget.onExport,
                                icon: CustomIconWidget(
                                  iconName: 'download',
                                  size: 16,
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                                label: Text(
                                  'Export',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelMedium
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              TextButton.icon(
                                onPressed: widget.onViewDetails,
                                icon: CustomIconWidget(
                                  iconName: 'analytics',
                                  size: 16,
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                                label: Text(
                                  'Analytics',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelMedium
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: attempts.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.1),
                      ),
                      itemBuilder: (context, index) {
                        final attempt = attempts[index] as Map<String, dynamic>;
                        return StudentAttemptItem(
                          attemptData: attempt,
                          onViewDetails: () =>
                              _showAttemptDetails(context, attempt),
                          onFlag: () => _flagAttempt(attempt),
                        );
                      },
                    ),
                  ] else ...[
                    Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Column(
                        children: [
                          CustomIconWidget(
                            iconName: 'assignment',
                            size: 48,
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No attempts yet',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Students haven\'t started this exam',
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String iconName) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          size: 20,
          color: AppTheme.lightTheme.colorScheme.primary,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showAttemptDetails(BuildContext context, Map<String, dynamic> attempt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Attempt Details',
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: CustomIconWidget(
                        iconName: 'close',
                        size: 24,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Student Name',
                          attempt['studentName'] as String? ?? 'Unknown'),
                      _buildDetailRow('Score', '${attempt['score'] ?? 0}%'),
                      _buildDetailRow('Time Taken',
                          attempt['timeTaken'] as String? ?? 'N/A'),
                      _buildDetailRow(
                          'Status', attempt['status'] as String? ?? 'Unknown'),
                      _buildDetailRow('Submitted At',
                          attempt['submittedAt'] as String? ?? 'N/A'),
                      SizedBox(height: 3.h),
                      Text(
                        'Question Breakdown',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      // Mock question breakdown
                      ...List.generate(
                          5,
                          (index) =>
                              _buildQuestionItem(index + 1, index % 2 == 0)),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionItem(int questionNumber, bool isCorrect) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect
              ? AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: isCorrect ? 'check_circle' : 'cancel',
            size: 20,
            color: isCorrect
                ? AppTheme.lightTheme.colorScheme.tertiary
                : Colors.red,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Question $questionNumber',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            isCorrect ? 'Correct' : 'Incorrect',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: isCorrect
                  ? AppTheme.lightTheme.colorScheme.tertiary
                  : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _flagAttempt(Map<String, dynamic> attempt) {
    // Implementation for flagging attempt for review
  }
}
