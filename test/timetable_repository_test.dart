import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lzu_timetable/database/app_database.dart';
import 'package:lzu_timetable/models/schedule_models.dart';
import 'package:lzu_timetable/services/semester_importer.dart';
import 'package:lzu_timetable/services/timetable_repository.dart';

void main() {
  late AppDatabase database;
  late TimetableRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = TimetableRepository(database);
  });

  tearDown(() => database.close());

  test('emits the initial empty schedule list', () async {
    expect(
      await repository.watchSemesters().first.timeout(
        const Duration(seconds: 5),
      ),
      isEmpty,
    );
  });

  test(
    'stores normalized relational data without periods or source html',
    () async {
      final id = await repository.saveSchedule(
        semester: _sampleSemester(displayName: '导入课表'),
        replaceImportedCourses: true,
      );

      final semester = await repository.loadSemester(id);
      expect(semester, isNotNull);
      expect(semester!.displayName, '导入课表');
      expect(semester.courses, hasLength(19));
      expect(semester.weekCount, 17);

      final schema = await database
          .customSelect(
            "SELECT name, sql FROM sqlite_master WHERE type IN ('table', 'view')",
          )
          .get();
      final names = schema.map((row) => row.read<String>('name')).toSet();
      expect(names, contains('effective_course_versions'));
      expect(names, isNot(contains('periods')));
      final sql = schema
          .map((row) => row.readNullable<String>('sql') ?? '')
          .join();
      expect(sql, isNot(contains('courseHtml')));
      expect(sql, isNot(contains('periodName')));
      expect(sql, isNot(contains('weekRule')));

      final sessionCount = semester.courses
          .expand((course) => course.sessions)
          .length;
      final meetingCount = await database
          .customSelect('SELECT COUNT(*) AS amount FROM course_meetings')
          .getSingle();
      expect(meetingCount.read<int>('amount'), lessThan(sessionCount));
    },
  );

  test(
    'validates trimmed names and supports update plus cascading delete',
    () async {
      final id = await repository.saveSchedule(
        semester: _sampleSemester(displayName: ' 原课表 '),
        replaceImportedCourses: true,
      );
      expect((await repository.loadSemester(id))!.displayName, '原课表');

      await expectLater(
        repository.saveSchedule(
          semester: _sampleSemester(displayName: '原课表'),
          replaceImportedCourses: true,
        ),
        throwsA(isA<DuplicateSemesterNameException>()),
      );

      final current = (await repository.loadSemester(id))!;
      await repository.saveSchedule(
        semesterId: id,
        semester: current.copyWith(
          displayName: '修改后的课表',
          termStartDate: DateTime(2026, 3, 2),
        ),
        replaceImportedCourses: false,
      );
      final updated = (await repository.loadSemester(id))!;
      expect(updated.displayName, '修改后的课表');
      expect(updated.termStartDate, DateTime(2026, 3, 2));
      expect(updated.courses, hasLength(19));

      await repository.deleteSemester(id);
      expect(await repository.loadSemester(id), isNull);
      for (final table in [
        'courses',
        'course_versions',
        'course_teachers',
        'course_meetings',
        'meeting_weeks',
      ]) {
        final count = await database
            .customSelect('SELECT COUNT(*) AS amount FROM $table')
            .getSingle();
        expect(count.read<int>('amount'), 0, reason: table);
      }
    },
  );

  test('reimport updates base data while retaining local override', () async {
    final imported = _sampleSemester();
    final id = await repository.saveSchedule(
      semester: imported,
      replaceImportedCourses: true,
    );
    final firstLoad = (await repository.loadSemester(id))!;
    final source = firstLoad.courses.firstWhere(
      (course) => course.name == '高等数学（同济版）B（2）',
    );
    await repository.saveCustomization(
      semesterId: id,
      customization: CourseCustomization(
        courseId: source.id,
        metadata: CourseMetadata.fromCourse(source).copyWith(name: '高等数学 B'),
        sessions: source.sessions.take(1).toList(),
      ),
    );

    final withoutSource = imported.copyWith(
      displayName: firstLoad.displayName,
      courses: [
        for (final course in imported.courses)
          if (course.courseCode != source.courseCode ||
              course.sequence != source.sequence)
            course,
      ],
    );
    await repository.saveSchedule(
      semesterId: id,
      semester: withoutSource,
      replaceImportedCourses: true,
    );
    expect(
      (await repository.loadSemester(id))!.courses.map((course) => course.name),
      isNot(contains('高等数学 B')),
    );

    await repository.saveSchedule(
      semesterId: id,
      semester: imported,
      replaceImportedCourses: true,
    );
    final restored = (await repository.loadSemester(id))!.courses.firstWhere(
      (course) =>
          course.courseCode == source.courseCode &&
          course.sequence == source.sequence,
    );
    expect(restored.id, source.id);
    expect(restored.name, '高等数学 B');
    expect(restored.sessions, hasLength(1));

    await repository.clearImportedOverride(restored.id);
    final reset = (await repository.loadSemester(
      id,
    ))!.courses.firstWhere((course) => course.id == restored.id);
    expect(reset.name, '高等数学（同济版）B（2）');
    expect(reset.sessions.length, greaterThan(1));
  });

  test('supports manual course CRUD and flexible course queries', () async {
    final id = await repository.saveSchedule(
      semester: _sampleSemester(),
      replaceImportedCourses: true,
    );
    final manualId = await repository.saveManualCourse(
      semesterId: id,
      course: const Course(
        origin: CourseOrigin.manual,
        courseCode: null,
        sequence: null,
        name: '手动研讨课',
        teachers: ['王老师'],
        credits: '',
        selectionType: '',
        assessment: '',
        examNature: '',
        deferredExam: '',
        material: '',
        courseDetailLink: null,
        teachingRecordLink: null,
        processScoreLink: null,
        sessions: [
          CourseSession(
            week: 2,
            weekday: 7,
            startSection: 0,
            endSection: 1,
            location: '秦岭堂研讨室',
          ),
          CourseSession(
            week: 4,
            weekday: 7,
            startSection: 0,
            endSection: 1,
            location: '秦岭堂研讨室',
          ),
        ],
      ),
    );

    expect(
      await repository.searchCourses(semesterId: id, teacher: '王老师'),
      hasLength(1),
    );
    expect(
      await repository.searchCourses(
        semesterId: id,
        text: '研讨室',
        week: 4,
        weekday: 7,
      ),
      hasLength(1),
    );

    final manual = (await repository.loadSemester(
      id,
    ))!.courses.firstWhere((course) => course.id == manualId);
    await repository.saveCustomization(
      semesterId: id,
      customization: CourseCustomization(
        courseId: manual.id,
        metadata: CourseMetadata.fromCourse(manual).copyWith(name: '更新后的研讨课'),
        sessions: const [],
      ),
    );
    final untimed = (await repository.loadSemester(
      id,
    ))!.courses.firstWhere((course) => course.id == manualId);
    expect(untimed.name, '更新后的研讨课');
    expect(untimed.sessions, isEmpty);

    await repository.saveCustomization(
      semesterId: id,
      customization: CourseCustomization.deleted(untimed),
    );
    expect(
      (await repository.loadSemester(id))!.courses.map((course) => course.id),
      isNot(contains(manualId)),
    );
  });

  test('rolls back a failed aggregate import', () async {
    final valid = _sampleSemester();
    final invalidCourse = valid.courses.first.copyWith(name: '无标识课程');
    final invalid = valid.copyWith(
      displayName: '失败课表',
      courses: [
        invalidCourse,
        Course(
          courseCode: '',
          sequence: '',
          name: '坏数据',
          teachers: const [],
          credits: '',
          selectionType: '',
          assessment: '',
          examNature: '',
          deferredExam: '',
          material: '',
          courseDetailLink: null,
          teachingRecordLink: null,
          processScoreLink: null,
          sessions: const [],
        ),
      ],
    );

    await expectLater(
      repository.saveSchedule(semester: invalid, replaceImportedCourses: true),
      throwsA(isA<FormatException>()),
    );
    expect(await repository.loadSemesters(), isEmpty);
  });
}

Semester _sampleSemester({String displayName = '2025-2026-2学期'}) {
  final parsed = SemesterImporter.parseCourseHtml(
    displayName: displayName,
    termStartDate: DateTime(2026, 2, 23),
    courseHtml: File('assets/raw/2025-2026-2-courses.html').readAsStringSync(),
  );
  return parsed.copyWith(weekCount: parsed.lastScheduledWeek);
}
