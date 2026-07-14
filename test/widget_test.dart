import 'dart:io';

import 'package:lzu_timetable/app/course_schedule_app.dart';
import 'package:lzu_timetable/app/import_schedule_page.dart';
import 'package:lzu_timetable/models/schedule_models.dart';
import 'package:lzu_timetable/services/course_customization_store.dart';
import 'package:lzu_timetable/services/imported_semester_store.dart';
import 'package:lzu_timetable/services/semester_importer.dart';
import 'package:lzu_timetable/services/theme_preference_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late final semester = _loadSampleSemester();

  testWidgets('starts without a bundled course schedule', (tester) async {
    final store = await _emptyStore();
    await tester.pumpWidget(CourseScheduleApp(importedSemesterStore: store));
    await tester.pumpAndSettle();

    expect(find.text('还没有课程表'), findsOneWidget);
    expect(find.text('2025-2026-2学期'), findsNothing);
  });

  testWidgets('defaults to system theme and persists desktop theme changes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await _pumpSchedule(
      tester,
      semester,
      store: ImportedSemesterStore(preferences: preferences),
      themePreferenceStore: ThemePreferenceStore(preferences: preferences),
    );

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.system,
    );
    expect(
      find.byKey(const ValueKey('desktop-theme-mode-button')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('desktop-theme-mode-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('theme-mode-dark')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect(preferences.getString(ThemePreferenceStore.storageKey), 'dark');

    await tester.tap(find.byKey(const ValueKey('desktop-theme-mode-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('theme-mode-light')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
    expect(preferences.getString(ThemePreferenceStore.storageKey), 'light');

    await tester.tap(find.byKey(const ValueKey('desktop-theme-mode-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('theme-mode-system')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.system,
    );
    expect(preferences.getString(ThemePreferenceStore.storageKey), 'system');
  });

  testWidgets('mobile and empty schedule screens expose theme controls', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await _pumpSchedule(
      tester,
      semester,
      size: const Size(390, 844),
      store: ImportedSemesterStore(preferences: preferences),
      themePreferenceStore: ThemePreferenceStore(preferences: preferences),
    );

    await tester.tap(find.byKey(const ValueKey('mobile-schedule-menu-button')));
    await tester.pumpAndSettle();
    expect(find.text('主题'), findsOneWidget);
    await tester.tap(find.text('主题'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('theme-mode-dark')));
    await tester.pumpAndSettle();
    expect(preferences.getString(ThemePreferenceStore.storageKey), 'dark');

    SharedPreferences.setMockInitialValues({});
    final emptyPreferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      CourseScheduleApp(
        importedSemesterStore: ImportedSemesterStore(
          preferences: emptyPreferences,
        ),
        themePreferenceStore: ThemePreferenceStore(
          preferences: emptyPreferences,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('empty-schedule-menu-button')),
      findsOneWidget,
    );
  });

  testWidgets('selects the current semester and highlights only today header', (
    tester,
  ) async {
    final earlier = semester.copyWith(
      id: 'earlier',
      displayName: '较早课表',
      termStartDate: DateTime(2026, 1, 5),
    );
    final current = semester.copyWith(
      id: 'current',
      displayName: '当前课表',
      termStartDate: DateTime(2026, 2, 23),
    );
    final store = await _emptyStore();
    await tester.pumpWidget(
      CourseScheduleApp(
        semestersFuture: Future.value([earlier, current]),
        importedSemesterStore: store,
        currentDate: DateTime(2026, 4, 1),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前课表'), findsOneWidget);
    expect(find.text('03-30'), findsOneWidget);
    final scheme = Theme.of(
      tester.element(find.byKey(const ValueKey('timetable-header-3'))),
    ).colorScheme;
    expect(_headerBackgroundColor(tester, 3), scheme.primaryContainer);
    expect(_headerBackgroundColor(tester, 2), scheme.surfaceContainerHighest);
  });

  testWidgets(
    'uses first or final week outside the semester without highlight',
    (tester) async {
      await _pumpSchedule(
        tester,
        semester.copyWith(weekCount: 20),
        currentDate: DateTime(2026, 2, 1),
      );

      expect(find.text('02-23'), findsOneWidget);
      final scheme = Theme.of(
        tester.element(find.byKey(const ValueKey('timetable-header-1'))),
      ).colorScheme;
      expect(_headerBackgroundColor(tester, 1), scheme.surfaceContainerHighest);

      await _pumpSchedule(
        tester,
        semester.copyWith(weekCount: 20),
        currentDate: DateTime(2026, 7, 13),
      );
      expect(find.text('07-06'), findsOneWidget);
      expect(_headerBackgroundColor(tester, 1), scheme.surfaceContainerHighest);
    },
  );

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
    expect(find.text('08:30'), findsOneWidget);
    expect(find.text('09:15'), findsOneWidget);
    expect(find.text('中午1'), findsOneWidget);
    expect(find.text('第12节'), findsOneWidget);
    expect(find.text('中国近现代史纲要'), findsOneWidget);
    expect(find.text('无固定时间'), findsNothing);
    expect(find.text('通信原理'), findsNothing);
  });

  testWidgets('dark mode keeps timetable surfaces and today header readable', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      ThemePreferenceStore.storageKey: 'dark',
    });
    final preferences = await SharedPreferences.getInstance();
    await _pumpSchedule(
      tester,
      semester,
      currentDate: DateTime(2026, 2, 23),
      store: ImportedSemesterStore(preferences: preferences),
      themePreferenceStore: ThemePreferenceStore(preferences: preferences),
    );

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
    final theme = Theme.of(
      tester.element(find.byKey(const ValueKey('timetable-header-1'))),
    );
    expect(theme.brightness, Brightness.dark);
    expect(
      _headerBackgroundColor(tester, 1),
      theme.colorScheme.primaryContainer,
    );
    expect(_tableBackgroundColor(tester), theme.colorScheme.surface);
    expect(find.text('天山堂A208'), findsOneWidget);
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
    expect(find.text('08:30'), findsOneWidget);
    expect(find.text('09:15'), findsOneWidget);
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

  testWidgets('adds a course from an empty timetable cell across weeks', (
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

    await tester.tap(find.byKey(const ValueKey('empty-cell-7-第1节')));
    await tester.pumpAndSettle();

    expect(find.text('添加课程'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('quick-add-weeks-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('quick-add-period-dropdown')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('quick-add-section-第1节')), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('午1'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('quick-add-weeks-button')));
    await tester.pumpAndSettle();
    expect(find.text('选择周次'), findsOneWidget);
    expect(
      tester
          .widget<FilterChip>(find.byKey(const ValueKey('quick-add-week-1')))
          .selected,
      isTrue,
    );
    await tester.tap(find.byKey(const ValueKey('quick-add-week-2')));
    await tester.tap(
      find.byKey(const ValueKey('quick-add-weeks-confirm-button')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('quick-add-name-field')),
      '手动新增课程',
    );
    await tester.tap(find.byKey(const ValueKey('quick-add-section-第2节')));
    await tester.tap(find.byKey(const ValueKey('quick-add-save-button')));
    await tester.pumpAndSettle();

    expect(find.text('手动新增课程'), findsOneWidget);
    final applied = await customizationStore.applyToSemester(semester);
    final course = applied.courses.firstWhere(
      (course) => course.name == '手动新增课程',
    );
    expect(course.isManual, isTrue);
    expect(course.sessions.map((session) => session.week), [1, 2]);
    expect(course.sessions.first.sections, ['第1节', '第2节']);

    await tester.tap(find.text('第1周').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('第2周').last);
    await tester.pumpAndSettle();
    expect(find.text('手动新增课程'), findsOneWidget);
  });

  testWidgets('selects one week session and removes selected sessions', (
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
    expect(find.byKey(const ValueKey('session-week-rule-field')), findsNothing);
    expect(find.byKey(const ValueKey('session-week-dropdown')), findsOneWidget);
    expect(find.byKey(const ValueKey('session-section-第1节')), findsOneWidget);
    expect(find.text('上课大节'), findsNothing);
    expect(find.text('地点'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('session-week-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('第2周').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '保存'));
    await tester.pumpAndSettle();
    expect(find.textContaining('第2周'), findsWidgets);

    final firstSessionCheckbox = find.byType(Checkbox).first;
    await tester.ensureVisible(firstSessionCheckbox);
    await tester.pumpAndSettle();
    await tester.tap(firstSessionCheckbox);
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(firstSessionCheckbox).value, isTrue);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 1200));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('delete-selected-sessions-button')),
      findsOneWidget,
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
      isNotNull,
    );
  });

  testWidgets('confirms a valid imported schedule without previewing first', (
    tester,
  ) async {
    final store = await _emptyStore();
    await _pumpSchedule(tester, semester, store: store);
    await _openScheduleEditor(tester);
    await _enterValidImportForm(tester, '直接添加课表');

    await tester.tap(find.byKey(const ValueKey('confirm-import-button')));
    await tester.pumpAndSettle();

    expect((await store.loadRecords()).single.displayName, '直接添加课表');
  });

  testWidgets('auto previews academic recognition without showing html', (
    tester,
  ) async {
    final store = await _emptyStore();
    await tester.pumpWidget(
      MaterialApp(
        home: ImportSchedulePage(
          existingDisplayNames: const [],
          store: store,
          initialDisplayName: '识别课表',
          initialCourseHtml: File(
            'assets/raw/2025-2026-2-courses.html',
          ).readAsStringSync(),
          hideCourseHtml: true,
          autoPreview: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('import-html-field')), findsNothing);
    expect(find.text('预览结果'), findsOneWidget);
    expect(find.text('中国近现代史纲要'), findsOneWidget);
    expect(find.byKey(const ValueKey('import-date-field')), findsOneWidget);
  });

  testWidgets('recognizes and validates the configurable semester week count', (
    tester,
  ) async {
    await _pumpSchedule(tester, semester);
    await _openScheduleEditor(tester);
    await _enterValidImportForm(tester, '可扩展课表');

    await tester.tap(find.byKey(const ValueKey('preview-import-button')));
    await tester.pumpAndSettle();
    final weekCountField = find.byKey(
      const ValueKey('import-week-count-field'),
    );
    expect(tester.widget<TextField>(weekCountField).controller!.text, '17');

    await tester.enterText(weekCountField, '16');
    await tester.tap(find.byKey(const ValueKey('preview-import-button')));
    await tester.pumpAndSettle();
    expect(find.text('学期总周数不得小于第17周'), findsOneWidget);

    await tester.enterText(weekCountField, '20');
    await tester.tap(find.byKey(const ValueKey('preview-import-button')));
    await tester.pumpAndSettle();
    expect(find.text('第 20 周'), findsOneWidget);
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
      semester: _loadSampleSemester(displayName: '待修改课表'),
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

  testWidgets('allows reducing extended weeks down to the final course week', (
    tester,
  ) async {
    final store = await _emptyStore();
    final record = await store.addRecord(
      semester: _loadSampleSemester(
        displayName: '扩展课表',
      ).copyWith(weekCount: 20),
      existingDisplayNames: const ['2025-2026-2学期'],
    );
    await _pumpSchedule(tester, semester, store: store);
    await _openManagementPage(tester);
    await tester.tap(find.byKey(ValueKey('edit-schedule-${record.id}')));
    await tester.pumpAndSettle();

    final weekCountField = find.byKey(
      const ValueKey('import-week-count-field'),
    );
    expect(tester.widget<TextField>(weekCountField).controller!.text, '20');
    await tester.enterText(weekCountField, '17');
    await tester.tap(find.byKey(const ValueKey('preview-import-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-import-button')));
    await tester.pumpAndSettle();

    expect((await store.loadRecords()).single.semester.weekCount, 17);
  });

  testWidgets('deletes an imported schedule in the management page', (
    tester,
  ) async {
    final store = await _emptyStore();
    final record = await store.addRecord(
      semester: _loadSampleSemester(displayName: '待删除课表'),
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

Semester _loadSampleSemester({
  String semesterId = '2025-2026-2',
  String displayName = '2025-2026-2学期',
  DateTime? termStartDate,
}) {
  return SemesterImporter.parseCourseHtml(
    semesterId: semesterId,
    displayName: displayName,
    termStartDate: termStartDate ?? DateTime(2026, 2, 23),
    courseHtml: File('assets/raw/2025-2026-2-courses.html').readAsStringSync(),
  );
}

Future<void> _pumpSchedule(
  WidgetTester tester,
  Semester semester, {
  ImportedSemesterStore? store,
  CourseCustomizationStore? customizationStore,
  ThemePreferenceStore? themePreferenceStore,
  Size size = const Size(1280, 900),
  DateTime? currentDate,
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
      key: ValueKey((currentDate ?? DateTime(2026, 2, 23)).toIso8601String()),
      semestersFuture: Future.value([semester]),
      importedSemesterStore: importedStore,
      courseCustomizationStore: customizationStore,
      themePreferenceStore: themePreferenceStore,
      currentDate: currentDate ?? DateTime(2026, 2, 23),
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

Color? _headerBackgroundColor(WidgetTester tester, int weekday) {
  final header = find.byKey(ValueKey('timetable-header-$weekday'));
  final decoration = tester.widget<DecoratedBox>(
    find.descendant(of: header, matching: find.byType(DecoratedBox)).first,
  );
  return (decoration.decoration as BoxDecoration).color;
}

Color? _tableBackgroundColor(WidgetTester tester) {
  final table = find.byKey(const ValueKey('timetable-canvas'));
  final decoration = tester.widget<DecoratedBox>(
    find.descendant(of: table, matching: find.byType(DecoratedBox)).first,
  );
  return (decoration.decoration as BoxDecoration).color;
}
