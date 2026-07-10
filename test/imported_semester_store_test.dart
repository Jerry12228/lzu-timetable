import 'dart:io';

import 'package:course_schedule/services/imported_semester_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('saves and restores imported semester records', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = ImportedSemesterStore(preferences: preferences);
    final html = File('assets/raw/2025-2026-2-courses.html').readAsStringSync();

    await store.addRecord(
      displayName: '导入课表',
      termStartDate: DateTime(2026, 2, 23),
      courseHtml: html,
      existingDisplayNames: const ['2025-2026-2学期'],
    );

    final records = await store.loadRecords();
    expect(records, hasLength(1));
    expect(records.single.displayName, '导入课表');
    expect(records.single.termStartDate, DateTime(2026, 2, 23));

    final semesters = await store.loadSemesters();
    expect(semesters.single.displayName, '导入课表');
    expect(semesters.single.courses, hasLength(19));
    expect(semesters.single.dateRangeForWeek(1)!.end, DateTime(2026, 3, 1));
  });

  test('rejects duplicate display names before saving', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = ImportedSemesterStore(preferences: preferences);
    final html = File('assets/raw/2025-2026-2-courses.html').readAsStringSync();

    await expectLater(
      store.addRecord(
        displayName: ' 2025-2026-2学期 ',
        termStartDate: DateTime(2026, 2, 23),
        courseHtml: html,
        existingDisplayNames: const ['2025-2026-2学期'],
      ),
      throwsA(isA<DuplicateSemesterNameException>()),
    );

    expect(await store.loadRecords(), isEmpty);
  });

  test('updates and deletes course schedules persistently', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = ImportedSemesterStore(preferences: preferences);
    final html = File('assets/raw/2025-2026-2-courses.html').readAsStringSync();

    final added = await store.addRecord(
      displayName: '原课表',
      termStartDate: DateTime(2026, 2, 23),
      courseHtml: html,
      existingDisplayNames: const ['2025-2026-2学期'],
    );
    final updated = await store.saveRecord(
      semesterId: added.id,
      displayName: '修改后的课表',
      termStartDate: DateTime(2026, 3, 2),
      courseHtml: html,
      existingDisplayNames: const ['2025-2026-2学期'],
    );

    expect(updated.id, added.id);
    expect((await store.loadRecords()).single.displayName, '修改后的课表');

    await store.deleteSemester(added.id);

    expect(await store.loadRecords(), isEmpty);
    expect(await store.loadHiddenBundledSemesterIds(), contains(added.id));
  });
}
