import 'dart:convert';
import 'dart:io';

import 'package:course_schedule/models/schedule_models.dart';
import 'package:course_schedule/services/imported_semester_store.dart';
import 'package:course_schedule/services/semester_importer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('stores parsed semester JSON without retaining source html', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = ImportedSemesterStore(preferences: preferences);

    await store.addRecord(
      semester: _sampleSemester(displayName: '导入课表'),
      existingDisplayNames: const ['2025-2026-2学期'],
    );

    final raw = preferences
        .getStringList('course_schedule_imported_semesters_v1')!
        .single;
    expect(raw, isNot(contains('courseHtml')));
    expect(raw, isNot(contains('weekRule')));
    expect(raw, isNot(contains('<table')));
    expect((jsonDecode(raw) as Map)['semester'], isA<Map>());

    final records = await store.loadRecords();
    expect(records, hasLength(1));
    expect(records.single.displayName, '导入课表');
    expect(records.single.termStartDate, DateTime(2026, 2, 23));

    final semesters = await store.loadSemesters();
    expect(semesters.single.displayName, '导入课表');
    expect(semesters.single.courses, hasLength(19));
    expect(semesters.single.dateRangeForWeek(1)!.end, DateTime(2026, 3, 1));
  });

  test('migrates previous HTML records to parsed semester JSON', () async {
    final html = File('assets/raw/2025-2026-2-courses.html').readAsStringSync();
    SharedPreferences.setMockInitialValues({
      'course_schedule_imported_semesters_v1': [
        jsonEncode({
          'id': 'legacy-id',
          'displayName': '旧课表',
          'termStartDate': '2026-02-23',
          'courseHtml': html,
          'createdAt': '2026-01-01T00:00:00.000',
        }),
      ],
    });
    final preferences = await SharedPreferences.getInstance();
    final store = ImportedSemesterStore(preferences: preferences);

    final records = await store.loadRecords();

    expect(records.single.semester.courses, hasLength(19));
    final migrated = preferences
        .getStringList('course_schedule_imported_semesters_v1')!
        .single;
    expect(migrated, isNot(contains('courseHtml')));
    expect(migrated, contains('"semester"'));
  });

  test('rejects duplicate display names before saving', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = ImportedSemesterStore(preferences: preferences);

    await expectLater(
      store.addRecord(
        semester: _sampleSemester(displayName: ' 2025-2026-2学期 '),
        existingDisplayNames: const ['2025-2026-2学期'],
      ),
      throwsA(isA<DuplicateSemesterNameException>()),
    );

    expect(await store.loadRecords(), isEmpty);
  });

  test('updates and deletes JSON course schedules persistently', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = ImportedSemesterStore(preferences: preferences);

    final added = await store.addRecord(
      semester: _sampleSemester(displayName: '原课表'),
      existingDisplayNames: const ['2025-2026-2学期'],
    );
    final updated = await store.saveRecord(
      semesterId: added.id,
      semester: _sampleSemester(
        displayName: '修改后的课表',
        termStartDate: DateTime(2026, 3, 2),
      ),
      existingDisplayNames: const ['2025-2026-2学期'],
    );

    expect(updated.id, added.id);
    expect((await store.loadRecords()).single.displayName, '修改后的课表');

    await store.deleteSemester(added.id);

    expect(await store.loadRecords(), isEmpty);
  });
}

Semester _sampleSemester({
  String displayName = '2025-2026-2学期',
  DateTime? termStartDate,
}) {
  return SemesterImporter.parseCourseHtml(
    semesterId: 'preview',
    displayName: displayName,
    termStartDate: termStartDate ?? DateTime(2026, 2, 23),
    courseHtml: File('assets/raw/2025-2026-2-courses.html').readAsStringSync(),
  );
}
