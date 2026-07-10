import 'package:flutter/material.dart';

import '../models/schedule_models.dart';
import '../services/semester_importer.dart';

class CourseEditorPage extends StatefulWidget {
  const CourseEditorPage({
    super.key,
    required this.semester,
    required this.course,
  });

  final Semester semester;
  final Course course;

  @override
  State<CourseEditorPage> createState() => _CourseEditorPageState();
}

class _CourseEditorPageState extends State<CourseEditorPage> {
  final _nameController = TextEditingController();
  final _teachersController = TextEditingController();
  final _creditsController = TextEditingController();
  final _selectionTypeController = TextEditingController();
  final _assessmentController = TextEditingController();
  final _examNatureController = TextEditingController();
  final _deferredExamController = TextEditingController();
  final _materialController = TextEditingController();
  final _selectedSessionIndexes = <int>{};
  late List<CourseSession> _sessions;

  @override
  void initState() {
    super.initState();
    final course = widget.course;
    _nameController.text = course.name;
    _teachersController.text = course.teachers.join('、');
    _creditsController.text = course.credits;
    _selectionTypeController.text = course.selectionType;
    _assessmentController.text = course.assessment;
    _examNatureController.text = course.examNature;
    _deferredExamController.text = course.deferredExam;
    _materialController.text = course.material;
    _sessions = [...course.sessions];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teachersController.dispose();
    _creditsController.dispose();
    _selectionTypeController.dispose();
    _assessmentController.dispose();
    _examNatureController.dispose();
    _deferredExamController.dispose();
    _materialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑课程'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            key: const ValueKey('delete-course-button'),
            tooltip: '删除课程',
            onPressed: _requestDeleteCourse,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const _EditorHeading('课程信息'),
            _ReadonlyRow(label: '课程号', value: widget.course.courseCode),
            _ReadonlyRow(label: '课程序号', value: widget.course.sequence),
            const SizedBox(height: 10),
            TextField(
              key: const ValueKey('course-name-field'),
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '课程名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('course-teachers-field'),
              controller: _teachersController,
              decoration: const InputDecoration(
                labelText: '任课教师',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _creditsController,
              decoration: const InputDecoration(
                labelText: '学分',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _selectionTypeController,
              decoration: const InputDecoration(
                labelText: '选课属性',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _assessmentController,
              decoration: const InputDecoration(
                labelText: '考核方式',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _examNatureController,
              decoration: const InputDecoration(
                labelText: '考试性质',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _deferredExamController,
              decoration: const InputDecoration(
                labelText: '缓考状态',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _materialController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '教材',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: _EditorHeading('上课节次')),
                if (_selectedSessionIndexes.isNotEmpty)
                  IconButton(
                    key: const ValueKey('delete-selected-sessions-button'),
                    tooltip: '删除所选节次',
                    onPressed: _requestDeleteSelectedSessions,
                    icon: const Icon(Icons.delete_outline),
                  ),
                IconButton(
                  key: const ValueKey('add-session-button'),
                  tooltip: '新增节次',
                  onPressed: () => _editSession(),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (_sessions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Text('暂无固定上课节次'),
              )
            else
              for (var index = 0; index < _sessions.length; index++)
                _SessionEditorRow(
                  session: _sessions[index],
                  selected: _selectedSessionIndexes.contains(index),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSessionIndexes.add(index);
                      } else {
                        _selectedSessionIndexes.remove(index);
                      }
                    });
                  },
                  onEdit: () => _editSession(index: index),
                ),
            const SizedBox(height: 92),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            key: const ValueKey('save-course-button'),
            onPressed: _saveCourse,
            icon: const Icon(Icons.save),
            label: const Text('保存课程'),
          ),
        ),
      ),
    );
  }

  Future<void> _editSession({int? index}) async {
    final updated = await showDialog<CourseSession>(
      context: context,
      builder: (context) => _CourseSessionEditorDialog(
        periods: widget.semester.periods,
        initialSession: index == null ? null : _sessions[index],
      ),
    );
    if (updated == null || !mounted) {
      return;
    }
    setState(() {
      if (index == null) {
        _sessions.add(updated);
      } else {
        _sessions[index] = updated;
      }
      _selectedSessionIndexes.clear();
    });
  }

  Future<void> _requestDeleteSelectedSessions() async {
    final shouldDelete = await _confirm(
      title: '删除所选节次',
      message: '确定删除已选的 ${_selectedSessionIndexes.length} 个节次吗？',
    );
    if (!shouldDelete || !mounted) {
      return;
    }
    setState(() {
      _sessions = [
        for (var index = 0; index < _sessions.length; index++)
          if (!_selectedSessionIndexes.contains(index)) _sessions[index],
      ];
      _selectedSessionIndexes.clear();
    });
  }

  Future<void> _requestDeleteCourse() async {
    final shouldDelete = await _confirm(
      title: '删除课程',
      message: '确定删除“${widget.course.name}”吗？删除后将不再显示在课表中。',
    );
    if (shouldDelete && mounted) {
      Navigator.of(context).pop(CourseCustomization.deleted(widget.course));
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('删除'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _saveCourse() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入课程名称')));
      return;
    }
    Navigator.of(context).pop(
      CourseCustomization(
        courseKey: CourseKey.fromCourse(widget.course),
        metadata: CourseMetadata(
          name: name,
          teachers: _splitTeachers(_teachersController.text),
          credits: _creditsController.text.trim(),
          selectionType: _selectionTypeController.text.trim(),
          assessment: _assessmentController.text.trim(),
          examNature: _examNatureController.text.trim(),
          deferredExam: _deferredExamController.text.trim(),
          material: _materialController.text.trim(),
        ),
        sessions: List.unmodifiable(_sessions),
      ),
    );
  }
}

class _EditorHeading extends StatelessWidget {
  const _EditorHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
  );
}

class _ReadonlyRow extends StatelessWidget {
  const _ReadonlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _SessionEditorRow extends StatelessWidget {
  const _SessionEditorRow({
    required this.session,
    required this.selected,
    required this.onSelected,
    required this.onEdit,
  });

  final CourseSession session;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Checkbox(
            value: selected,
            onChanged: (value) => onSelected(value ?? false),
          ),
          title: Text(
            '${session.weekRule.rawText} · ${session.weekdayText} · ${session.periodName}',
          ),
          subtitle: Text(
            '${session.startTime}-${session.endTime} · ${session.location.isEmpty ? '地点未公布' : session.location}',
          ),
          trailing: IconButton(
            tooltip: '编辑节次',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

class _CourseSessionEditorDialog extends StatefulWidget {
  const _CourseSessionEditorDialog({
    required this.periods,
    required this.initialSession,
  });

  final List<PeriodDefinition> periods;
  final CourseSession? initialSession;

  @override
  State<_CourseSessionEditorDialog> createState() =>
      _CourseSessionEditorDialogState();
}

class _CourseSessionEditorDialogState
    extends State<_CourseSessionEditorDialog> {
  final _weekRuleController = TextEditingController();
  final _locationController = TextEditingController();
  String? _errorMessage;
  late int _weekday;
  late String _periodName;

  @override
  void initState() {
    super.initState();
    final session = widget.initialSession;
    _weekRuleController.text = session?.weekRule.rawText ?? '';
    _locationController.text = session?.location ?? '';
    _weekday = session?.weekday ?? 1;
    _periodName =
        widget.periods.any((period) => period.name == session?.periodName)
        ? session!.periodName
        : widget.periods.first.name;
  }

  @override
  void dispose() {
    _weekRuleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialSession == null ? '新增节次' : '编辑节次'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const ValueKey('session-week-rule-field'),
                controller: _weekRuleController,
                decoration: const InputDecoration(
                  labelText: '周次规则',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
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
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _weekday = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _periodName,
                decoration: const InputDecoration(
                  labelText: '上课大节',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final period in widget.periods)
                    DropdownMenuItem(
                      value: period.name,
                      child: Text(period.name),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _periodName = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: '地点',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
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
        FilledButton(onPressed: _save, child: const Text('保存')),
      ],
    );
  }

  void _save() {
    try {
      final period = widget.periods.firstWhere(
        (item) => item.name == _periodName,
      );
      final session = CourseSession(
        weekRule: SemesterImporter.parseWeekRule(
          _weekRuleController.text.trim(),
        ),
        weekday: _weekday,
        weekdayText: weekdays[_weekday - 1],
        periodName: period.name,
        startTime: period.startTime,
        endTime: period.endTime,
        sections: period.sections,
        location: _locationController.text.trim(),
      );
      Navigator.of(context).pop(session);
    } on FormatException catch (error) {
      setState(() => _errorMessage = error.message);
    }
  }
}

List<String> _splitTeachers(String value) {
  return value
      .split(RegExp(r'[、，,]'))
      .map((teacher) => teacher.trim())
      .where((teacher) => teacher.isNotEmpty)
      .toList();
}
