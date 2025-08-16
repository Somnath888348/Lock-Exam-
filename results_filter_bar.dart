import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ResultsFilterBar extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final VoidCallback? onDateFilter;
  final VoidCallback? onScoreFilter;

  const ResultsFilterBar({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.onDateFilter,
    this.onScoreFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All Exams', 'all'),
                      SizedBox(width: 2.w),
                      _buildFilterChip('Active', 'active'),
                      SizedBox(width: 2.w),
                      _buildFilterChip('Completed', 'completed'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'date':
                      onDateFilter?.call();
                      break;
                    case 'score':
                      onScoreFilter?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'date',
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'date_range',
                          size: 18,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                        SizedBox(width: 3.w),
                        Text('Date Range'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'score',
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'trending_up',
                          size: 18,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                        SizedBox(width: 3.w),
                        Text('Score Range'),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'tune',
                    size: 20,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;

    return GestureDetector(
      onTap: () => onFilterChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.onPrimary
                : AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
