import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import '../models/schedule_models.dart';
import '../models/timetable_sections.dart';
import 'default_periods.dart';

class SemesterImporter {
  const SemesterImporter._();

  static Semester parseCourseHtml({
    int semesterId = 0,
    required String displayName,
    required DateTime? termStartDate,
    required String courseHtml,
  }) {
    final courses = _parseCourses(courseHtml);
    return Semester(
      id: semesterId,
      displayName: displayName,
      termStartDate: termStartDate,
      courses: courses,
    );
  }

  static List<Course> _parseCourses(String html) {
    final document = html_parser.parse(html);
    final courseTable = _findCourseTable(document);
    final rows = courseTable.querySelectorAll('tr.infolist_common');
    if (rows.isEmpty) {
      throw const FormatException('未找到课程列表，请确认粘贴或上传的是课程列表 HTML');
    }
    final periodsByName = {
      for (final period in AcademicPeriodMappings.all)
        _compact(period.name): period,
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
      return Course(
        origin: CourseOrigin.imported,
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
        sessions: _parseSessions(cells[9], periodsByName),
      );
    }).toList();
  }

  static dom.Element _findCourseTable(dom.Document document) {
    for (final table in document.querySelectorAll('table.infolist_tab')) {
      final headers = table
          .querySelectorAll('th')
          .map(_cleanText)
          .map(_compact)
          .toSet();
      if (headers.contains('课程号') &&
          headers.contains('课程名称') &&
          headers.contains('上课时间、地点')) {
        return table;
      }
    }
    throw const FormatException('未找到课程列表，请确认粘贴或上传的是课程列表 HTML');
  }

  static List<CourseSession> _parseSessions(
    dom.Element scheduleCell,
    Map<String, AcademicPeriodMapping> periodsByName,
  ) {
    final sessions = <CourseSession>[];
    for (final row in scheduleCell.querySelectorAll('table.none tr')) {
      final cells = _directCells(row);
      if (cells.length < 4) continue;
      final weekText = _cleanText(cells[0]);
      final weekdayText = _cleanText(cells[1]);
      final periodName = _cleanText(cells[2]);
      final location = _cleanText(cells[3]);
      if (weekText.isEmpty || weekdayText.isEmpty || periodName.isEmpty) {
        continue;
      }
      final period = periodsByName[_compact(periodName)];
      if (period == null || period.sections.isEmpty) {
        throw FormatException('无法识别上课节次：$periodName');
      }
      final startSection = TimetableSections.orderOf(period.sections.first);
      final endSection = TimetableSections.orderOf(period.sections.last);
      for (final week in parseWeeks(weekText)) {
        sessions.add(
          CourseSession(
            week: week,
            weekday: parseWeekday(weekdayText),
            startSection: startSection,
            endSection: endSection,
            location: location,
          ),
        );
      }
    }
    return sessions;
  }

  static List<int> parseWeeks(String rawText) {
    final compact = _compact(rawText).replaceAll('，', ',').replaceAll('、', ',');
    final explicitMatch = RegExp(r'^第([\d,]+)周$').firstMatch(compact);
    if (explicitMatch != null) {
      final weeks = explicitMatch
          .group(1)!
          .split(',')
          .map(int.parse)
          .where((week) => week > 0)
          .toList();
      if (weeks.isEmpty) throw FormatException('Invalid week rule: $rawText');
      return weeks.toSet().toList()..sort();
    }
    final rangeMatch = RegExp(r'^(\d+)-(\d+)周(全周|单周|双周)?$').firstMatch(compact);
    if (rangeMatch != null) {
      final startWeek = int.parse(rangeMatch.group(1)!);
      final endWeek = int.parse(rangeMatch.group(2)!);
      if (startWeek <= 0 || endWeek < startWeek) {
        throw FormatException('Invalid week range: $rawText');
      }
      final suffix = rangeMatch.group(3);
      return [
        for (var week = startWeek; week <= endWeek; week++)
          if (suffix != '单周' || week.isOdd)
            if (suffix != '双周' || week.isEven) week,
      ];
    }
    throw FormatException('Unsupported week rule: $rawText');
  }

  static int parseWeekday(String text) {
    final index = weekdays.indexOf(_cleanString(text));
    if (index == -1) throw FormatException('Unsupported weekday: $text');
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
