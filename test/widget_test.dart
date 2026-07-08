import 'dart:io';
import 'dart:ui';

import 'package:course_schedule/app/course_schedule_app.dart';
import 'package:course_schedule/models/schedule_models.dart';
import 'package:course_schedule/services/semester_importer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final semester = _loadSampleSemester();

  testWidgets('shows semester controls and missing start date hint', (
    tester,
  ) async {
    await _pumpSchedule(tester, semester);

    expect(find.text('课程表'), findsOneWidget);
    expect(find.text('2025-2026-2学期'), findsOneWidget);
    expect(find.text('第1周 · 开学日期未配置'), findsOneWidget);
    expect(find.text('中国近现代史纲要'), findsOneWidget);
  });

  testWidgets('switches week and updates visible courses', (tester) async {
    await _pumpSchedule(tester, semester);

    expect(find.text('大学生心理健康（网络共享课）'), findsNothing);

    await tester.tap(find.text('第1周').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('第2周').last);
    await tester.pumpAndSettle();

    expect(find.text('第2周 · 开学日期未配置'), findsOneWidget);
    expect(find.text('大学生心理健康（网络共享课）'), findsOneWidget);
  });

  testWidgets('opens course detail dialog from a course tile', (tester) async {
    await _pumpSchedule(tester, semester);

    await tester.tap(find.text('中国近现代史纲要').first);
    await tester.pumpAndSettle();

    expect(find.text('课程号'), findsOneWidget);
    expect(find.text('1309061'), findsOneWidget);
    expect(find.text('任课教师'), findsOneWidget);
    expect(find.text('关闭'), findsOneWidget);
  });
}

Semester _loadSampleSemester() {
  return SemesterImporter.parseFromHtml(
    semesterId: '2025-2026-2',
    displayName: '2025-2026-2学期',
    termStartDate: null,
    courseHtml: File('assets/raw/2025-2026-2-courses.html').readAsStringSync(),
    periodHtml: File('assets/raw/periods.html').readAsStringSync(),
  );
}

Future<void> _pumpSchedule(WidgetTester tester, Semester semester) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    CourseScheduleApp(semestersFuture: Future.value([semester])),
  );
  await tester.pumpAndSettle();
}
