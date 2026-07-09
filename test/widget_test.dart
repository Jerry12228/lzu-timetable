import 'dart:io';

import 'package:course_schedule/app/course_schedule_app.dart';
import 'package:course_schedule/models/schedule_models.dart';
import 'package:course_schedule/services/imported_semester_store.dart';
import 'package:course_schedule/services/semester_importer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late final semester = _loadSampleSemester();

  testWidgets('shows semester controls and missing start date hint', (
    tester,
  ) async {
    await _pumpSchedule(tester, semester);

    expect(find.text('课程表'), findsOneWidget);
    expect(find.text('2025-2026-2学期'), findsOneWidget);
    expect(find.text('第1周 · 开学日期未配置'), findsOneWidget);
    expect(find.text('节次'), findsOneWidget);
    expect(find.text('星期一'), findsOneWidget);
    expect(find.text('第1节'), findsOneWidget);
    expect(find.text('中午1'), findsOneWidget);
    expect(find.text('第12节'), findsOneWidget);
    expect(find.text('中国近现代史纲要'), findsOneWidget);
    expect(find.text('无固定时间'), findsNothing);
    expect(find.text('通信原理'), findsNothing);
  });

  testWidgets('keeps schedule usable on Android phone width', (tester) async {
    await _pumpSchedule(tester, semester, size: const Size(390, 844));

    expect(find.text('课程表'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('open-import-page-button')),
      findsOneWidget,
    );
    expect(find.text('2025-2026-2学期'), findsOneWidget);
    expect(find.text('第1周 · 开学日期未配置'), findsOneWidget);
    expect(find.text('节次'), findsOneWidget);
    expect(find.text('星期一'), findsOneWidget);
    expect(find.text('第1节'), findsOneWidget);
    expect(tester.takeException(), isNull);
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

  testWidgets('opens standalone import page', (tester) async {
    await _pumpSchedule(tester, semester);

    await tester.tap(find.byKey(const ValueKey('open-import-page-button')));
    await tester.pumpAndSettle();

    expect(find.text('导入课程表'), findsOneWidget);
    expect(find.byKey(const ValueKey('import-name-field')), findsOneWidget);
    expect(find.byKey(const ValueKey('import-html-field')), findsOneWidget);
  });

  testWidgets('validates required import fields before preview', (
    tester,
  ) async {
    await _pumpSchedule(tester, semester);
    await tester.tap(find.byKey(const ValueKey('open-import-page-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('preview-import-button')));
    await tester.pumpAndSettle();

    expect(find.text('请输入课表名称'), findsOneWidget);
  });

  testWidgets('rejects duplicate imported schedule names', (tester) async {
    await _pumpSchedule(tester, semester);
    await tester.tap(find.byKey(const ValueKey('open-import-page-button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('import-name-field')),
      ' 2025-2026-2学期 ',
    );
    await tester.enterText(
      find.byKey(const ValueKey('import-date-field')),
      '2026-02-23',
    );
    await tester.enterText(
      find.byKey(const ValueKey('import-html-field')),
      File('assets/raw/2025-2026-2-courses.html').readAsStringSync(),
    );
    await tester.tap(find.byKey(const ValueKey('preview-import-button')));
    await tester.pumpAndSettle();

    expect(find.text('课表名称已存在，请修改名称'), findsOneWidget);
  });

  testWidgets('previews pasted html and disables confirm after edits', (
    tester,
  ) async {
    await _pumpSchedule(tester, semester);
    await tester.tap(find.byKey(const ValueKey('open-import-page-button')));
    await tester.pumpAndSettle();
    await _enterValidImportForm(tester, '导入课表');

    await tester.tap(find.byKey(const ValueKey('preview-import-button')));
    await tester.pumpAndSettle();

    expect(find.text('预览结果'), findsOneWidget);
    expect(find.text('19 门'), findsOneWidget);
    expect(find.text('2026-02-23 - 2026-03-01'), findsOneWidget);
    expect(find.text('预览周次'), findsOneWidget);
    expect(find.text('节次'), findsOneWidget);
    expect(find.text('星期一'), findsOneWidget);
    expect(find.text('第1节'), findsOneWidget);
    expect(find.text('中国近现代史纲要'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('confirm-import-button')),
          )
          .onPressed,
      isNotNull,
    );

    await tester.enterText(
      find.byKey(const ValueKey('import-name-field')),
      '导入课表-改名',
    );
    await tester.pumpAndSettle();

    expect(find.text('预览结果'), findsNothing);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('confirm-import-button')),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('switches week inside import preview timetable', (tester) async {
    await _pumpSchedule(tester, semester);
    await tester.tap(find.byKey(const ValueKey('open-import-page-button')));
    await tester.pumpAndSettle();
    await _enterValidImportForm(tester, '导入课表');

    await tester.tap(find.byKey(const ValueKey('preview-import-button')));
    await tester.pumpAndSettle();

    expect(find.text('2026-02-23 - 2026-03-01'), findsOneWidget);
    expect(find.text('大学生心理健康（网络共享课）'), findsNothing);

    await tester.ensureVisible(
      find.byKey(const ValueKey('preview-week-dropdown')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('preview-week-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('第2周').last);
    await tester.pumpAndSettle();

    expect(find.text('2026-03-02 - 2026-03-08'), findsOneWidget);
    expect(find.text('大学生心理健康（网络共享课）'), findsOneWidget);
  });

  testWidgets('confirms preview and selects imported schedule', (tester) async {
    final store = await _emptyStore();
    await _pumpSchedule(tester, semester, store: store);
    await tester.tap(find.byKey(const ValueKey('open-import-page-button')));
    await tester.pumpAndSettle();
    await _enterValidImportForm(tester, '导入课表');

    await tester.tap(find.byKey(const ValueKey('preview-import-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-import-button')));
    await tester.pumpAndSettle();

    expect(find.text('导入课表'), findsOneWidget);
    expect(find.text('2026-02-23 - 2026-03-01'), findsOneWidget);
    expect((await store.loadRecords()).single.displayName, '导入课表');
  });
}

Semester _loadSampleSemester() {
  return SemesterImporter.parseCourseHtml(
    semesterId: '2025-2026-2',
    displayName: '2025-2026-2学期',
    termStartDate: null,
    courseHtml: File('assets/raw/2025-2026-2-courses.html').readAsStringSync(),
  );
}

Future<void> _pumpSchedule(
  WidgetTester tester,
  Semester semester, {
  ImportedSemesterStore? store,
  Size size = const Size(1280, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  final importedStore = store ?? await _emptyStore();
  await tester.pumpWidget(
    CourseScheduleApp(
      semestersFuture: Future.value([semester]),
      importedSemesterStore: importedStore,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _enterValidImportForm(
  WidgetTester tester,
  String displayName,
) async {
  await tester.enterText(
    find.byKey(const ValueKey('import-name-field')),
    displayName,
  );
  await tester.enterText(
    find.byKey(const ValueKey('import-date-field')),
    '2026-02-23',
  );
  await tester.enterText(
    find.byKey(const ValueKey('import-html-field')),
    File('assets/raw/2025-2026-2-courses.html').readAsStringSync(),
  );
}

Future<ImportedSemesterStore> _emptyStore() async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  return ImportedSemesterStore(preferences: preferences);
}
