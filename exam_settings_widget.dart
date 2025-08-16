import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExamSettingsWidget extends StatefulWidget {
  final Map<String, bool> settings;
  final Function(Map<String, bool>) onSettingsChanged;

  const ExamSettingsWidget({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
  }) : super(key: key);

  @override
  State<ExamSettingsWidget> createState() => _ExamSettingsWidgetState();
}

class _ExamSettingsWidgetState extends State<ExamSettingsWidget> {
  late Map<String, bool> _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = Map.from(widget.settings);
  }

  void _updateSetting(String key, bool value) {
    setState(() {
      _currentSettings[key] = value;
    });
    widget.onSettingsChanged(_currentSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'settings',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Exam Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // Randomize Questions Setting
            _buildSettingTile(
              context: context,
              icon: 'shuffle',
              title: 'Randomize Questions',
              subtitle:
                  'Questions will appear in random order for each student',
              value: _currentSettings['randomizeQuestions'] ?? false,
              onChanged: (value) => _updateSetting('randomizeQuestions', value),
            ),

            Divider(height: 3.h),

            // Randomize Answers Setting
            _buildSettingTile(
              context: context,
              icon: 'swap_vert',
              title: 'Randomize Answers',
              subtitle: 'Answer options will be shuffled for each question',
              value: _currentSettings['randomizeAnswers'] ?? false,
              onChanged: (value) => _updateSetting('randomizeAnswers', value),
            ),

            Divider(height: 3.h),

            // Allow Question Review Setting
            _buildSettingTile(
              context: context,
              icon: 'preview',
              title: 'Allow Question Review',
              subtitle:
                  'Students can review and change answers before submission',
              value: _currentSettings['allowReview'] ?? true,
              onChanged: (value) => _updateSetting('allowReview', value),
            ),

            Divider(height: 3.h),

            // Show Results Immediately Setting
            _buildSettingTile(
              context: context,
              icon: 'visibility',
              title: 'Show Results Immediately',
              subtitle: 'Display scores and correct answers after submission',
              value: _currentSettings['showResultsImmediately'] ?? false,
              onChanged: (value) =>
                  _updateSetting('showResultsImmediately', value),
            ),

            Divider(height: 3.h),

            // Strict Proctoring Setting
            _buildSettingTile(
              context: context,
              icon: 'security',
              title: 'Strict Proctoring',
              subtitle: 'Enable advanced AI monitoring and cheating detection',
              value: _currentSettings['strictProctoring'] ?? true,
              onChanged: (value) => _updateSetting('strictProctoring', value),
            ),

            Divider(height: 3.h),

            // Auto Submit Setting
            _buildSettingTile(
              context: context,
              icon: 'timer_off',
              title: 'Auto Submit on Time End',
              subtitle: 'Automatically submit exam when time expires',
              value: _currentSettings['autoSubmit'] ?? true,
              onChanged: (value) => _updateSetting('autoSubmit', value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: value
                ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: value
                  ? AppTheme.lightTheme.primaryColor
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: 2.w),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.lightTheme.primaryColor,
          activeTrackColor:
              AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
          inactiveThumbColor: Theme.of(context).colorScheme.outline,
          inactiveTrackColor:
              Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}
