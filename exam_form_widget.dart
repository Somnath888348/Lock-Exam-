import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExamFormWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFormChanged;
  final Map<String, dynamic> initialData;

  const ExamFormWidget({
    Key? key,
    required this.onFormChanged,
    required this.initialData,
  }) : super(key: key);

  @override
  State<ExamFormWidget> createState() => _ExamFormWidgetState();
}

class _ExamFormWidgetState extends State<ExamFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _instructionsController;

  int _selectedHours = 1;
  int _selectedMinutes = 0;
  DateTime _selectedDate = DateTime.now().add(Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialData['name'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialData['description'] ?? '');
    _instructionsController =
        TextEditingController(text: widget.initialData['instructions'] ?? '');

    if (widget.initialData['duration'] != null) {
      final duration = widget.initialData['duration'] as int;
      _selectedHours = duration ~/ 60;
      _selectedMinutes = duration % 60;
    }

    if (widget.initialData['startDate'] != null) {
      _selectedDate = widget.initialData['startDate'] as DateTime;
    }

    if (widget.initialData['startTime'] != null) {
      _selectedTime = widget.initialData['startTime'] as TimeOfDay;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _updateFormData() {
    final formData = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'instructions': _instructionsController.text,
      'duration': (_selectedHours * 60) + _selectedMinutes,
      'startDate': _selectedDate,
      'startTime': _selectedTime,
    };
    widget.onFormChanged(formData);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.lightTheme.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _updateFormData();
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).colorScheme.brightness == Brightness.light
              ? AppTheme.lightTheme
              : AppTheme.darkTheme,
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      _updateFormData();
    }
  }

  void _showDurationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: 40.h,
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Select Duration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 3.h),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Hours',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: 1.h),
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 50,
                              physics: FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _selectedHours = index;
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  return Center(
                                    child: Text(
                                      '$index',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: index == _selectedHours
                                                ? AppTheme
                                                    .lightTheme.primaryColor
                                                : Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                          ),
                                    ),
                                  );
                                },
                                childCount: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Minutes',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          SizedBox(height: 1.h),
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 50,
                              physics: FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _selectedMinutes = index * 15;
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                builder: (context, index) {
                                  final minutes = index * 15;
                                  return Center(
                                    child: Text(
                                      '$minutes',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: minutes == _selectedMinutes
                                                ? AppTheme
                                                    .lightTheme.primaryColor
                                                : Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                          ),
                                    ),
                                  );
                                },
                                childCount: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateFormData();
                  },
                  child: Text('Done'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exam Name Field
          Text(
            'Exam Name *',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter exam name',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'quiz',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Exam name is required';
              }
              if (value.trim().length < 3) {
                return 'Exam name must be at least 3 characters';
              }
              return null;
            },
            onChanged: (value) => _updateFormData(),
          ),
          SizedBox(height: 3.h),

          // Description Field
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter exam description (optional)',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'description',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
            onChanged: (value) => _updateFormData(),
          ),
          SizedBox(height: 3.h),

          // Duration Selector
          Text(
            'Duration *',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          InkWell(
            onTap: _showDurationPicker,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.w),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'schedule',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      _selectedHours > 0 && _selectedMinutes > 0
                          ? '${_selectedHours}h ${_selectedMinutes}m'
                          : _selectedHours > 0
                              ? '${_selectedHours}h'
                              : '${_selectedMinutes}m',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Start Date/Time
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Date *',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 1.h),
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 4.w),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'calendar_today',
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              size: 20,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Time *',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 1.h),
                    InkWell(
                      onTap: _selectTime,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 4.w),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'access_time',
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              size: 20,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                _selectedTime.format(context),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Instructions Field
          Text(
            'Instructions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _instructionsController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter exam instructions for students (optional)',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'info_outline',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
            onChanged: (value) => _updateFormData(),
          ),
        ],
      ),
    );
  }
}
