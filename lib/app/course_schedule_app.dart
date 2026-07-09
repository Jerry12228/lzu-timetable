import 'package:flutter/material.dart';

import 'import_schedule_page.dart';
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

  Future<List<Semester>> _loadSemesters() async {
    final bundled =
        await (widget.semestersFuture ?? const SampleSemesterLoader().load());
    final imported = await _importedSemesterStore.loadSemesters();
    return [...bundled, ...imported];
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
          return const _ErrorScreen(message: '没有可显示的学期数据');
        }
        return ScheduleHome(
          semesters: semesters,
          selectedSemesterId: _selectedSemesterId,
          onImportRequested: () => _openImportPage(semesters),
        );
      },
    );
  }

  Future<void> _openImportPage(List<Semester> semesters) async {
    final importedId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => ImportSchedulePage(
          existingDisplayNames: [
            for (final semester in semesters) semester.displayName,
          ],
          store: _importedSemesterStore,
        ),
      ),
    );
    if (importedId == null || !mounted) {
      return;
    }
    setState(() {
      _selectedSemesterId = importedId;
      _semestersFuture = _loadSemesters();
    });
  }
}

class ScheduleHome extends StatefulWidget {
  const ScheduleHome({
    super.key,
    required this.semesters,
    this.selectedSemesterId,
    this.onImportRequested,
  });

  final List<Semester> semesters;
  final String? selectedSemesterId;
  final VoidCallback? onImportRequested;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('课程表'),
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton.icon(
              key: const ValueKey('open-import-page-button'),
              onPressed: widget.onImportRequested,
              icon: const Icon(Icons.upload_file),
              label: const Text('导入'),
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
                  semesters: widget.semesters,
                  selectedSemester: _selectedSemester,
                  selectedWeek: _selectedWeek,
                  onSemesterChanged: _selectSemester,
                  onWeekChanged: (week) => setState(() => _selectedWeek = week),
                ),
                Expanded(
                  child: _TimetableGrid(
                    compact: compact,
                    scheduled: scheduled,
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

class _TimetableGrid extends StatelessWidget {
  const _TimetableGrid({
    required this.compact,
    required this.scheduled,
    required this.onCourseTap,
  });

  final bool compact;
  final List<ScheduledCourse> scheduled;
  final void Function(Course course, CourseSession? session) onCourseTap;

  static const _headerHeight = 44.0;
  static const _rowHeight = 62.0;

  @override
  Widget build(BuildContext context) {
    final padding = compact ? 12.0 : 18.0;
    final leftWidth = compact ? 68.0 : 86.0;
    final minDayWidth = compact ? 124.0 : 138.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - padding * 2;
        final minTableWidth = leftWidth + minDayWidth * weekdays.length;
        final tableWidth = availableWidth > minTableWidth
            ? availableWidth
            : minTableWidth;
        final dayWidth = (tableWidth - leftWidth) / weekdays.length;
        final tableHeight =
            _headerHeight + _rowHeight * _timetableSections.length;

        return Scrollbar(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Scrollbar(
              notificationPredicate: (notification) =>
                  notification.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  height: tableHeight,
                  child: _TimetableCanvas(
                    leftWidth: leftWidth,
                    dayWidth: dayWidth,
                    headerHeight: _headerHeight,
                    rowHeight: _rowHeight,
                    scheduled: scheduled,
                    onCourseTap: onCourseTap,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TimetableCanvas extends StatelessWidget {
  const _TimetableCanvas({
    required this.leftWidth,
    required this.dayWidth,
    required this.headerHeight,
    required this.rowHeight,
    required this.scheduled,
    required this.onCourseTap,
  });

  final double leftWidth;
  final double dayWidth;
  final double headerHeight;
  final double rowHeight;
  final List<ScheduledCourse> scheduled;
  final void Function(Course course, CourseSession? session) onCourseTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const courseInset = 4.0;
    final suppressedLineSegments = _suppressedLineSegmentsFor(
      scheduled: scheduled,
      dayWidth: dayWidth,
      courseInset: courseInset,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            _CornerCell(width: leftWidth, height: headerHeight),
            for (var day = 0; day < weekdays.length; day++)
              _HeaderCell(
                left: leftWidth + day * dayWidth,
                width: dayWidth,
                height: headerHeight,
                label: weekdays[day],
              ),
            for (var index = 0; index < _timetableSections.length; index++)
              _SectionCell(
                top: headerHeight + index * rowHeight,
                width: leftWidth,
                height: rowHeight,
                label: _timetableSections[index].label,
              ),
            _GridLinesLayer(
              left: leftWidth,
              top: headerHeight,
              width: dayWidth * weekdays.length,
              height: rowHeight * _timetableSections.length,
              dayWidth: dayWidth,
              rowHeight: rowHeight,
              suppressedLineSegments: suppressedLineSegments,
            ),
            for (final item in scheduled)
              if (_sectionSpanFor(item.session) case final span?)
                _PositionedCourseBlock(
                  scheduled: item,
                  left: leftWidth + (item.session.weekday - 1) * dayWidth + 4,
                  top: headerHeight + span.startIndex * rowHeight + 4,
                  width: dayWidth - 8,
                  height: span.length * rowHeight - 8,
                  onTap: () => onCourseTap(item.course, item.session),
                ),
          ],
        ),
      ),
    );
  }
}

class _CornerCell extends StatelessWidget {
  const _CornerCell({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      width: width,
      height: height,
      child: _TableCellShell(
        background: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Text('节次', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.left,
    required this.width,
    required this.height,
    required this.label,
  });

  final double left;
  final double width;
  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: 0,
      width: width,
      height: height,
      child: _TableCellShell(
        background: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _SectionCell extends StatelessWidget {
  const _SectionCell({
    required this.top,
    required this.width,
    required this.height,
    required this.label,
  });

  final double top;
  final double width;
  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: top,
      width: width,
      height: height,
      child: _TableCellShell(
        background: const Color(0xFFFAFBFC),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _GridLinesLayer extends StatelessWidget {
  const _GridLinesLayer({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.dayWidth,
    required this.rowHeight,
    required this.suppressedLineSegments,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final double dayWidth;
  final double rowHeight;
  final Map<int, List<_SuppressedLineSegment>> suppressedLineSegments;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: CustomPaint(
        painter: _GridLinesPainter(
          dayWidth: dayWidth,
          rowHeight: rowHeight,
          rowCount: _timetableSections.length,
          dayCount: weekdays.length,
          lineColor: Theme.of(context).colorScheme.outlineVariant,
          suppressedLineSegments: suppressedLineSegments,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _GridLinesPainter extends CustomPainter {
  const _GridLinesPainter({
    required this.dayWidth,
    required this.rowHeight,
    required this.rowCount,
    required this.dayCount,
    required this.lineColor,
    required this.suppressedLineSegments,
  });

  final double dayWidth;
  final double rowHeight;
  final int rowCount;
  final int dayCount;
  final Color lineColor;
  final Map<int, List<_SuppressedLineSegment>> suppressedLineSegments;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, background);

    final line = Paint()
      ..color = lineColor
      ..strokeWidth = 0.5;

    for (var day = 0; day <= dayCount; day++) {
      final x = day * dayWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }

    for (var boundary = 0; boundary <= rowCount; boundary++) {
      final y = boundary * rowHeight;
      _drawHorizontalLine(
        canvas: canvas,
        paint: line,
        y: y,
        width: dayWidth * dayCount,
        suppressed: suppressedLineSegments[boundary] ?? const [],
      );
    }
  }

  void _drawHorizontalLine({
    required Canvas canvas,
    required Paint paint,
    required double y,
    required double width,
    required List<_SuppressedLineSegment> suppressed,
  }) {
    var start = 0.0;
    final ordered = suppressed.toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    for (final segment in ordered) {
      final segmentStart = segment.start.clamp(0.0, width);
      final segmentEnd = segment.end.clamp(0.0, width);
      if (segmentStart > start) {
        canvas.drawLine(Offset(start, y), Offset(segmentStart, y), paint);
      }
      if (segmentEnd > start) {
        start = segmentEnd;
      }
    }
    if (start < width) {
      canvas.drawLine(Offset(start, y), Offset(width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridLinesPainter oldDelegate) {
    return dayWidth != oldDelegate.dayWidth ||
        rowHeight != oldDelegate.rowHeight ||
        rowCount != oldDelegate.rowCount ||
        dayCount != oldDelegate.dayCount ||
        lineColor != oldDelegate.lineColor ||
        suppressedLineSegments != oldDelegate.suppressedLineSegments;
  }
}

class _TableCellShell extends StatelessWidget {
  const _TableCellShell({required this.background, required this.child});

  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: child,
    );
  }
}

class _PositionedCourseBlock extends StatelessWidget {
  const _PositionedCourseBlock({
    required this.scheduled,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.onTap,
  });

  final ScheduledCourse scheduled;
  final double left;
  final double top;
  final double width;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _courseColor(scheduled.course.name);
    final session = scheduled.session;
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Material(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.35)),
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
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.location.isEmpty ? '地点未公布' : session.location,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const Spacer(),
                Text(
                  session.startTime.isEmpty
                      ? session.periodName
                      : '${session.startTime}-${session.endTime}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: Colors.black54),
                ),
              ],
            ),
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

class _TimetableSection {
  const _TimetableSection({required this.id, required this.label});

  final String id;
  final String label;
}

class _SectionSpan {
  const _SectionSpan({required this.startIndex, required this.length});

  final int startIndex;
  final int length;

  int get endIndex => startIndex + length;
}

class _SuppressedLineSegment {
  const _SuppressedLineSegment({required this.start, required this.end});

  final double start;
  final double end;
}

const _timetableSections = [
  _TimetableSection(id: '第1节', label: '第1节'),
  _TimetableSection(id: '第2节', label: '第2节'),
  _TimetableSection(id: '第3节', label: '第3节'),
  _TimetableSection(id: '第4节', label: '第4节'),
  _TimetableSection(id: '中午1节', label: '中午1'),
  _TimetableSection(id: '中午2节', label: '中午2'),
  _TimetableSection(id: '第5节', label: '第5节'),
  _TimetableSection(id: '第6节', label: '第6节'),
  _TimetableSection(id: '第7节', label: '第7节'),
  _TimetableSection(id: '第8节', label: '第8节'),
  _TimetableSection(id: '第9节', label: '第9节'),
  _TimetableSection(id: '第10节', label: '第10节'),
  _TimetableSection(id: '第11节', label: '第11节'),
  _TimetableSection(id: '第12节', label: '第12节'),
];

_SectionSpan? _sectionSpanFor(CourseSession session) {
  final indexes =
      session.sections
          .map(
            (section) =>
                _timetableSections.indexWhere((item) => item.id == section),
          )
          .where((index) => index >= 0)
          .toList()
        ..sort();
  if (indexes.isEmpty) {
    return null;
  }
  return _SectionSpan(
    startIndex: indexes.first,
    length: indexes.last - indexes.first + 1,
  );
}

Map<int, List<_SuppressedLineSegment>> _suppressedLineSegmentsFor({
  required List<ScheduledCourse> scheduled,
  required double dayWidth,
  required double courseInset,
}) {
  final suppressed = <int, List<_SuppressedLineSegment>>{};
  const lineGapOverlap = 2.0;
  for (final item in scheduled) {
    final span = _sectionSpanFor(item.session);
    if (span == null) {
      continue;
    }
    final left =
        (item.session.weekday - 1) * dayWidth + courseInset - lineGapOverlap;
    final right =
        item.session.weekday * dayWidth - courseInset + lineGapOverlap;
    for (
      var boundary = span.startIndex + 1;
      boundary < span.endIndex;
      boundary++
    ) {
      suppressed
          .putIfAbsent(boundary, () => <_SuppressedLineSegment>[])
          .add(_SuppressedLineSegment(start: left, end: right));
    }
  }
  return suppressed;
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
