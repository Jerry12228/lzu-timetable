import 'dart:io';

import 'package:course_schedule/app/course_schedule_app.dart';
import 'package:course_schedule/models/schedule_models.dart';
import 'package:course_schedule/services/course_customization_store.dart';
import 'package:course_schedule/services/imported_semester_store.dart';
import 'package:course_schedule/services/semester_importer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late final semester = _loadSampleSemester();

  testWidgets('shows semester controls and timetable headers', (tester) async {
    await _pumpSchedule(tester, semester);

    expect(find.text('课程表'), findsOneWidget);
    expect(find.text('2025-2026-2学期'), findsOneWidget);
    expect(find.textContaining('开学日期未配置'), findsNothing);
    expect(find.text('节次'), findsOneWidget);
    expect(find.text('星期一'), findsOneWidget);
    expect(find.text('02-23'), findsOneWidget);
    expect(find.text('03-01'), findsOneWidget);
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
      find.byKey(const ValueKey('mobile-schedule-menu-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('open-manage-schedules-button')),
      findsNothing,
    );
    expect(find.textContaining('开学日期未配置'), findsNothing);
    expect(find.text('节次'), findsOneWidget);
    expect(find.text('星期一'), findsOneWidget);
    expect(find.text('星期日'), findsOneWidget);
    expect(find.text('02-23'), findsOneWidget);
    expect(find.text('第1节'), findsOneWidget);
    expect(find.text('天山堂A208'), findsOneWidget);

    final tableSize = tester.getSize(
      find.byKey(const ValueKey('timetable-canvas')),
    );
    expect(tableSize.width, lessThanOrEqualTo(382));

    await tester.tap(find.byKey(const ValueKey('mobile-schedule-menu-button')));
    await tester.pumpAndSettle();

    expect(find.text('学期'), findsOneWidget);
    expect(find.text('管理课程表'), findsOneWidget);

    await tester.tap(find.text('学期'));
    await tester.pumpAndSettle();

    expect(find.text('选择学期'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('mobile-semester-picker')),
      findsOneWidget,
    );
    expect(find.text('2025-2026-2学期'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switches week and updates visible courses', (tester) async {
    await _pumpSchedule(tester, semester);

    expect(find.text('大学生心理健康（网络共享课）'), findsNothing);

    await tester.tap(find.text('第1周').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('第2周').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('开学日期未配置'), findsNothing);
    expect(find.text('大学生心理健康（网络共享课）'), findsOneWidget);
  });

  testWidgets('opens course detail dialog from a course tile', (tester) async {
    await _pumpSchedule(tester, semester);

    await tester.tap(find.text('中国近现代史纲要').first);
    await tester.pumpAndSettle();

    expect(find.text('课程号'), findsOneWidget);
    expect(find.text('1309061'), findsOneWidget);
    expect(find.text('任课教师'), findsOneWidget);
    expect(find.byTooltip('编辑课程'), findsOneWidget);
    expect(find.text('关闭'), findsOneWidget);
  });

  testWidgets('edits course metadata and refreshes the timetable', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final customizationStore = CourseCustomizationStore(
      preferences: preferences,
    );
    await _pumpSchedule(
      tester,
      semester,
      store: ImportedSemesterStore(preferences: preferences),
      customizationStore: customizationStore,
    );

    await tester.tap(find.text('中国近现代史纲要').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('edit-course-button')));
    await tester.pumpAndSettle();

    expect(find.text('编辑课程'), findsOneWidget);
    expect(find.text('课程号'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('course-name-field')),
      '编辑后的课程',
    );
    await tester.tap(find.byKey(const ValueKey('save-course-button')));
    await tester.pumpAndSettle();

    expect(find.text('编辑后的课程'), findsOneWidget);
    final applied = await customizationStore.applyToSemester(semester);
    expect(
      applied.courses
          .firstWhere((course) => course.courseCode == '1309061')
          .name,
      '编辑后的课程',
    );
  });

  testWidgets('edits one session and removes selected sessions', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final customizationStore = CourseCustomizationStore(
      preferences: preferences,
    );
    final source = semester.courses.firstWhere(
      (course) => course.name == '中国近现代史纲要',
    );
    await _pumpSchedule(
      tester,
      semester,
      store: ImportedSemesterStore(preferences: preferences),
      customizationStore: customizationStore,
    );

    await tester.tap(find.text(source.name).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('edit-course-button')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('编辑节次').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('编辑节次').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('session-week-rule-field')),
      '第2周',
    );
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();
    expect(find.textContaining('第2周'), findsOneWidget);

    await tester.ensureVisible(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('delete-selected-sessions-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('delete-selected-sessions-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-course-button')));
    await tester.pumpAndSettle();

    final applied = await customizationStore.applyToSemester(semester);
    final updated = applied.courses.firstWhere(
      (course) =>
          course.courseCode == source.courseCode &&
          course.sequence == source.sequence,
    );
    expect(updated.sessions, hasLength(source.sessions.length - 1));
  });

  testWidgets('confirms before deleting an entire course', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final customizationStore = CourseCustomizationStore(
      preferences: preferences,
    );
    final source = semester.courses.firstWhere(
      (course) => course.name == '中国近现代史纲要',
    );
    await _pumpSchedule(
      tester,
      semester,
      store: ImportedSemesterStore(preferences: preferences),
      customizationStore: customizationStore,
    );

    await tester.tap(find.text(source.name).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('edit-course-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('delete-course-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(find.text('编辑课程'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('delete-course-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();

    final applied = await customizationStore.applyToSemester(semester);
    expect(
      applied.courses.map((course) => course.courseCode),
      isNot(contains(source.courseCode)),
    );
    expect(find.text(source.name), findsNothing);
  });

  testWidgets('opens the schedule management page', (tester) async {
    await _pumpSchedule(tester, semester);

    await tester.tap(
      find.byKey(const ValueKey('open-manage-schedules-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('管理课程表'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('manage-add-schedule-button')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('open-import-page-button')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('manage-add-schedule-button')));
    await tester.pumpAndSettle();

    expect(find.text('教务系统导入'), findsOneWidget);
    expect(find.text('粘贴/上传 HTML'), findsOneWidget);
  });

  testWidgets('keeps the schedule management page usable on Android width', (
    tester,
  ) async {
    await _pumpSchedule(tester, semester, size: const Size(390, 844));
    await _openManagementPage(tester);

    expect(find.text('管理课程表'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('manage-add-schedule-button')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('validates required import fields before preview', (
    tester,
  ) async {
    await _pumpSchedule(tester, semester);
    await _openScheduleEditor(tester);

    await tester.tap(find.byKey(const ValueKey('preview-import-button')));
    await tester.pumpAndSettle();

    expect(find.text('请输入课表名称'), findsOneWidget);
  });

  testWidgets('rejects duplicate imported schedule names', (tester) async {
    await _pumpSchedule(tester, semester);
    await _openScheduleEditor(tester);

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
    await _openScheduleEditor(tester);
    await _enterValidImportForm(tester, '导入课表');

    await tester.tap(find.byKey(const ValueKey('preview-import-button')));
    await tester.pumpAndSettle();

    expect(find.text('预览结果'), findsOneWidget);
    expect(find.text('19 门'), findsOneWidget);
    expect(find.text('02-23'), findsOneWidget);
    expect(find.text('03-01'), findsOneWidget);
    expect(find.text('2026-02-23 - 2026-03-01'), findsNothing);
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
    await _openScheduleEditor(tester);
    await _enterValidImportForm(tester, '导入课表');

    await tester.tap(find.byKey(const ValueKey('preview-import-button')));
    await tester.pumpAndSettle();

    expect(find.text('02-23'), findsWidgets);
    expect(find.text('2026-02-23 - 2026-03-01'), findsNothing);
    expect(find.text('大学生心理健康（网络共享课）'), findsNothing);

    await tester.ensureVisible(
      find.byKey(const ValueKey('preview-week-dropdown')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('preview-week-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('第2周').last);
    await tester.pumpAndSettle();

    expect(find.text('03-02'), findsWidgets);
    expect(find.text('2026-03-02 - 2026-03-08'), findsNothing);
    expect(find.text('大学生心理健康（网络共享课）'), findsOneWidget);
  });

  testWidgets('confirms preview and selects imported schedule', (tester) async {
    final store = await _emptyStore();
    await _pumpSchedule(tester, semester, store: store);
    await _openScheduleEditor(tester);
    await _enterValidImportForm(tester, '导入课表');

    await tester.tap(find.byKey(const ValueKey('preview-import-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-import-button')));
    await tester.pumpAndSettle();

    expect(find.text('导入课表'), findsOneWidget);
    expect(find.text('2026-02-23起 · 19 门课程'), findsWidgets);
    expect((await store.loadRecords()).single.displayName, '导入课表');

    await tester.tap(find.byTooltip('返回课程表'));
    await tester.pumpAndSettle();

    expect(find.text('02-23'), findsWidgets);
    expect(find.text('2026-02-23 - 2026-03-01'), findsNothing);
  });

  testWidgets('edits an imported schedule in the management page', (
    tester,
  ) async {
    final store = await _emptyStore();
    final record = await store.addRecord(
      displayName: '待修改课表',
      termStartDate: DateTime(2026, 2, 23),
      courseHtml: File(
        'assets/raw/2025-2026-2-courses.html',
      ).readAsStringSync(),
      existingDisplayNames: const ['2025-2026-2学期'],
    );
    await _pumpSchedule(tester, semester, store: store);
    await _openManagementPage(tester);

    await tester.tap(find.byKey(ValueKey('edit-schedule-${record.id}')));
    await tester.pumpAndSettle();

    expect(find.text('修改课程表'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('import-name-field')))
          .controller!
          .text,
      '待修改课表',
    );
    await tester.enterText(
      find.byKey(const ValueKey('import-name-field')),
      '已修改课表',
    );
    await tester.tap(find.byKey(const ValueKey('preview-import-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-import-button')));
    await tester.pumpAndSettle();

    final records = await store.loadRecords();
    expect(records, hasLength(1));
    expect(records.single.id, record.id);
    expect(records.single.displayName, '已修改课表');
    expect(find.text('已修改课表'), findsOneWidget);
  });

  testWidgets('deletes an imported schedule in the management page', (
    tester,
  ) async {
    final store = await _emptyStore();
    final record = await store.addRecord(
      displayName: '待删除课表',
      termStartDate: DateTime(2026, 2, 23),
      courseHtml: File(
        'assets/raw/2025-2026-2-courses.html',
      ).readAsStringSync(),
      existingDisplayNames: const ['2025-2026-2学期'],
    );
    await _pumpSchedule(tester, semester, store: store);
    await _openManagementPage(tester);

    await tester.tap(find.byKey(ValueKey('delete-schedule-${record.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await tester.pumpAndSettle();

    expect(await store.loadRecords(), isEmpty);
    expect(find.text('待删除课表'), findsNothing);
  });
}

Semester _loadSampleSemester() {
  return SemesterImporter.parseCourseHtml(
    semesterId: '2025-2026-2',
    displayName: '2025-2026-2学期',
    termStartDate: DateTime(2026, 2, 23),
    courseHtml: File('assets/raw/2025-2026-2-courses.html').readAsStringSync(),
  );
}

Future<void> _pumpSchedule(
  WidgetTester tester,
  Semester semester, {
  ImportedSemesterStore? store,
  CourseCustomizationStore? customizationStore,
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
      courseCustomizationStore: customizationStore,
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

Future<void> _openManagementPage(WidgetTester tester) async {
  final mobileMenu = find.byKey(const ValueKey('mobile-schedule-menu-button'));
  if (mobileMenu.evaluate().isNotEmpty) {
    await tester.tap(mobileMenu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('管理课程表'));
  } else {
    await tester.tap(
      find.byKey(const ValueKey('open-manage-schedules-button')),
    );
  }
  await tester.pumpAndSettle();
}

Future<void> _openScheduleEditor(WidgetTester tester) async {
  await _openManagementPage(tester);
  await tester.tap(find.byKey(const ValueKey('manage-add-schedule-button')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('粘贴/上传 HTML'));
  await tester.pumpAndSettle();
}

Future<ImportedSemesterStore> _emptyStore() async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  return ImportedSemesterStore(preferences: preferences);
}
