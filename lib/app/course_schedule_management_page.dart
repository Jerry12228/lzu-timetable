import 'package:flutter/material.dart';

import '../models/schedule_models.dart';
import '../services/imported_semester_store.dart';
import 'import_schedule_page.dart';

class CourseScheduleManagementResult {
  const CourseScheduleManagementResult({
    required this.changed,
    this.selectedSemesterId,
  });

  final bool changed;
  final String? selectedSemesterId;
}

class CourseScheduleManagementPage extends StatefulWidget {
  const CourseScheduleManagementPage({
    super.key,
    required this.loadSemesters,
    required this.store,
  });

  final Future<List<Semester>> Function() loadSemesters;
  final ImportedSemesterStore store;

  @override
  State<CourseScheduleManagementPage> createState() =>
      _CourseScheduleManagementPageState();
}

class _CourseScheduleManagementPageState
    extends State<CourseScheduleManagementPage> {
  late Future<List<_ManagedSemester>> _entriesFuture = _loadEntries();
  bool _changed = false;
  bool _canPop = false;
  String? _selectedSemesterId;

  Future<List<_ManagedSemester>> _loadEntries() async {
    final results = await Future.wait<Object>([
      widget.loadSemesters(),
      widget.store.loadRecords(),
    ]);
    final semesters = results[0] as List<Semester>;
    final records = results[1] as List<ImportedSemesterRecord>;
    final recordsById = {for (final record in records) record.id: record};
    return [
      for (final semester in semesters)
        _ManagedSemester(semester: semester, record: recordsById[semester.id]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _finish();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: '返回课程表',
            onPressed: _finish,
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('管理课程表'),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                key: const ValueKey('manage-add-schedule-button'),
                onPressed: () => _openEditor(),
                icon: const Icon(Icons.add),
                label: const Text('添加'),
              ),
            ),
          ],
        ),
        body: FutureBuilder<List<_ManagedSemester>>(
          future: _entriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(snapshot.error.toString()),
                ),
              );
            }
            final entries = snapshot.data ?? const <_ManagedSemester>[];
            if (entries.isEmpty) {
              return _EmptyManagementState(onAdd: _openEditor);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Text(
                      '课程表',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                }
                final entry = entries[index - 1];
                return _ScheduleListItem(
                  entry: entry,
                  onEdit: () => _openEditor(entry: entry),
                  onDelete: () => _requestDelete(entry),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _openEditor({_ManagedSemester? entry}) async {
    final entries = await _entriesFuture;
    if (!mounted) {
      return;
    }
    final semester = entry?.semester;
    final updatedId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => ImportSchedulePage(
          existingDisplayNames: [
            for (final item in entries)
              if (item.semester.id != semester?.id) item.semester.displayName,
          ],
          store: widget.store,
          editingSemesterId: semester?.id,
          initialDisplayName: semester?.displayName,
          initialTermStartDate: semester?.termStartDate,
          initialCourseHtml:
              entry?.record?.courseHtml ?? semester?.sourceCourseHtml,
        ),
      ),
    );
    if (updatedId == null || !mounted) {
      return;
    }
    _changed = true;
    _selectedSemesterId = updatedId;
    setState(() {
      _entriesFuture = _loadEntries();
    });
  }

  Future<void> _requestDelete(_ManagedSemester entry) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除课程表'),
        content: Text('确定删除“${entry.semester.displayName}”吗？删除后不可恢复。'),
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
    );
    if (shouldDelete != true || !mounted) {
      return;
    }
    await widget.store.deleteSemester(entry.semester.id);
    if (!mounted) {
      return;
    }
    _changed = true;
    if (_selectedSemesterId == entry.semester.id) {
      _selectedSemesterId = null;
    }
    setState(() {
      _entriesFuture = _loadEntries();
    });
  }

  void _finish() {
    if (_canPop) {
      return;
    }
    setState(() => _canPop = true);
    Navigator.of(context).pop(
      CourseScheduleManagementResult(
        changed: _changed,
        selectedSemesterId: _selectedSemesterId,
      ),
    );
  }
}

class _ManagedSemester {
  const _ManagedSemester({required this.semester, required this.record});

  final Semester semester;
  final ImportedSemesterRecord? record;
}

class _ScheduleListItem extends StatelessWidget {
  const _ScheduleListItem({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final _ManagedSemester entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final semester = entry.semester;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          semester.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '${_formatDate(semester.termStartDate)}起 · ${semester.courses.length} 门课程',
          ),
        ),
        trailing: SizedBox(
          width: 96,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                key: ValueKey('edit-schedule-${semester.id}'),
                tooltip: '修改课程表',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                key: ValueKey('delete-schedule-${semester.id}'),
                tooltip: '删除课程表',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyManagementState extends StatelessWidget {
  const _EmptyManagementState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('还没有课程表'),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('添加课程表'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) {
    return '未设置第一周日期';
  }
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
