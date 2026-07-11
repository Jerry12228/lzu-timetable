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
  late final Set<String> _sections = {widget.selection.section};
  late int _weekday = widget.selection.weekday;
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
              OutlinedButton.icon(
                key: const ValueKey('quick-add-weeks-button'),
                onPressed: _chooseWeeks,
                icon: const Icon(Icons.date_range_outlined),
                label: Text('选择周次（已选 ${_weeks.length} 周）'),
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
              const Text('上课节次', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final period in _singleSectionPeriods)
                    FilterChip(
                      key: ValueKey(
                        'quick-add-section-${period.sections.single}',
                      ),
                      label: Text(_sectionLabel(period.sections.single)),
                      selected: _sections.contains(period.sections.single),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _sections.add(period.sections.single);
                          } else {
                            _sections.remove(period.sections.single);
                          }
                          _errorMessage = null;
                        });
                      },
                    ),
                ],
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

  List<PeriodDefinition> get _singleSectionPeriods => [
    for (final section in timetableSectionOrder)
      widget.semester.periods.firstWhere(
        (period) =>
            period.sections.length == 1 && period.sections.single == section,
      ),
  ];

  Future<void> _chooseWeeks() async {
    final selectedWeeks = await showDialog<Set<int>>(
      context: context,
      builder: (context) =>
          _WeekSelectionDialog(maxWeek: _maxWeek, selectedWeeks: _weeks),
    );
    if (selectedWeeks == null || !mounted) {
      return;
    }
    setState(() {
      _weeks
        ..clear()
        ..addAll(selectedWeeks);
      _errorMessage = null;
    });
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
    if (_sections.isEmpty) {
      setState(() => _errorMessage = '请选择至少一节课');
      return;
    }
    if (!_hasContinuousSections) {
      setState(() => _errorMessage = '上课节次必须连续');
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
    final selectedPeriods = _selectedSectionPeriods;
    final firstPeriod = selectedPeriods.first;
    final lastPeriod = selectedPeriods.last;
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
            periodName: _periodName(selectedPeriods),
            startTime: firstPeriod.startTime,
            endTime: lastPeriod.endTime,
            sections: [
              for (final period in selectedPeriods) period.sections.single,
            ],
            location: _locationController.text.trim(),
          ),
      ],
    );
  }

  List<PeriodDefinition> get _selectedSectionPeriods => [
    for (final period in _singleSectionPeriods)
      if (_sections.contains(period.sections.single)) period,
  ];

  bool get _hasContinuousSections {
    final indexes = [
      for (var index = 0; index < timetableSectionOrder.length; index++)
        if (_sections.contains(timetableSectionOrder[index])) index,
    ];
    if (indexes.isEmpty) {
      return false;
    }
    return indexes.last - indexes.first + 1 == indexes.length;
  }
}

class _WeekSelectionDialog extends StatefulWidget {
  const _WeekSelectionDialog({
    required this.maxWeek,
    required this.selectedWeeks,
  });

  final int maxWeek;
  final Set<int> selectedWeeks;

  @override
  State<_WeekSelectionDialog> createState() => _WeekSelectionDialogState();
}

class _WeekSelectionDialogState extends State<_WeekSelectionDialog> {
  late final Set<int> _weeks = {...widget.selectedWeeks};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择周次'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var week = 1; week <= widget.maxWeek; week++)
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
                    });
                  },
                ),
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
          key: const ValueKey('quick-add-weeks-confirm-button'),
          onPressed: () => Navigator.of(context).pop(_weeks),
          child: const Text('确定'),
        ),
      ],
    );
  }
}

String _sectionLabel(String section) => section.replaceAll('节', '');

String _periodName(List<PeriodDefinition> periods) {
  if (periods.length == 1) {
    return periods.single.name;
  }
  return '${periods.first.sections.single}至${periods.last.sections.single}';
}

String _formatMonthDay(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$month-$day';
}
