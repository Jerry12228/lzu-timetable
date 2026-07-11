import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../models/schedule_models.dart';
import '../services/imported_semester_store.dart';
import '../services/semester_importer.dart';
import 'timetable_grid.dart';

class ImportSchedulePage extends StatefulWidget {
  const ImportSchedulePage({
    super.key,
    required this.existingDisplayNames,
    required this.store,
    this.editingSemesterId,
    this.initialDisplayName,
    this.initialTermStartDate,
    this.initialSemester,
    this.initialCourseHtml,
  });

  final List<String> existingDisplayNames;
  final ImportedSemesterStore store;
  final String? editingSemesterId;
  final String? initialDisplayName;
  final DateTime? initialTermStartDate;
  final Semester? initialSemester;
  final String? initialCourseHtml;

  bool get isEditing => editingSemesterId != null;

  @override
  State<ImportSchedulePage> createState() => _ImportSchedulePageState();
}

class _ImportSchedulePageState extends State<ImportSchedulePage> {
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _htmlController = TextEditingController();

  Semester? _preview;
  String? _previewKey;
  String? _errorMessage;
  bool _isPickingFile = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialDisplayName ?? '';
    final initialDate = widget.initialTermStartDate;
    if (initialDate != null) {
      _dateController.text = _formatDate(initialDate);
    }
    _htmlController.text = widget.initialCourseHtml ?? '';
    _nameController.addListener(_invalidatePreview);
    _dateController.addListener(_invalidatePreview);
    _htmlController.addListener(_invalidatePreview);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _htmlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    final hasValidPreview = preview != null && _previewKey == _currentInputKey;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? '修改课程表' : '添加课程表'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _ImportSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const ValueKey('import-name-field'),
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '课表名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    key: const ValueKey('import-date-field'),
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: '第一周星期一日期',
                      hintText: 'yyyy-mm-dd',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: '选择日期',
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_month),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    key: const ValueKey('import-html-field'),
                    controller: _htmlController,
                    minLines: 10,
                    maxLines: 18,
                    decoration: InputDecoration(
                      labelText: widget.isEditing
                          ? '课程列表 HTML（可选，重新解析课程）'
                          : '课程列表 HTML',
                      hintText: widget.isEditing ? '留空会保留当前已解析的课程数据' : null,
                      alignLabelWithHint: true,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isPickingFile ? null : _pickHtmlFile,
                        icon: const Icon(Icons.upload_file),
                        label: Text(_isPickingFile ? '读取中...' : '上传 HTML'),
                      ),
                      FilledButton.icon(
                        key: const ValueKey('preview-import-button'),
                        onPressed: _previewHtml,
                        icon: const Icon(Icons.visibility),
                        label: const Text('预览'),
                      ),
                      FilledButton.icon(
                        key: const ValueKey('confirm-import-button'),
                        onPressed: hasValidPreview && !_isSaving
                            ? () => _confirmSchedule(preview)
                            : null,
                        icon: Icon(widget.isEditing ? Icons.save : Icons.add),
                        label: Text(
                          _isSaving
                              ? (widget.isEditing ? '保存中...' : '添加中...')
                              : (widget.isEditing ? '保存修改' : '确认添加'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 14),
              _MessageBanner(message: _errorMessage!, isError: true),
            ],
            if (preview != null && hasValidPreview) ...[
              const SizedBox(height: 14),
              _PreviewCard(key: ValueKey(_previewKey), semester: preview),
            ],
          ],
        ),
      ),
    );
  }

  String get _currentInputKey =>
      '${_nameController.text.trim()}|${_dateController.text.trim()}|${_htmlController.text}';

  void _invalidatePreview() {
    if (_preview == null && _errorMessage == null) {
      return;
    }
    setState(() {
      _preview = null;
      _previewKey = null;
      _errorMessage = null;
    });
  }

  Future<void> _pickDate() async {
    final initialDate =
        _parseDateOrNull(_dateController.text) ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      _dateController.text = _formatDate(selected);
    }
  }

  Future<void> _pickHtmlFile() async {
    setState(() {
      _isPickingFile = true;
      _errorMessage = null;
    });
    try {
      const htmlFileTypes = XTypeGroup(
        label: 'HTML 文件',
        extensions: ['html', 'htm', 'txt'],
      );
      final file = await openFile(acceptedTypeGroups: [htmlFileTypes]);
      if (file == null) {
        return;
      }
      final bytes = await file.readAsBytes();
      _htmlController.text = utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      setState(() {
        _errorMessage = '文件读取失败，请改用粘贴 HTML';
      });
    } finally {
      if (mounted) {
        setState(() => _isPickingFile = false);
      }
    }
  }

  void _previewHtml() {
    try {
      final semester = _parseInputForPreview();
      setState(() {
        _preview = semester;
        _previewKey = _currentInputKey;
        _errorMessage = null;
      });
    } catch (error) {
      setState(() {
        _preview = null;
        _previewKey = null;
        _errorMessage = _messageForError(error);
      });
    }
  }

  Future<void> _confirmSchedule(Semester preview) async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      final record = await widget.store.saveRecord(
        semesterId: widget.editingSemesterId,
        semester: preview,
        existingDisplayNames: widget.existingDisplayNames,
      );
      if (mounted) {
        Navigator.of(context).pop(record.id);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = _messageForError(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Semester _parseInputForPreview() {
    final displayName = _validatedDisplayName();
    final termStartDate = _validatedStartDate();
    final courseHtml = _htmlController.text.trim();
    if (courseHtml.isEmpty) {
      final initialSemester = widget.initialSemester;
      if (initialSemester == null) {
        throw const FormatException('请粘贴或上传课程列表 HTML');
      }
      return initialSemester.copyWith(
        id: widget.editingSemesterId ?? initialSemester.id,
        displayName: displayName,
        termStartDate: termStartDate,
      );
    }
    return SemesterImporter.parseCourseHtml(
      semesterId: widget.editingSemesterId ?? 'preview',
      displayName: displayName,
      termStartDate: termStartDate,
      courseHtml: courseHtml,
    );
  }

  String _validatedDisplayName() {
    final displayName = _nameController.text.trim();
    if (displayName.isEmpty) {
      throw const FormatException('请输入课表名称');
    }
    final names = widget.existingDisplayNames
        .map((name) => name.trim())
        .toSet();
    if (names.contains(displayName)) {
      throw DuplicateSemesterNameException(displayName);
    }
    return displayName;
  }

  DateTime _validatedStartDate() {
    final date = _parseDateOrNull(_dateController.text);
    if (date == null) {
      throw const FormatException('请输入有效的第一周星期一日期，例如 2026-02-23');
    }
    if (date.weekday != DateTime.monday) {
      throw const FormatException('第一周星期一日期必须是星期一');
    }
    return date;
  }

  String _messageForError(Object error) {
    if (error is DuplicateSemesterNameException) {
      return '课表名称已存在，请修改名称';
    }
    if (error is FormatException) {
      return error.message;
    }
    return '导入失败，请确认 HTML 内容来自课程列表页面';
  }
}

class _ImportSection extends StatelessWidget {
  const _ImportSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? scheme.errorContainer : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? scheme.onErrorContainer : scheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PreviewCard extends StatefulWidget {
  const _PreviewCard({super.key, required this.semester});

  final Semester semester;

  @override
  State<_PreviewCard> createState() => _PreviewCardState();
}

class _PreviewCardState extends State<_PreviewCard> {
  int _selectedWeek = 1;

  @override
  void didUpdateWidget(covariant _PreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedWeek > widget.semester.maxWeek) {
      _selectedWeek = widget.semester.maxWeek;
    }
  }

  @override
  Widget build(BuildContext context) {
    final semester = widget.semester;
    final compact = MediaQuery.sizeOf(context).width < 760;
    final scheduled = semester.scheduledCoursesForWeek(_selectedWeek);
    return _ImportSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '预览结果',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _PreviewLine(label: '课程总数', value: '${semester.courses.length} 门'),
          _PreviewLine(label: '最大周次', value: '第 ${semester.maxWeek} 周'),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: DropdownButtonFormField<int>(
              key: const ValueKey('preview-week-dropdown'),
              initialValue: _selectedWeek,
              decoration: const InputDecoration(
                labelText: '预览周次',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                for (var week = 1; week <= semester.maxWeek; week++)
                  DropdownMenuItem(value: week, child: Text('第$week周')),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() => _selectedWeek = value);
              },
            ),
          ),
          const SizedBox(height: 10),
          TimetableGrid(
            compact: compact,
            scheduled: scheduled,
            weekDateRange: semester.dateRangeForWeek(_selectedWeek),
            onCourseTap: (course, session) =>
                _showPreviewCourseDetails(context, course, session),
          ),
        ],
      ),
    );
  }

  void _showPreviewCourseDetails(
    BuildContext context,
    Course course,
    CourseSession? session,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) =>
          _PreviewCourseDialog(course: course, session: session),
    );
  }
}

class _PreviewLine extends StatelessWidget {
  const _PreviewLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
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

class _PreviewCourseDialog extends StatelessWidget {
  const _PreviewCourseDialog({required this.course, required this.session});

  final Course course;
  final CourseSession? session;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(course.name),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PreviewLine(label: '课程号', value: course.courseCode),
            _PreviewLine(label: '任课教师', value: course.teachers.join('、')),
            _PreviewLine(label: '学分', value: course.credits),
            _PreviewLine(label: '考核方式', value: course.assessment),
            if (session != null) ...[
              const SizedBox(height: 8),
              _PreviewLine(label: '周次', value: '第${session!.week}周'),
              _PreviewLine(label: '星期', value: session!.weekdayText),
              _PreviewLine(label: '节次', value: session!.periodName),
              _PreviewLine(
                label: '地点',
                value: session!.location.isEmpty ? '地点未公布' : session!.location,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}

DateTime? _parseDateOrNull(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value.trim());
  if (match == null) {
    return null;
  }
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }
  return date;
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
