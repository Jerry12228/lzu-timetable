import 'package:flutter/material.dart';

import '../models/schedule_models.dart';

class TimetableGrid extends StatelessWidget {
  const TimetableGrid({
    super.key,
    required this.compact,
    required this.scheduled,
    required this.onCourseTap,
    this.weekDateRange,
  });

  final bool compact;
  final List<ScheduledCourse> scheduled;
  final void Function(Course course, CourseSession? session) onCourseTap;
  final DateRange? weekDateRange;

  static const _headerHeight = 44.0;
  static const _datedHeaderHeight = 58.0;
  static const _rowHeight = 62.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final denseMobile = compact && constraints.maxWidth < 600;
        final padding = denseMobile ? 4.0 : (compact ? 12.0 : 18.0);
        final leftWidth = denseMobile ? 42.0 : (compact ? 68.0 : 86.0);
        final minDayWidth = compact ? 124.0 : 138.0;
        final availableWidth = constraints.maxWidth - padding * 2;
        final minTableWidth = leftWidth + minDayWidth * weekdays.length;
        final tableWidth = denseMobile
            ? availableWidth
            : (availableWidth > minTableWidth ? availableWidth : minTableWidth);
        final dayWidth = (tableWidth - leftWidth) / weekdays.length;
        final headerHeight = weekDateRange == null
            ? _headerHeight
            : _datedHeaderHeight;
        final tableHeight =
            headerHeight + _rowHeight * _timetableSections.length;

        final table = SizedBox(
          key: const ValueKey('timetable-canvas'),
          width: tableWidth,
          height: tableHeight,
          child: _TimetableCanvas(
            leftWidth: leftWidth,
            dayWidth: dayWidth,
            headerHeight: headerHeight,
            rowHeight: _rowHeight,
            scheduled: scheduled,
            weekDateRange: weekDateRange,
            dense: denseMobile,
            onCourseTap: onCourseTap,
          ),
        );

        return Scrollbar(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: denseMobile
                ? table
                : Scrollbar(
                    notificationPredicate: (notification) =>
                        notification.metrics.axis == Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: table,
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
    required this.weekDateRange,
    required this.dense,
    required this.onCourseTap,
  });

  final double leftWidth;
  final double dayWidth;
  final double headerHeight;
  final double rowHeight;
  final List<ScheduledCourse> scheduled;
  final DateRange? weekDateRange;
  final bool dense;
  final void Function(Course course, CourseSession? session) onCourseTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final courseInset = dense ? 2.0 : 4.0;
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
            _CornerCell(width: leftWidth, height: headerHeight, dense: dense),
            for (var day = 0; day < weekdays.length; day++)
              _HeaderCell(
                left: leftWidth + day * dayWidth,
                width: dayWidth,
                height: headerHeight,
                label: weekdays[day],
                date: weekDateRange?.start.add(Duration(days: day)),
                dense: dense,
              ),
            for (var index = 0; index < _timetableSections.length; index++)
              _SectionCell(
                top: headerHeight + index * rowHeight,
                width: leftWidth,
                height: rowHeight,
                label: _timetableSections[index].label,
                dense: dense,
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
                  left:
                      leftWidth +
                      (item.session.weekday - 1) * dayWidth +
                      courseInset,
                  top: headerHeight + span.startIndex * rowHeight + courseInset,
                  width: dayWidth - courseInset * 2,
                  height: span.length * rowHeight - courseInset * 2,
                  dense: dense,
                  onTap: () => onCourseTap(item.course, item.session),
                ),
          ],
        ),
      ),
    );
  }
}

class _CornerCell extends StatelessWidget {
  const _CornerCell({
    required this.width,
    required this.height,
    required this.dense,
  });

  final double width;
  final double height;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      width: width,
      height: height,
      child: _TableCellShell(
        background: Theme.of(context).colorScheme.surfaceContainerHighest,
        dense: dense,
        child: Text(
          '节次',
          style: TextStyle(
            fontSize: dense ? 10 : 14,
            fontWeight: FontWeight.w800,
          ),
        ),
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
    required this.date,
    required this.dense,
  });

  final double left;
  final double width;
  final double height;
  final String label;
  final DateTime? date;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: 0,
      width: width,
      height: height,
      child: _TableCellShell(
        background: Theme.of(context).colorScheme.surfaceContainerHighest,
        dense: dense,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: dense ? 10 : 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (date != null) ...[
              SizedBox(height: dense ? 1 : 2),
              Text(
                _formatMonthDay(date!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: dense ? 8.5 : 11.5,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
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
    required this.dense,
  });

  final double top;
  final double width;
  final double height;
  final String label;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: top,
      width: width,
      height: height,
      child: _TableCellShell(
        background: const Color(0xFFFAFBFC),
        dense: dense,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: dense ? 9 : 13,
            fontWeight: FontWeight.w700,
          ),
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
  const _TableCellShell({
    required this.background,
    required this.child,
    this.dense = false,
  });

  final Color background;
  final Widget child;
  final bool dense;

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
      padding: dense
          ? const EdgeInsets.symmetric(horizontal: 1, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
    required this.dense,
    required this.onTap,
  });

  final ScheduledCourse scheduled;
  final double left;
  final double top;
  final double width;
  final double height;
  final bool dense;
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
        borderRadius: BorderRadius.circular(dense ? 4 : 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(dense ? 4 : 8),
          child: Container(
            padding: EdgeInsets.all(dense ? 3 : 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(dense ? 4 : 8),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scheduled.course.name,
                  maxLines: dense ? 4 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: dense ? 10 : 14,
                    fontWeight: FontWeight.w800,
                    height: dense ? 1.1 : 1.15,
                  ),
                ),
                if (!dense) ...[
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
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
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

String _formatMonthDay(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$month-$day';
}
