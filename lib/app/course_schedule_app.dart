import 'package:flutter/material.dart';

import '../models/schedule_models.dart';
import '../services/sample_semester_loader.dart';

class CourseScheduleApp extends StatelessWidget {
  const CourseScheduleApp({super.key, this.semestersFuture});

  final Future<List<Semester>>? semestersFuture;

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
      home: _SemesterBootstrap(semestersFuture: semestersFuture),
    );
  }
}

class _SemesterBootstrap extends StatefulWidget {
  const _SemesterBootstrap({required this.semestersFuture});

  final Future<List<Semester>>? semestersFuture;

  @override
  State<_SemesterBootstrap> createState() => _SemesterBootstrapState();
}

class _SemesterBootstrapState extends State<_SemesterBootstrap> {
  late final Future<List<Semester>> _semestersFuture =
      widget.semestersFuture ?? const SampleSemesterLoader().load();

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
          return const _ErrorScreen(message: '没有可显示的学期数据');
        }
        return ScheduleHome(semesters: semesters);
      },
    );
  }
}

class ScheduleHome extends StatefulWidget {
  const ScheduleHome({super.key, required this.semesters});

  final List<Semester> semesters;

  @override
  State<ScheduleHome> createState() => _ScheduleHomeState();
}

class _ScheduleHomeState extends State<ScheduleHome> {
  late Semester _selectedSemester = widget.semesters.first;
  int _selectedWeek = 1;

  @override
  void didUpdateWidget(covariant ScheduleHome oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('课程表'),
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
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
                  semesters: widget.semesters,
                  selectedSemester: _selectedSemester,
                  selectedWeek: _selectedWeek,
                  onSemesterChanged: _selectSemester,
                  onWeekChanged: (week) => setState(() => _selectedWeek = week),
                ),
                Expanded(
                  child: compact
                      ? _MobileTimetable(
                          scheduled: scheduled,
                          unscheduled:
                              _selectedSemester.coursesWithoutFixedSchedule,
                          onCourseTap: _showCourseDetails,
                        )
                      : _DesktopTimetable(
                          scheduled: scheduled,
                          unscheduled:
                              _selectedSemester.coursesWithoutFixedSchedule,
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
}

class _ScheduleControls extends StatelessWidget {
  const _ScheduleControls({
    required this.compact,
    required this.semesters,
    required this.selectedSemester,
    required this.selectedWeek,
    required this.onSemesterChanged,
    required this.onWeekChanged,
  });

  final bool compact;
  final List<Semester> semesters;
  final Semester selectedSemester;
  final int selectedWeek;
  final ValueChanged<Semester> onSemesterChanged;
  final ValueChanged<int> onWeekChanged;

  @override
  Widget build(BuildContext context) {
    final controls = <Widget>[
      _SemesterDropdown(
        semesters: semesters,
        selectedSemester: selectedSemester,
        onChanged: onSemesterChanged,
      ),
      _WeekDropdown(
        maxWeek: selectedSemester.maxWeek,
        selectedWeek: selectedWeek,
        onChanged: onWeekChanged,
      ),
      _WeekRangeBadge(label: _weekRangeLabel(selectedSemester, selectedWeek)),
    ];

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
                controls[0],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: controls[1]),
                    const SizedBox(width: 10),
                    Expanded(child: controls[2]),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                SizedBox(width: 260, child: controls[0]),
                const SizedBox(width: 12),
                SizedBox(width: 160, child: controls[1]),
                const SizedBox(width: 12),
                Expanded(child: controls[2]),
              ],
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

class _WeekRangeBadge extends StatelessWidget {
  const _WeekRangeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.secondary.withValues(alpha: 0.28)),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(Icons.calendar_month, size: 18, color: scheme.secondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopTimetable extends StatelessWidget {
  const _DesktopTimetable({
    required this.scheduled,
    required this.unscheduled,
    required this.onCourseTap,
  });

  final List<ScheduledCourse> scheduled;
  final List<Course> unscheduled;
  final void Function(Course course, CourseSession? session) onCourseTap;

  @override
  Widget build(BuildContext context) {
    final byDay = _groupByDay(scheduled);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var day = 1; day <= 7; day++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: day == 7 ? 0 : 10),
                  child: _DayColumn(
                    dayLabel: weekdays[day - 1],
                    scheduled: byDay[day] ?? const [],
                    onCourseTap: onCourseTap,
                  ),
                ),
              ),
          ],
        ),
        if (unscheduled.isNotEmpty) ...[
          const SizedBox(height: 16),
          _UnscheduledSection(courses: unscheduled, onCourseTap: onCourseTap),
        ],
      ],
    );
  }
}

class _MobileTimetable extends StatelessWidget {
  const _MobileTimetable({
    required this.scheduled,
    required this.unscheduled,
    required this.onCourseTap,
  });

  final List<ScheduledCourse> scheduled;
  final List<Course> unscheduled;
  final void Function(Course course, CourseSession? session) onCourseTap;

  @override
  Widget build(BuildContext context) {
    final byDay = _groupByDay(scheduled);
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      children: [
        for (var day = 1; day <= 7; day++) ...[
          _DayColumn(
            dayLabel: weekdays[day - 1],
            scheduled: byDay[day] ?? const [],
            onCourseTap: onCourseTap,
          ),
          const SizedBox(height: 12),
        ],
        if (unscheduled.isNotEmpty)
          _UnscheduledSection(courses: unscheduled, onCourseTap: onCourseTap),
      ],
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.dayLabel,
    required this.scheduled,
    required this.onCourseTap,
  });

  final String dayLabel;
  final List<ScheduledCourse> scheduled;
  final void Function(Course course, CourseSession? session) onCourseTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 160),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.48),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Text(
              dayLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          if (scheduled.isEmpty)
            const Padding(
              padding: EdgeInsets.all(14),
              child: Text('无课程', textAlign: TextAlign.center),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  for (final item in scheduled) ...[
                    _CourseTile(
                      scheduled: item,
                      onTap: () => onCourseTap(item.course, item.session),
                    ),
                    if (item != scheduled.last) const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({required this.scheduled, required this.onTap});

  final ScheduledCourse scheduled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _courseColor(scheduled.course.name);
    final session = scheduled.session;
    return Material(
      color: color.withValues(alpha: 0.11),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scheduled.course.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              _TileLine(
                icon: Icons.schedule,
                text:
                    '${session.periodName} ${session.startTime}-${session.endTime}',
              ),
              const SizedBox(height: 4),
              _TileLine(
                icon: Icons.place,
                text: session.location.isEmpty ? '地点未公布' : session.location,
              ),
              const SizedBox(height: 4),
              _TileLine(
                icon: Icons.person,
                text: scheduled.course.teachers.join('、'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileLine extends StatelessWidget {
  const _TileLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.black54),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

class _UnscheduledSection extends StatelessWidget {
  const _UnscheduledSection({required this.courses, required this.onCourseTap});

  final List<Course> courses;
  final void Function(Course course, CourseSession? session) onCourseTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.public, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              const Text(
                '无固定时间',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final course in courses)
                _UnscheduledChip(
                  course: course,
                  onTap: () => onCourseTap(course, null),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnscheduledChip extends StatelessWidget {
  const _UnscheduledChip({required this.course, required this.onTap});

  final Course course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _courseColor(course.name);
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 260),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Text(
            course.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ),
      ),
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

Map<int, List<ScheduledCourse>> _groupByDay(List<ScheduledCourse> scheduled) {
  final byDay = <int, List<ScheduledCourse>>{};
  for (final item in scheduled) {
    byDay.putIfAbsent(item.session.weekday, () => []).add(item);
  }
  return byDay;
}

String _weekRangeLabel(Semester semester, int week) {
  final range = semester.dateRangeForWeek(week);
  if (range == null) {
    return '第$week周 · 开学日期未配置';
  }
  return '${_formatDate(range.start)} - ${_formatDate(range.end)}';
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

Color _courseColor(String key) {
  const colors = [
    Color(0xFF0F766E),
    Color(0xFF2563EB),
    Color(0xFFB45309),
    Color(0xFFBE123C),
    Color(0xFF6D28D9),
    Color(0xFF047857),
    Color(0xFFA21CAF),
    Color(0xFF334155),
  ];
  final hash = key.runes.fold<int>(0, (value, rune) => value + rune);
  return colors[hash % colors.length];
}

bool _hasAnyLink(Course course) =>
    course.courseDetailLink != null ||
    course.teachingRecordLink != null ||
    course.processScoreLink != null;
