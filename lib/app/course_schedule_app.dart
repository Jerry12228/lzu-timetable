import 'package:flutter/material.dart';

import 'course_editor_page.dart';
import 'course_schedule_management_page.dart';
import 'quick_add_course_dialog.dart';
import 'timetable_grid.dart';
import '../models/schedule_models.dart';
import '../services/course_customization_store.dart';
import '../services/imported_semester_store.dart';
import '../services/theme_preference_store.dart';

class CourseScheduleApp extends StatefulWidget {
  const CourseScheduleApp({
    super.key,
    this.semestersFuture,
    this.importedSemesterStore,
    this.courseCustomizationStore,
    this.themePreferenceStore,
    this.currentDate,
  });

  final Future<List<Semester>>? semestersFuture;
  final ImportedSemesterStore? importedSemesterStore;
  final CourseCustomizationStore? courseCustomizationStore;
  final ThemePreferenceStore? themePreferenceStore;
  final DateTime? currentDate;

  @override
  State<CourseScheduleApp> createState() => _CourseScheduleAppState();
}

class _CourseScheduleAppState extends State<CourseScheduleApp> {
  late final ThemePreferenceStore _themePreferenceStore =
      widget.themePreferenceStore ?? ThemePreferenceStore();
  AppThemePreference _themePreference = AppThemePreference.system;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LZU Timetable',
      theme: _buildAppTheme(Brightness.light),
      darkTheme: _buildAppTheme(Brightness.dark),
      themeMode: _themeModeFor(_themePreference),
      home: _SemesterBootstrap(
        semestersFuture: widget.semestersFuture,
        importedSemesterStore: widget.importedSemesterStore,
        courseCustomizationStore: widget.courseCustomizationStore,
        themePreference: _themePreference,
        onThemePreferenceChanged: _setThemePreference,
        currentDate: widget.currentDate,
      ),
    );
  }

  Future<void> _loadThemePreference() async {
    final preference = await _themePreferenceStore.load();
    if (!mounted) {
      return;
    }
    setState(() => _themePreference = preference);
  }

  Future<void> _setThemePreference(AppThemePreference preference) async {
    setState(() => _themePreference = preference);
    await _themePreferenceStore.save(preference);
  }
}

class _SemesterBootstrap extends StatefulWidget {
  const _SemesterBootstrap({
    required this.semestersFuture,
    required this.importedSemesterStore,
    required this.courseCustomizationStore,
    required this.themePreference,
    required this.onThemePreferenceChanged,
    required this.currentDate,
  });

  final Future<List<Semester>>? semestersFuture;
  final ImportedSemesterStore? importedSemesterStore;
  final CourseCustomizationStore? courseCustomizationStore;
  final AppThemePreference themePreference;
  final ValueChanged<AppThemePreference> onThemePreferenceChanged;
  final DateTime? currentDate;

  @override
  State<_SemesterBootstrap> createState() => _SemesterBootstrapState();
}

class _SemesterBootstrapState extends State<_SemesterBootstrap> {
  late final ImportedSemesterStore _importedSemesterStore =
      widget.importedSemesterStore ?? ImportedSemesterStore();
  late final CourseCustomizationStore _courseCustomizationStore =
      widget.courseCustomizationStore ?? CourseCustomizationStore();
  late Future<List<Semester>> _semestersFuture = _loadSemesters();
  String? _selectedSemesterId;

  Future<List<Semester>> _loadSeedSemesters() =>
      widget.semestersFuture ?? Future.value(const <Semester>[]);

  Future<List<Semester>> _loadSemesters() async {
    final seedSemesters = await _loadSeedSemesters();
    final imported = await _importedSemesterStore.loadSemesters();
    final importedIds = {for (final semester in imported) semester.id};
    final semesters = [
      for (final semester in seedSemesters)
        if (!importedIds.contains(semester.id)) semester,
      ...imported,
    ];
    return Future.wait([
      for (final semester in semesters)
        _courseCustomizationStore.applyToSemester(semester),
    ]);
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
          return _EmptyScheduleScreen(
            themePreference: widget.themePreference,
            onThemePreferenceChanged: widget.onThemePreferenceChanged,
            onManageRequested: _openManagementPage,
          );
        }
        return ScheduleHome(
          semesters: semesters,
          selectedSemesterId: _selectedSemesterId,
          onManageRequested: _openManagementPage,
          onCourseCustomizationSaved: _saveCourseCustomization,
          onManualCourseSaved: _saveManualCourse,
          themePreference: widget.themePreference,
          onThemePreferenceChanged: widget.onThemePreferenceChanged,
          currentDate: widget.currentDate,
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

  Future<void> _saveCourseCustomization(
    String semesterId,
    CourseCustomization customization,
  ) async {
    await _courseCustomizationStore.saveCustomization(
      semesterId: semesterId,
      customization: customization,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _semestersFuture = _loadSemesters();
    });
  }

  Future<void> _saveManualCourse(String semesterId, Course course) async {
    await _courseCustomizationStore.saveManualCourse(
      semesterId: semesterId,
      course: course,
    );
    if (!mounted) {
      return;
    }
    setState(() {
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
    this.onCourseCustomizationSaved,
    this.onManualCourseSaved,
    required this.themePreference,
    required this.onThemePreferenceChanged,
    this.currentDate,
  });

  final List<Semester> semesters;
  final String? selectedSemesterId;
  final VoidCallback? onManageRequested;
  final Future<void> Function(
    String semesterId,
    CourseCustomization customization,
  )?
  onCourseCustomizationSaved;
  final Future<void> Function(String semesterId, Course course)?
  onManualCourseSaved;
  final AppThemePreference themePreference;
  final ValueChanged<AppThemePreference> onThemePreferenceChanged;
  final DateTime? currentDate;

  @override
  State<ScheduleHome> createState() => _ScheduleHomeState();
}

class _ScheduleHomeState extends State<ScheduleHome> {
  late Semester _selectedSemester;
  late int _selectedWeek;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = _dateOnly(widget.currentDate ?? DateTime.now());
    _selectedSemester =
        _semesterForId(widget.selectedSemesterId) ??
        _semesterForToday() ??
        widget.semesters.first;
    _selectedWeek = _selectedSemester.weekForDate(_today);
  }

  @override
  void didUpdateWidget(covariant ScheduleHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    final requestedSemester = _semesterForId(widget.selectedSemesterId);
    if (widget.selectedSemesterId != oldWidget.selectedSemesterId &&
        requestedSemester != null) {
      _selectedSemester = requestedSemester;
      _selectedWeek = _selectedSemester.weekForDate(_today);
      return;
    }
    final refreshedSemester = _semesterForId(_selectedSemester.id);
    if (refreshedSemester != null) {
      _selectedSemester = refreshedSemester;
    } else {
      _selectedSemester = widget.semesters.first;
      _selectedWeek = _selectedSemester.weekForDate(_today);
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          if (mobile)
            _MobileScheduleMenu(
              semesters: widget.semesters,
              selectedSemester: _selectedSemester,
              onSemesterChanged: _selectSemester,
              themePreference: widget.themePreference,
              onThemePreferenceChanged: widget.onThemePreferenceChanged,
              onManageRequested: widget.onManageRequested,
            )
          else ...[
            _ThemeModeIconButton(
              themePreference: widget.themePreference,
              onThemePreferenceChanged: widget.onThemePreferenceChanged,
            ),
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
                    periods: _selectedSemester.periods,
                    selectedWeek: _selectedWeek,
                    weekDateRange: _selectedSemester.dateRangeForWeek(
                      _selectedWeek,
                    ),
                    today: _today,
                    onCourseTap: _showCourseDetails,
                    onEmptyCellTap: widget.onManualCourseSaved == null
                        ? null
                        : _addCourseAt,
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
      _selectedWeek = semester.weekForDate(_today);
    });
  }

  void _showCourseDetails(Course course, CourseSession? session) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _CourseDetailDialog(
        course: course,
        session: session,
        onEdit: widget.onCourseCustomizationSaved == null
            ? null
            : () {
                Navigator.of(dialogContext).pop();
                _openCourseEditor(course);
              },
      ),
    );
  }

  Future<void> _openCourseEditor(Course course) async {
    final customization = await Navigator.of(context).push<CourseCustomization>(
      MaterialPageRoute(
        builder: (context) =>
            CourseEditorPage(semester: _selectedSemester, course: course),
      ),
    );
    if (customization == null || widget.onCourseCustomizationSaved == null) {
      return;
    }
    await widget.onCourseCustomizationSaved!(
      _selectedSemester.id,
      customization,
    );
  }

  Future<void> _addCourseAt(TimetableCellSelection selection) async {
    if (widget.onManualCourseSaved == null) {
      return;
    }
    final course = await showDialog<Course>(
      context: context,
      builder: (context) => QuickAddCourseDialog(
        semester: _selectedSemester,
        selection: selection,
        validateCourse: _manualCourseConflict,
      ),
    );
    if (course == null || !mounted) {
      return;
    }
    await widget.onManualCourseSaved!(_selectedSemester.id, course);
  }

  String? _manualCourseConflict(Course course) {
    for (final addedSession in course.sessions) {
      for (final existingCourse in _selectedSemester.courses) {
        for (final existingSession in existingCourse.sessions) {
          final sameTime =
              addedSession.week == existingSession.week &&
              addedSession.weekday == existingSession.weekday &&
              addedSession.sections.any(existingSession.sections.contains);
          if (sameTime) {
            return '第${addedSession.week}周 ${addedSession.weekdayText} '
                '${addedSession.periodName} 与“${existingCourse.name}”冲突';
          }
        }
      }
    }
    return null;
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

  Semester? _semesterForToday() {
    final matching =
        widget.semesters
            .where((semester) => semester.containsDate(_today))
            .toList()
          ..sort((a, b) => a.termStartDate!.compareTo(b.termStartDate!));
    return matching.isEmpty ? null : matching.last;
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

ThemeData _buildAppTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0F766E),
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: brightness == Brightness.light
        ? const Color(0xFFF6F7F9)
        : const Color(0xFF101413),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    popupMenuTheme: PopupMenuThemeData(color: scheme.surfaceContainerHigh),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
    ),
  );
}

ThemeMode _themeModeFor(AppThemePreference preference) {
  return switch (preference) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };
}

String _themePreferenceLabel(AppThemePreference preference) {
  return switch (preference) {
    AppThemePreference.system => '跟随系统',
    AppThemePreference.light => '浅色',
    AppThemePreference.dark => '深色',
  };
}

IconData _themePreferenceIcon(AppThemePreference preference) {
  return switch (preference) {
    AppThemePreference.system => Icons.brightness_auto_outlined,
    AppThemePreference.light => Icons.light_mode_outlined,
    AppThemePreference.dark => Icons.dark_mode_outlined,
  };
}

Future<void> _showThemePreferencePicker({
  required BuildContext context,
  required AppThemePreference current,
  required ValueChanged<AppThemePreference> onChanged,
}) async {
  final selected = await showModalBottomSheet<AppThemePreference>(
    context: context,
    showDragHandle: true,
    builder: (context) => _ThemePreferencePicker(current: current),
  );
  if (selected != null && selected != current) {
    onChanged(selected);
  }
}

class _ThemeModeIconButton extends StatelessWidget {
  const _ThemeModeIconButton({
    required this.themePreference,
    required this.onThemePreferenceChanged,
  });

  final AppThemePreference themePreference;
  final ValueChanged<AppThemePreference> onThemePreferenceChanged;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const ValueKey('desktop-theme-mode-button'),
      tooltip: '切换主题',
      onPressed: () => _showThemePreferencePicker(
        context: context,
        current: themePreference,
        onChanged: onThemePreferenceChanged,
      ),
      icon: Icon(_themePreferenceIcon(themePreference)),
    );
  }
}

class _ThemePreferencePicker extends StatelessWidget {
  const _ThemePreferencePicker({required this.current});

  final AppThemePreference current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text(
              '选择主题',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          for (final preference in AppThemePreference.values)
            ListTile(
              key: ValueKey('theme-mode-${preference.storageValue}'),
              leading: Icon(_themePreferenceIcon(preference)),
              title: Text(_themePreferenceLabel(preference)),
              trailing: preference == current ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(context).pop(preference),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
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
        color: Theme.of(context).colorScheme.surface,
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
    required this.themePreference,
    required this.onThemePreferenceChanged,
    required this.onManageRequested,
  });

  final List<Semester> semesters;
  final Semester selectedSemester;
  final ValueChanged<Semester> onSemesterChanged;
  final AppThemePreference themePreference;
  final ValueChanged<AppThemePreference> onThemePreferenceChanged;
  final VoidCallback? onManageRequested;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MobileScheduleMenuAction>(
      key: const ValueKey('mobile-schedule-menu-button'),
      tooltip: '课程表菜单',
      icon: const Icon(Icons.menu),
      onSelected: (action) {
        switch (action) {
          case _MobileScheduleMenuAction.chooseSemester:
            _showSemesterPicker(context);
          case _MobileScheduleMenuAction.theme:
            _showThemePreferencePicker(
              context: context,
              current: themePreference,
              onChanged: onThemePreferenceChanged,
            );
          case _MobileScheduleMenuAction.management:
            onManageRequested?.call();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _MobileScheduleMenuAction.chooseSemester,
          child: SizedBox(
            width: 240,
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('学期'),
                      Text(
                        selectedSemester.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
        PopupMenuItem(
          value: _MobileScheduleMenuAction.theme,
          child: SizedBox(
            width: 240,
            child: Row(
              children: [
                Icon(_themePreferenceIcon(themePreference)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('主题'),
                      Text(
                        _themePreferenceLabel(themePreference),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: _MobileScheduleMenuAction.management,
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

  Future<void> _showSemesterPicker(BuildContext context) async {
    final semester = await showModalBottomSheet<Semester>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _MobileSemesterPicker(
        semesters: semesters,
        selectedSemester: selectedSemester,
      ),
    );
    if (semester != null) {
      onSemesterChanged(semester);
    }
  }
}

enum _MobileScheduleMenuAction { chooseSemester, theme, management }

class _MobileSemesterPicker extends StatelessWidget {
  const _MobileSemesterPicker({
    required this.semesters,
    required this.selectedSemester,
  });

  final List<Semester> semesters;
  final Semester selectedSemester;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.65,
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              '选择学期',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RadioGroup<String>(
                groupValue: selectedSemester.id,
                onChanged: (id) {
                  if (id == null) {
                    return;
                  }
                  Navigator.of(
                    context,
                  ).pop(semesters.firstWhere((semester) => semester.id == id));
                },
                child: ListView.builder(
                  key: const ValueKey('mobile-semester-picker'),
                  itemCount: semesters.length,
                  itemBuilder: (context, index) {
                    final semester = semesters[index];
                    return RadioListTile<String>(
                      value: semester.id,
                      title: Text(semester.displayName),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
  const _CourseDetailDialog({
    required this.course,
    required this.session,
    this.onEdit,
  });

  final Course course;
  final CourseSession? session;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(course.name)),
          if (onEdit != null)
            IconButton(
              key: const ValueKey('edit-course-button'),
              tooltip: '编辑课程',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
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
              if (course.isManual)
                const _DetailRow(label: '课程来源', value: '手动添加')
              else ...[
                _DetailRow(label: '课程号', value: course.courseCode),
                _DetailRow(label: '课程序号', value: course.sequence),
              ],
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
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '第${session.week}周 · ${session.weekdayText} · ${session.periodName}'
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
  const _EmptyScheduleScreen({
    required this.themePreference,
    required this.onThemePreferenceChanged,
    required this.onManageRequested,
  });

  final AppThemePreference themePreference;
  final ValueChanged<AppThemePreference> onThemePreferenceChanged;
  final VoidCallback onManageRequested;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('课程表'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (mobile)
            PopupMenuButton<_EmptyScheduleAction>(
              key: const ValueKey('empty-schedule-menu-button'),
              tooltip: '课程表菜单',
              icon: const Icon(Icons.menu),
              onSelected: (action) {
                switch (action) {
                  case _EmptyScheduleAction.theme:
                    _showThemePreferencePicker(
                      context: context,
                      current: themePreference,
                      onChanged: onThemePreferenceChanged,
                    );
                  case _EmptyScheduleAction.management:
                    onManageRequested();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _EmptyScheduleAction.theme,
                  child: Row(
                    children: [
                      Icon(_themePreferenceIcon(themePreference)),
                      const SizedBox(width: 12),
                      Text('主题：${_themePreferenceLabel(themePreference)}'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: _EmptyScheduleAction.management,
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined),
                      SizedBox(width: 12),
                      Text('管理课程表'),
                    ],
                  ),
                ),
              ],
            )
          else
            _ThemeModeIconButton(
              themePreference: themePreference,
              onThemePreferenceChanged: onThemePreferenceChanged,
            ),
        ],
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

enum _EmptyScheduleAction { theme, management }

bool _hasAnyLink(Course course) =>
    course.courseDetailLink != null ||
    course.teachingRecordLink != null ||
    course.processScoreLink != null;
