import 'dart:io';

import 'package:course_schedule/models/schedule_models.dart';
import 'package:course_schedule/services/course_customization_store.dart';
import 'package:course_schedule/services/semester_importer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late final Semester semester = SemesterImporter.parseCourseHtml(
    semesterId: '2025-2026-2',
    displayName: '2025-2026-2学期',
    termStartDate: DateTime(2026, 2, 23),
    courseHtml: File('assets/raw/2025-2026-2-courses.html').readAsStringSync(),
  );

  test('persists metadata and session overrides across reloads', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = CourseCustomizationStore(preferences: preferences);
    final source = semester.courses.firstWhere(
      (course) => course.name == '高等数学（同济版）B（2）',
    );
    final customization = CourseCustomization(
      courseKey: CourseKey.fromCourse(source),
      metadata: CourseMetadata.fromCourse(source).copyWith(name: '高等数学 B'),
      sessions: source.sessions.take(1).toList(),
    );

    await store.saveCustomization(
      semesterId: semester.id,
      customization: customization,
    );

    expect(
      preferences.getString('course_schedule_course_customizations_v1'),
      isNot(contains('weekRule')),
    );

    final reloadedStore = CourseCustomizationStore(preferences: preferences);
    final reimportedSemester = SemesterImporter.parseCourseHtml(
      semesterId: semester.id,
      displayName: '重新导入的课表',
      termStartDate: DateTime(2026, 2, 23),
      courseHtml: File(
        'assets/raw/2025-2026-2-courses.html',
      ).readAsStringSync(),
    );
    final applied = await reloadedStore.applyToSemester(reimportedSemester);
    final edited = applied.courses.firstWhere(
      (course) =>
          course.courseCode == source.courseCode &&
          course.sequence == source.sequence,
    );
    expect(edited.name, '高等数学 B');
    expect(edited.sessions, hasLength(1));
  });

  test(
    'keeps a course with all sessions removed but removes deleted courses',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final store = CourseCustomizationStore(preferences: preferences);
      final unscheduledSource = semester.courses.firstWhere(
        (course) => course.name == '中国近现代史纲要',
      );
      final deletedSource = semester.courses.firstWhere(
        (course) => course.name == '有机化学',
      );

      await store.saveCustomization(
        semesterId: semester.id,
        customization: CourseCustomization(
          courseKey: CourseKey.fromCourse(unscheduledSource),
          metadata: CourseMetadata.fromCourse(unscheduledSource),
          sessions: const [],
        ),
      );
      await store.saveCustomization(
        semesterId: semester.id,
        customization: CourseCustomization.deleted(deletedSource),
      );

      final applied = await store.applyToSemester(semester);
      expect(
        applied.coursesWithoutFixedSchedule.map((course) => course.courseCode),
        contains(unscheduledSource.courseCode),
      );
      expect(
        applied.courses.map((course) => course.courseCode),
        isNot(contains(deletedSource.courseCode)),
      );
    },
  );
}
