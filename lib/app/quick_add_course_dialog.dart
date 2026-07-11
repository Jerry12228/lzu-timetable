import 'package:flutter/material.dart';

import '../models/schedule_models.dart';

class QuickAddCourseDialog extends StatefulWidget {
  const QuickAddCourseDialog({
    super.key,
    required this.semester,
    required this.selection,
    required this.validateCourse,
  });

  final Semester semester;
  final TimetableCellSelection selection;
  final String? Function(Course course) validateCourse;

  @override
  State<QuickAddCourseDialog> createState() => _QuickAddCourseDialogState();
}

class _QuickAddCourseDialogState extends State<QuickAddCourseDialog> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  late final Set<int> _weeks = {widget.selection.week};
  late int _weekday = widget.selection.weekday;
  late PeriodDefinition _period = _defaultPeriod();
  String? _errorMessage;

  int get _maxWeek =>
      widget.semester.maxWeek < 20 ? 20 : widget.semester.maxWeek;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加课程'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const ValueKey('quick-add-name-field'),
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '课程名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              const Text('周次', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var week = 1; week <= _maxWeek; week++)
                    FilterChip(
                      key: ValueKey('quick-add-week-$week'),
                      label: Text('第$week周'),
                      selected: _weeks.contains(week),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _weeks.add(week);
                          } else {
                            _weeks.remove(week);
                          }
                          _errorMessage = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _selectedDateSummary(),
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                key: const ValueKey('quick-add-weekday-dropdown'),
                initialValue: _weekday,
                decoration: const InputDecoration(
                  labelText: '星期',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (var index = 0; index < weekdays.length; index++)
                    DropdownMenuItem(
                      value: index + 1,
                      child: Text(weekdays[index]),
                    ),
                ],
                onChanged: (weekday) {
                  if (weekday != null) {
                    setState(() {
                      _weekday = weekday;
                      _errorMessage = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                key: const ValueKey('quick-add-period-dropdown'),
                initialValue: _period.name,
                decoration: const InputDecoration(
                  labelText: '上课节次',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final period in widget.semester.periods)
                    DropdownMenuItem(
                      value: period.name,
                      child: Text(
                        '${period.name} ${period.startTime}-${period.endTime}',
                      ),
                    ),
                ],
                onChanged: (name) {
                  if (name != null) {
                    setState(() {
                      _period = widget.semester.periods.firstWhere(
                        (period) => period.name == name,
                      );
                      _errorMessage = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 14),
              TextField(
                key: const ValueKey('quick-add-location-field'),
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: '地点（可选）',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          key: const ValueKey('quick-add-save-button'),
          onPressed: _save,
          child: const Text('添加'),
        ),
      ],
    );
  }

  PeriodDefinition _defaultPeriod() {
    return widget.semester.periods.firstWhere(
      (period) =>
          period.sections.length == 1 &&
          period.sections.single == widget.selection.section,
      orElse: () => widget.semester.periods.first,
    );
  }

  String _selectedDateSummary() {
    if (_weeks.isEmpty) {
      return '请选择至少一个周次';
    }
    final sortedWeeks = _weeks.toList()..sort();
    final start = widget.semester.termStartDate;
    if (start == null) {
      return '已选：${sortedWeeks.map((week) => '第$week周').join('、')}';
    }
    final dates = [
      for (final week in sortedWeeks)
        _formatMonthDay(
          DateTime(
            start.year,
            start.month,
            start.day,
          ).add(Duration(days: (week - 1) * 7 + _weekday - 1)),
        ),
    ];
    return '已选日期：${dates.join('、')}';
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = '请输入课程名称');
      return;
    }
    if (_weeks.isEmpty) {
      setState(() => _errorMessage = '请选择至少一个周次');
      return;
    }
    final course = _buildCourse(name);
    final conflict = widget.validateCourse(course);
    if (conflict != null) {
      setState(() => _errorMessage = conflict);
      return;
    }
    Navigator.of(context).pop(course);
  }

  Course _buildCourse(String name) {
    final code =
        '$manualCourseCodePrefix${DateTime.now().microsecondsSinceEpoch}';
    final sortedWeeks = _weeks.toList()..sort();
    return Course(
      courseCode: code,
      sequence: 'local',
      name: name,
      teachers: const [],
      credits: '',
      selectionType: '',
      assessment: '',
      examNature: '',
      deferredExam: '',
      material: '',
      courseDetailLink: null,
      teachingRecordLink: null,
      processScoreLink: null,
      sessions: [
        for (final week in sortedWeeks)
          CourseSession(
            week: week,
            weekday: _weekday,
            weekdayText: weekdays[_weekday - 1],
            periodName: _period.name,
            startTime: _period.startTime,
            endTime: _period.endTime,
            sections: _period.sections,
            location: _locationController.text.trim(),
          ),
      ],
    );
  }
}

String _formatMonthDay(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$month-$day';
}
