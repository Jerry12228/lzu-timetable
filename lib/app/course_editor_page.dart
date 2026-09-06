import 'package:flutter/material.dart';

import '../models/schedule_models.dart';
import '../models/timetable_sections.dart';
import 'section_button_grid.dart';

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
  final _courseLocationController = TextEditingController();
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
    _syncCourseLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teachersController.dispose();
    _courseLocationController.dispose();
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
        backgroundColor: Theme.of(context).colorScheme.surface,
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
            if (widget.course.isManual)
              const _ReadonlyRow(label: '课程来源', value: '手动添加')
            else ...[
              _ReadonlyRow(label: '课程号', value: widget.course.courseCode ?? ''),
              _ReadonlyRow(label: '课程序号', value: widget.course.sequence ?? ''),
            ],
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
              key: const ValueKey('course-location-field'),
              controller: _courseLocationController,
              enabled: _sessions.isNotEmpty,
              onChanged: _updateAllLocations,
              decoration: InputDecoration(
                labelText: '上课地点（可选）',
                hintText: _hasMixedLocations ? '-' : null,
                helperText: _sessions.isEmpty
                    ? '暂无上课安排，请先新增节次'
                    : '修改后应用于所有上课安排',
                helperMaxLines: 2,
                border: const OutlineInputBorder(),
                suffixIcon:
                    _sessions.any((session) => session.location.isNotEmpty)
                    ? IconButton(
                        tooltip: '清空所有地点',
                        onPressed: () {
                          _courseLocationController.clear();
                          _updateAllLocations('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
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
                IconButton(
                  key: const ValueKey('add-session-button'),
                  tooltip: '新增节次',
                  onPressed: () => _editSession(),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (_selectedSessionIndexes.isNotEmpty)
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('已选 ${_selectedSessionIndexes.length} 项'),
                  TextButton.icon(
                    key: const ValueKey('edit-selected-locations-button'),
                    onPressed: _editSelectedLocations,
                    icon: const Icon(Icons.edit_location_alt_outlined),
                    label: const Text('修改地点'),
                  ),
                  IconButton(
                    key: const ValueKey('delete-selected-sessions-button'),
                    tooltip: '删除所选节次',
                    onPressed: _requestDeleteSelectedSessions,
                    icon: const Icon(Icons.delete_outline),
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
                  key: ValueKey('session-row-$index'),
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

  bool get _hasMixedLocations =>
      _sessions.map((session) => session.location).toSet().length > 1;

  void _syncCourseLocation() {
    // A mixed location is a hint, never a value written back to the sessions.
    _courseLocationController.text = _sessions.isEmpty || _hasMixedLocations
        ? ''
        : _sessions.first.location;
  }

  void _updateAllLocations(String value) {
    final location = value.trim();
    setState(() {
      _sessions = [
        for (final session in _sessions) session.copyWith(location: location),
      ];
    });
  }

  Future<void> _editSession({int? index}) async {
    final updated = await showDialog<CourseSession>(
      context: context,
      builder: (context) => _CourseSessionEditorDialog(
        maxWeek: widget.semester.maxWeek,
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
      _syncCourseLocation();
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
      _syncCourseLocation();
    });
  }

  Future<void> _editSelectedLocations() async {
    final selected = {..._selectedSessionIndexes};
    final location = await showDialog<String>(
      context: context,
      builder: (context) => _BulkLocationDialog(
        selectedCount: selected.length,
        locations: {for (final index in selected) _sessions[index].location},
      ),
    );
    if (location == null || !mounted) return;
    setState(() {
      for (final index in selected) {
        _sessions[index] = _sessions[index].copyWith(location: location);
      }
      _selectedSessionIndexes.clear();
      _syncCourseLocation();
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
        courseId: widget.course.id,
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
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
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
    super.key,
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
            '第${session.week}周 · ${session.weekdayText} · ${session.periodName}',
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
    required this.maxWeek,
    required this.initialSession,
  });

  final int maxWeek;
  final CourseSession? initialSession;

  @override
  State<_CourseSessionEditorDialog> createState() =>
      _CourseSessionEditorDialogState();
}

class _CourseSessionEditorDialogState
    extends State<_CourseSessionEditorDialog> {
  final _locationController = TextEditingController();
  late int _week;
  late int _weekday;
  late Set<String> _sections;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final session = widget.initialSession;
    _locationController.text = session?.location ?? '';
    _week = session?.week ?? 1;
    _weekday = session?.weekday ?? 1;
    _sections = {
      ...(session?.sections ?? const []),
      if (session == null) TimetableSections.all.first.id,
    };
  }

  @override
  void dispose() {
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                key: const ValueKey('session-week-dropdown'),
                initialValue: _week,
                decoration: const InputDecoration(
                  labelText: '周次',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (var week = 1; week <= widget.maxWeek; week++)
                    DropdownMenuItem(value: week, child: Text('第$week周')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _week = value);
                  }
                },
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
              const Text('上课节次', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              SectionButtonGrid(
                selectedSections: _sections,
                keyPrefix: 'session-section',
                onToggle: _toggleSection,
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('session-location-field'),
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: '上课地点（可选）',
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
    if (_sections.isEmpty) {
      setState(() => _errorMessage = '请选择至少一节课');
      return;
    }
    if (!_hasContinuousSections) {
      setState(() => _errorMessage = '上课节次必须连续');
      return;
    }
    final selectedOrders = [
      for (final section in TimetableSections.all)
        if (_sections.contains(section.id)) section.order,
    ];
    final session = CourseSession(
      week: _week,
      weekday: _weekday,
      startSection: selectedOrders.first,
      endSection: selectedOrders.last,
      location: _locationController.text.trim(),
    );
    Navigator.of(context).pop(session);
  }

  bool get _hasContinuousSections {
    final indexes = [
      for (var index = 0; index < timetableSectionOrder.length; index++)
        if (_sections.contains(timetableSectionOrder[index])) index,
    ];
    return indexes.isNotEmpty &&
        indexes.last - indexes.first + 1 == indexes.length;
  }

  void _toggleSection(String section) {
    setState(() {
      if (_sections.contains(section)) {
        _sections.remove(section);
      } else {
        _sections.add(section);
      }
      _errorMessage = null;
    });
  }
}

class _BulkLocationDialog extends StatefulWidget {
  const _BulkLocationDialog({
    required this.selectedCount,
    required this.locations,
  });

  final int selectedCount;
  final Set<String> locations;

  @override
  State<_BulkLocationDialog> createState() => _BulkLocationDialogState();
}

class _BulkLocationDialogState extends State<_BulkLocationDialog> {
  late final _controller = TextEditingController(
    text: widget.locations.length == 1 ? widget.locations.single : '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('批量修改地点'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('已选 ${widget.selectedCount} 条上课安排'),
              if (widget.locations.length > 1) ...[
                const SizedBox(height: 8),
                const Text('所选安排存在不同地点，保存后将统一修改。'),
              ],
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('bulk-location-field'),
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: '上课地点（可选）',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              const Text('留空将清除所选安排的地点'),
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
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('保存'),
        ),
      ],
    );
  }
}

List<String> _splitTeachers(String value) {
  return value
      .split(RegExp(r'[、，,]'))
      .map((teacher) => teacher.trim())
      .where((teacher) => teacher.isNotEmpty)
      .toList();
}
