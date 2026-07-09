import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import '../models/schedule_models.dart';
import 'default_periods.dart';

class SemesterImporter {
  const SemesterImporter._();

  static Semester parseFromHtml({
    required String semesterId,
    required String displayName,
    required DateTime? termStartDate,
    required String courseHtml,
    required String periodHtml,
  }) {
    final periods = _parsePeriods(periodHtml);
    final courses = _parseCourses(courseHtml, periods);
    return Semester(
      id: semesterId,
      displayName: displayName,
      termStartDate: termStartDate,
      courses: courses,
      periods: periods,
    );
  }

  static Semester parseCourseHtml({
    required String semesterId,
    required String displayName,
    required DateTime? termStartDate,
    required String courseHtml,
  }) {
    final courses = _parseCourses(courseHtml, DefaultPeriods.all);
    return Semester(
      id: semesterId,
      displayName: displayName,
      termStartDate: termStartDate,
      courses: courses,
      periods: DefaultPeriods.all,
    );
  }

  static List<PeriodDefinition> _parsePeriods(String html) {
    final document = html_parser.parse(html);
    return document.querySelectorAll('tr.infolist_common').map((row) {
      final cells = _directCells(row);
      if (cells.length < 4) {
        throw FormatException('Invalid period row: ${row.outerHtml}');
      }
      final timeText = _cleanText(cells[3]);
      final timeMatch = RegExp(
        r'(\d{2}:\d{2})\s*--\s*(\d{2}:\d{2})',
      ).firstMatch(timeText);
      if (timeMatch == null) {
        throw FormatException('Invalid period time: $timeText');
      }
      return PeriodDefinition(
        order: int.parse(_cleanText(cells[0])),
        name: _cleanText(cells[1]),
        sections: _cleanText(
          cells[2],
        ).split(' ').where((section) => section.isNotEmpty).toList(),
        startTime: timeMatch.group(1)!,
        endTime: timeMatch.group(2)!,
      );
    }).toList();
  }

  static List<Course> _parseCourses(
    String html,
    List<PeriodDefinition> periods,
  ) {
    final document = html_parser.parse(html);
    final rows = document.querySelectorAll('tr.infolist_common');
    if (rows.isEmpty) {
      throw const FormatException('未找到课程列表，请确认粘贴或上传的是课程列表 HTML');
    }
    final periodsByName = {
      for (final period in periods) _compact(period.name): period,
    };
    return rows.map((row) {
      final cells = _directCells(row);
      if (cells.length < 10) {
        throw FormatException('Invalid course row: ${row.outerHtml}');
      }
      final teachers = cells[3]
          .querySelectorAll('a')
          .map(_cleanText)
          .where((teacher) => teacher.isNotEmpty)
          .toList();
      final scheduleCell = cells[9];
      return Course(
        courseCode: _cleanText(cells[0]),
        sequence: _cleanText(cells[1]),
        name: _cleanText(cells[2].querySelector('a') ?? cells[2]),
        teachers: teachers.isEmpty ? _fallbackTeachers(cells[3]) : teachers,
        credits: _cleanText(cells[4]),
        selectionType: _cleanText(cells[5]),
        assessment: _cleanText(cells[6]),
        examNature: _cleanText(cells[7]),
        deferredExam: _cleanText(cells[8]),
        material: cells.length > 10 ? _cleanText(cells[10]) : '',
        courseDetailLink: _firstLink(cells[2]),
        teachingRecordLink: cells.length > 11 ? _firstLink(cells[11]) : null,
        processScoreLink: cells.length > 12 ? _firstLink(cells[12]) : null,
        sessions: _parseSessions(scheduleCell, periodsByName),
      );
    }).toList();
  }

  static List<CourseSession> _parseSessions(
    dom.Element scheduleCell,
    Map<String, PeriodDefinition> periodsByName,
  ) {
    final sessions = <CourseSession>[];
    for (final row in scheduleCell.querySelectorAll('table.none tr')) {
      final cells = _directCells(row);
      if (cells.length < 4) {
        continue;
      }
      final weekText = _cleanText(cells[0]);
      final weekdayText = _cleanText(cells[1]);
      final periodName = _cleanText(cells[2]);
      final location = _cleanText(cells[3]);
      if (weekText.isEmpty || weekdayText.isEmpty || periodName.isEmpty) {
        continue;
      }
      final period = periodsByName[_compact(periodName)];
      sessions.add(
        CourseSession(
          weekRule: parseWeekRule(weekText),
          weekday: parseWeekday(weekdayText),
          weekdayText: weekdayText,
          periodName: periodName,
          startTime: period?.startTime ?? '',
          endTime: period?.endTime ?? '',
          sections: period?.sections ?? const [],
          location: location,
        ),
      );
    }
    return sessions;
  }

  static WeekRule parseWeekRule(String rawText) {
    final compact = _compact(rawText).replaceAll('，', ',').replaceAll('、', ',');
    final explicitMatch = RegExp(r'^第([\d,]+)周$').firstMatch(compact);
    if (explicitMatch != null) {
      final weeks = explicitMatch
          .group(1)!
          .split(',')
          .map(int.parse)
          .where((week) => week > 0)
          .toList();
      if (weeks.isEmpty) {
        throw FormatException('Invalid week rule: $rawText');
      }
      return WeekRule.explicit(rawText: rawText, weeks: weeks);
    }

    final rangeMatch = RegExp(r'^(\d+)-(\d+)周(全周|单周|双周)?$').firstMatch(compact);
    if (rangeMatch != null) {
      final startWeek = int.parse(rangeMatch.group(1)!);
      final endWeek = int.parse(rangeMatch.group(2)!);
      if (startWeek <= 0 || endWeek < startWeek) {
        throw FormatException('Invalid week range: $rawText');
      }
      final parity = switch (rangeMatch.group(3)) {
        '单周' => WeekParity.odd,
        '双周' => WeekParity.even,
        _ => WeekParity.all,
      };
      return WeekRule.range(
        rawText: rawText,
        startWeek: startWeek,
        endWeek: endWeek,
        parity: parity,
      );
    }

    throw FormatException('Unsupported week rule: $rawText');
  }

  static int parseWeekday(String text) {
    final index = weekdays.indexOf(_cleanString(text));
    if (index == -1) {
      throw FormatException('Unsupported weekday: $text');
    }
    return index + 1;
  }

  static List<dom.Element> _directCells(dom.Element row) =>
      row.children.where((child) => child.localName == 'td').toList();

  static List<String> _fallbackTeachers(dom.Element cell) => _cleanText(
    cell,
  ).split(' ').where((teacher) => teacher.isNotEmpty).toList();

  static String? _firstLink(dom.Element cell) {
    final href = cell.querySelector('a')?.attributes['href'];
    return href == null || href.trim().isEmpty ? null : href.trim();
  }

  static String _cleanText(dom.Element element) => _cleanString(element.text);

  static String _cleanString(String value) =>
      value.replaceAll('\u00a0', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

  static String _compact(String value) =>
      _cleanString(value).replaceAll(' ', '');
}
