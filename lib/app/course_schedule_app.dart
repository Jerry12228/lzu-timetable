import 'package:flutter/material.dart';

import 'course_schedule_management_page.dart';
import 'timetable_grid.dart';
import '../models/schedule_models.dart';
import '../services/imported_semester_store.dart';
import '../services/sample_semester_loader.dart';

class CourseScheduleApp extends StatelessWidget {
  const CourseScheduleApp({
    super.key,
    this.semestersFuture,
    this.importedSemesterStore,
  });

  final Future<List<Semester>>? semestersFuture;
  final ImportedSemesterStore? importedSemesterStore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '课程表',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
      ),
      home: _SemesterBootstrap(
        semestersFuture: semestersFuture,
        importedSemesterStore: importedSemesterStore,
      ),
    );
  }
}

class _SemesterBootstrap extends StatefulWidget {
  const _SemesterBootstrap({
    required this.semestersFuture,
    required this.importedSemesterStore,
  });

  final Future<List<Semester>>? semestersFuture;
  final ImportedSemesterStore? importedSemesterStore;

  @override
  State<_SemesterBootstrap> createState() => _SemesterBootstrapState();
}

class _SemesterBootstrapState extends State<_SemesterBootstrap> {
  late final ImportedSemesterStore _importedSemesterStore =
      widget.importedSemesterStore ?? ImportedSemesterStore();
  late Future<List<Semester>> _semestersFuture = _loadSemesters();
  String? _selectedSemesterId;

  Future<List<Semester>> _loadBundledSemesters() =>
      widget.semestersFuture ?? const SampleSemesterLoader().load();

  Future<List<Semester>> _loadSemesters() async {
    final bundled = await _loadBundledSemesters();
    final imported = await _importedSemesterStore.loadSemesters();
    final hiddenBundledIds = await _importedSemesterStore
        .loadHiddenBundledSemesterIds();
    final importedIds = {for (final semester in imported) semester.id};
    return [
      for (final semester in bundled)
        if (!hiddenBundledIds.contains(semester.id) &&
            !importedIds.contains(semester.id))
          semester,
      ...imported,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Semester>>(
      future: _semestersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LoadingScreen();
        }
        if (snapshot.hasError) {
          return _ErrorScreen(message: snapshot.error.toString());
        }
        final semesters = snapshot.data ?? const [];
        if (semesters.isEmpty) {
          return _EmptyScheduleScreen(onManageRequested: _openManagementPage);
        }
        return ScheduleHome(
          semesters: semesters,
          selectedSemesterId: _selectedSemesterId,
          onManageRequested: _openManagementPage,
        );
      },
    );
  }

  Future<void> _openManagementPage() async {
    final result = await Navigator.of(context)
        .push<CourseScheduleManagementResult>(
          MaterialPageRoute(
            builder: (context) => CourseScheduleManagementPage(
              store: _importedSemesterStore,
              loadSemesters: _loadSemesters,
            ),
          ),
        );
    if (result == null || !result.changed || !mounted) {
      return;
    }
    setState(() {
      if (result.selectedSemesterId != null) {
        _selectedSemesterId = result.selectedSemesterId;
      }
      _semestersFuture = _loadSemesters();
    });
  }
}

class ScheduleHome extends StatefulWidget {
  const ScheduleHome({
    super.key,
    required this.semesters,
    this.selectedSemesterId,
    this.onManageRequested,
  });

  final List<Semester> semesters;
  final String? selectedSemesterId;
  final VoidCallback? onManageRequested;

  @override
  State<ScheduleHome> createState() => _ScheduleHomeState();
}

class _ScheduleHomeState extends State<ScheduleHome> {
  late Semester _selectedSemester;
  int _selectedWeek = 1;

  @override
  void initState() {
    super.initState();
    _selectedSemester =
        _semesterForId(widget.selectedSemesterId) ?? widget.semesters.first;
  }

  @override
  void didUpdateWidget(covariant ScheduleHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    final requestedSemester = _semesterForId(widget.selectedSemesterId);
    if (widget.selectedSemesterId != oldWidget.selectedSemesterId &&
        requestedSemester != null) {
      _selectedSemester = requestedSemester;
      _selectedWeek = 1;
      return;
    }
    if (!widget.semesters.any(
      (semester) => semester.id == _selectedSemester.id,
    )) {
      _selectedSemester = widget.semesters.first;
      _selectedWeek = 1;
    }
    if (_selectedWeek > _selectedSemester.maxWeek) {
      _selectedWeek = _selectedSemester.maxWeek;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('课程表'),
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        actions: [
          if (mobile)
            _MobileScheduleMenu(
              semesters: widget.semesters,
              selectedSemester: _selectedSemester,
              onSemesterChanged: _selectSemester,
              onManageRequested: widget.onManageRequested,
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: TextButton.icon(
                key: const ValueKey('open-manage-schedules-button'),
                onPressed: widget.onManageRequested,
                icon: const Icon(Icons.settings_outlined),
                label: const Text('管理'),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 920;
            final scheduled = _selectedSemester.scheduledCoursesForWeek(
              _selectedWeek,
            );
            return Column(
              children: [
                _ScheduleControls(
                  compact: compact,
                  showSemesterSelector: !mobile,
                  semesters: widget.semesters,
                  selectedSemester: _selectedSemester,
                  selectedWeek: _selectedWeek,
                  onSemesterChanged: _selectSemester,
                  onWeekChanged: (week) => setState(() => _selectedWeek = week),
                ),
                Expanded(
                  child: TimetableGrid(
                    compact: compact,
                    scheduled: scheduled,
                    weekDateRange: _selectedSemester.dateRangeForWeek(
                      _selectedWeek,
                    ),
                    onCourseTap: _showCourseDetails,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _selectSemester(Semester semester) {
    setState(() {
      _selectedSemester = semester;
      _selectedWeek = _selectedWeek.clamp(1, semester.maxWeek);
    });
  }

  void _showCourseDetails(Course course, CourseSession? session) {
    showDialog<void>(
      context: context,
      builder: (context) =>
          _CourseDetailDialog(course: course, session: session),
    );
  }

  Semester? _semesterForId(String? id) {
    if (id == null) {
      return null;
    }
    for (final semester in widget.semesters) {
      if (semester.id == id) {
        return semester;
      }
    }
    return null;
  }
}

class _ScheduleControls extends StatelessWidget {
  const _ScheduleControls({
    required this.compact,
    required this.showSemesterSelector,
    required this.semesters,
    required this.selectedSemester,
    required this.selectedWeek,
    required this.onSemesterChanged,
    required this.onWeekChanged,
  });

  final bool compact;
  final bool showSemesterSelector;
  final List<Semester> semesters;
  final Semester selectedSemester;
  final int selectedWeek;
  final ValueChanged<Semester> onSemesterChanged;
  final ValueChanged<int> onWeekChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        compact ? 12 : 20,
        12,
        compact ? 12 : 20,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showSemesterSelector)
                  _SemesterDropdown(
                    semesters: semesters,
                    selectedSemester: selectedSemester,
                    onChanged: onSemesterChanged,
                  ),
                if (showSemesterSelector) const SizedBox(height: 10),
                _WeekDropdown(
                  maxWeek: selectedSemester.maxWeek,
                  selectedWeek: selectedWeek,
                  onChanged: onWeekChanged,
                ),
              ],
            )
          : Row(
              children: [
                if (showSemesterSelector)
                  SizedBox(
                    width: 260,
                    child: _SemesterDropdown(
                      semesters: semesters,
                      selectedSemester: selectedSemester,
                      onChanged: onSemesterChanged,
                    ),
                  ),
                if (showSemesterSelector) const SizedBox(width: 12),
                SizedBox(
                  width: 160,
                  child: _WeekDropdown(
                    maxWeek: selectedSemester.maxWeek,
                    selectedWeek: selectedWeek,
                    onChanged: onWeekChanged,
                  ),
                ),
              ],
            ),
    );
  }
}

class _MobileScheduleMenu extends StatelessWidget {
  const _MobileScheduleMenu({
    required this.semesters,
    required this.selectedSemester,
    required this.onSemesterChanged,
    required this.onManageRequested,
  });

  final List<Semester> semesters;
  final Semester selectedSemester;
  final ValueChanged<Semester> onSemesterChanged;
  final VoidCallback? onManageRequested;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MobileScheduleMenuAction>(
      key: const ValueKey('mobile-schedule-menu-button'),
      tooltip: '课程表菜单',
      icon: const Icon(Icons.menu),
      onSelected: (action) {
        if (action.opensManagement) {
          onManageRequested?.call();
          return;
        }
        final semester = action.semester;
        if (semester != null) {
          onSemesterChanged(semester);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          enabled: false,
          child: Text('学期', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        for (final semester in semesters)
          PopupMenuItem(
            value: _MobileScheduleMenuAction.semester(semester),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: semester.id == selectedSemester.id
                      ? const Icon(Icons.check, size: 18)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    semester.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: _MobileScheduleMenuAction.management(),
          child: Row(
            children: [
              Icon(Icons.settings_outlined),
              SizedBox(width: 12),
              Text('管理课程表'),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileScheduleMenuAction {
  const _MobileScheduleMenuAction.semester(this.semester)
    : opensManagement = false;

  const _MobileScheduleMenuAction.management()
    : semester = null,
      opensManagement = true;

  final Semester? semester;
  final bool opensManagement;
}

class _SemesterDropdown extends StatelessWidget {
  const _SemesterDropdown({
    required this.semesters,
    required this.selectedSemester,
    required this.onChanged,
  });

  final List<Semester> semesters;
  final Semester selectedSemester;
  final ValueChanged<Semester> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey(selectedSemester.id),
      initialValue: selectedSemester.id,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: '学期',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: semesters
          .map(
            (semester) => DropdownMenuItem(
              value: semester.id,
              child: Text(semester.displayName),
            ),
          )
          .toList(),
      onChanged: (id) {
        final semester = semesters.firstWhere((semester) => semester.id == id);
        onChanged(semester);
      },
    );
  }
}

class _WeekDropdown extends StatelessWidget {
  const _WeekDropdown({
    required this.maxWeek,
    required this.selectedWeek,
    required this.onChanged,
  });

  final int maxWeek;
  final int selectedWeek;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      key: ValueKey(selectedWeek),
      initialValue: selectedWeek,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: '周次',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        for (var week = 1; week <= maxWeek; week++)
          DropdownMenuItem(value: week, child: Text('第$week周')),
      ],
      onChanged: (week) {
        if (week != null) {
          onChanged(week);
        }
      },
    );
  }
}

class _CourseDetailDialog extends StatelessWidget {
  const _CourseDetailDialog({required this.course, required this.session});

  final Course course;
  final CourseSession? session;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(course.name),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (session != null) ...[
                _ActiveSessionBanner(session: session!),
                const SizedBox(height: 14),
              ],
              _DetailRow(label: '课程号', value: course.courseCode),
              _DetailRow(label: '课程序号', value: course.sequence),
              _DetailRow(label: '任课教师', value: course.teachers.join('、')),
              _DetailRow(label: '学分', value: course.credits),
              _DetailRow(label: '选课属性', value: course.selectionType),
              _DetailRow(label: '考核方式', value: course.assessment),
              _DetailRow(label: '考试性质', value: course.examNature),
              _DetailRow(label: '缓考状态', value: course.deferredExam),
              _DetailRow(
                label: '教材',
                value: course.material.isEmpty ? '无' : course.material,
              ),
              const SizedBox(height: 12),
              const Text('上课安排', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (course.sessions.isEmpty)
                const Text('暂无固定上课时间')
              else
                Column(
                  children: [
                    for (final item in course.sessions)
                      _SessionDetail(session: item),
                  ],
                ),
              if (_hasAnyLink(course)) ...[
                const SizedBox(height: 12),
                const Text(
                  '相关链接',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                if (course.courseDetailLink != null)
                  _DetailRow(label: '课程详情', value: course.courseDetailLink!),
                if (course.teachingRecordLink != null)
                  _DetailRow(label: '教学记录', value: course.teachingRecordLink!),
                if (course.processScoreLink != null)
                  _DetailRow(label: '过程性成绩', value: course.processScoreLink!),
              ],
            ],
          ),
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

class _ActiveSessionBanner extends StatelessWidget {
  const _ActiveSessionBanner({required this.session});

  final CourseSession session;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${session.weekdayText} ${session.periodName} ${session.startTime}-${session.endTime}'
        ' · ${session.location.isEmpty ? '地点未公布' : session.location}',
        style: TextStyle(color: scheme.onPrimaryContainer),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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
            width: 82,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? '无' : value)),
        ],
      ),
    );
  }
}

class _SessionDetail extends StatelessWidget {
  const _SessionDetail({required this.session});

  final CourseSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${session.weekRule.rawText} · ${session.weekdayText} · ${session.periodName}'
        ' · ${session.startTime}-${session.endTime}'
        ' · ${session.location.isEmpty ? '地点未公布' : session.location}',
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

class _EmptyScheduleScreen extends StatelessWidget {
  const _EmptyScheduleScreen({required this.onManageRequested});

  final VoidCallback onManageRequested;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('课程表'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('还没有课程表'),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onManageRequested,
                icon: const Icon(Icons.settings_outlined),
                label: const Text('管理课程表'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _hasAnyLink(Course course) =>
    course.courseDetailLink != null ||
    course.teachingRecordLink != null ||
    course.processScoreLink != null;
