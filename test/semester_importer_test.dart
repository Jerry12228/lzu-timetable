import 'dart:io';

import 'package:course_schedule/services/default_periods.dart';
import 'package:course_schedule/services/semester_importer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final semester = SemesterImporter.parseFromHtml(
    semesterId: '2025-2026-2',
    displayName: '2025-2026-2学期',
    termStartDate: null,
    courseHtml: File('assets/raw/2025-2026-2-courses.html').readAsStringSync(),
    periodHtml: File('assets/raw/periods.html').readAsStringSync(),
  );

  test('default periods are hardcoded and reusable', () {
    expect(DefaultPeriods.all, hasLength(48));
    final morning = DefaultPeriods.all.firstWhere(
      (period) => period.name == '上午12节',
    );
    expect(morning.sections, ['第1节', '第2节']);
    expect(morning.startTime, '08:30');
    expect(morning.endTime, '10:10');

    final noon = DefaultPeriods.all.firstWhere(
      (period) => period.name == '中午1-2节',
    );
    expect(noon.sections, ['中午1节', '中午2节']);

    final evening = DefaultPeriods.all.firstWhere(
      (period) => period.name == '晚9-11节',
    );
    expect(evening.sections, ['第9节', '第10节', '第11节']);
  });

  test('parses bundled sample from course html only', () {
    final courseOnlySemester = SemesterImporter.parseCourseHtml(
      semesterId: 'course-only',
      displayName: '课程HTML导入',
      termStartDate: DateTime(2026, 2, 23),
      courseHtml: File(
        'assets/raw/2025-2026-2-courses.html',
      ).readAsStringSync(),
    );

    expect(courseOnlySemester.courses, hasLength(19));
    expect(courseOnlySemester.periods, hasLength(48));
    expect(
      courseOnlySemester.dateRangeForWeek(1)!.start,
      DateTime(2026, 2, 23),
    );
    expect(courseOnlySemester.dateRangeForWeek(1)!.end, DateTime(2026, 3, 1));
  });

  test('scopes courses to the course table in a complete academic page', () {
    final courseHtml = File(
      'assets/raw/2025-2026-2-courses.html',
    ).readAsStringSync();
    final completePageHtml = File(
      'assets/raw/lzu-currcourse-page.html',
    ).readAsStringSync();

    final completePageSemester = SemesterImporter.parseCourseHtml(
      semesterId: 'complete-page',
      displayName: '完整页面导入',
      termStartDate: null,
      courseHtml: '$courseHtml\n$completePageHtml',
    );

    expect(completePageSemester.courses, hasLength(19));
  });

  test('parses bundled sample counts', () {
    expect(semester.courses, hasLength(19));
    expect(semester.periods, hasLength(48));
    expect(semester.maxWeek, 17);
  });

  test('expands imported schedules into individual weekly sessions', () {
    final botanyLab = semester.courses.firstWhere(
      (course) => course.name == '植物学实验',
    );
    expect(botanyLab.teachers, ['林雯', '赵宁', '杨梅', '孙丽娟']);
    expect(botanyLab.sessions, isNotEmpty);
    expect(botanyLab.sessions.every((session) => session.week > 0), isTrue);
    expect(botanyLab.sessions.first.periodName, '上午1-4节');
    expect(botanyLab.sessions.last.location, '陇山堂A323');

    final calculus = semester.courses.firstWhere(
      (course) => course.name == '高等数学（同济版）B（2）',
    );
    expect(calculus.sessions, hasLength(37));
    expect(
      calculus.sessions.where((session) => session.week == 9),
      hasLength(3),
    );
    expect(
      calculus.sessions.where((session) => session.week == 15),
      hasLength(3),
    );
  });

  test('keeps courses without fixed schedule outside weekly sessions', () {
    final unscheduledNames = semester.coursesWithoutFixedSchedule
        .map((course) => course.name)
        .toList();
    expect(unscheduledNames, ['通信原理', '漫画艺术欣赏与创作（网络共享课）', '男生穿搭技巧']);
  });

  test('expands range, even-week, and explicit week expressions', () {
    expect(SemesterImporter.parseWeeks('1-17周全周'), [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
    ]);
    expect(SemesterImporter.parseWeeks('2-16周双周'), [
      2,
      4,
      6,
      8,
      10,
      12,
      14,
      16,
    ]);
    expect(SemesterImporter.parseWeeks('第2,6,10周'), [2, 6, 10]);
    expect(SemesterImporter.parseWeeks('第9周'), [9]);
    expect(SemesterImporter.parseWeeks('第15周'), [15]);
    expect(SemesterImporter.parseWeeks('第16周'), [16]);
  });

  test('builds weekly scheduled course list', () {
    final week2Names = semester
        .scheduledCoursesForWeek(2)
        .map((item) => item.course.name)
        .toList();
    expect(week2Names, contains('中国近现代史纲要'));
    expect(week2Names, contains('大学英语（3/4）'));
    expect(week2Names, contains('大学生心理健康（网络共享课）'));

    final week3Names = semester
        .scheduledCoursesForWeek(3)
        .map((item) => item.course.name)
        .toList();
    expect(week3Names, isNot(contains('大学生心理健康（网络共享课）')));
  });
}
