import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lzu_timetable/app/course_editor_page.dart';
import 'package:lzu_timetable/models/schedule_models.dart';

void main() {
  testWidgets(
    'untouched mixed location hint preserves every original location',
    (tester) async {
      CourseCustomization? saved;
      await _pumpEditor(tester, onSaved: (value) => saved = value);
      final field = find.byKey(const ValueKey('course-location-field'));
      expect(tester.widget<TextField>(field).controller!.text, isEmpty);
      expect(tester.widget<TextField>(field).decoration!.hintText, '-');
      await tester.tap(field);
      await tester.enterText(
        find.byKey(const ValueKey('course-name-field')),
        '只修改名称',
      );
      await tester.tap(find.byKey(const ValueKey('save-course-button')));
      await tester.pumpAndSettle();
      expect(
        saved!.sessions.map((s) => s.location),
        _course.sessions.map((s) => s.location),
      );
    },
  );

  testWidgets(
    'course location changes all sessions and respects later individual edits',
    (tester) async {
      CourseCustomization? saved;
      await _pumpEditor(tester, onSaved: (value) => saved = value);
      final field = find.byKey(const ValueKey('course-location-field'));
      await tester.enterText(field, '  全部安排的新地点  ');
      await tester.pumpAndSettle();
      expect(saved, isNull);
      await _editSession(tester, 1);
      final sessionField = find.byKey(const ValueKey('session-location-field'));
      expect(
        tester.widget<TextField>(sessionField).controller!.text,
        '全部安排的新地点',
      );
      await tester.enterText(sessionField, '单次例外');
      await _saveDialog(tester);
      await _tapVisible(tester, field, scrollStep: -250);
      expect(tester.widget<TextField>(field).controller!.text, isEmpty);
      expect(tester.widget<TextField>(field).decoration!.hintText, '-');
      await tester.tap(find.byKey(const ValueKey('save-course-button')));
      await tester.pumpAndSettle();
      expect(saved!.sessions.map((s) => s.location), [
        '全部安排的新地点',
        '单次例外',
        '全部安排的新地点',
      ]);
      for (var index = 0; index < 3; index++) {
        _expectSameTime(saved!.sessions[index], _course.sessions[index]);
      }
    },
  );

  testWidgets(
    'course location summary follows selected-session edits and deletions',
    (tester) async {
      await _pumpEditor(tester, onSaved: (_) {});
      for (var index = 0; index < 3; index++) {
        await _selectSession(tester, index);
      }
      await _openBulk(tester);
      await tester.enterText(
        find.byKey(const ValueKey('bulk-location-field')),
        '共同地点',
      );
      await _saveDialog(tester);
      final field = find.byKey(const ValueKey('course-location-field'));
      await _tapVisible(tester, field, scrollStep: -250);
      expect(tester.widget<TextField>(field).controller!.text, '共同地点');
      await _editSession(tester, 0);
      await tester.enterText(
        find.byKey(const ValueKey('session-location-field')),
        '例外地点',
      );
      await _saveDialog(tester);
      await _selectSession(tester, 0);
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('delete-selected-sessions-button')),
      );
      await tester.tap(find.widgetWithText(FilledButton, '删除'));
      await tester.pumpAndSettle();
      await _tapVisible(tester, field, scrollStep: -250);
      expect(tester.widget<TextField>(field).controller!.text, '共同地点');
      expect(tester.widget<TextField>(field).decoration!.hintText, isNull);
    },
  );

  testWidgets('can clear all locations including an untouched mixed summary', (
    tester,
  ) async {
    CourseCustomization? saved;
    await _pumpEditor(tester, onSaved: (value) => saved = value);
    await tester.tap(find.byTooltip('清空所有地点'));
    await tester.pumpAndSettle();
    final field = find.byKey(const ValueKey('course-location-field'));
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
    expect(tester.widget<TextField>(field).decoration!.hintText, isNull);
    await tester.enterText(field, '暂时的统一地点');
    await tester.enterText(field, '   ');
    await tester.tap(find.byKey(const ValueKey('save-course-button')));
    await tester.pumpAndSettle();
    expect(saved!.sessions.map((s) => s.location), ['', '', '']);
  });

  testWidgets(
    'untimed course enables its location field after adding a session',
    (tester) async {
      await _pumpEditor(
        tester,
        course: _course.copyWith(sessions: []),
        onSaved: (_) {},
      );
      final field = find.byKey(const ValueKey('course-location-field'));
      expect(tester.widget<TextField>(field).enabled, isFalse);
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('add-session-button')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('session-location-field')),
        '新增地点',
      );
      await _saveDialog(tester);
      await _tapVisible(tester, field, scrollStep: -250);
      expect(tester.widget<TextField>(field).enabled, isTrue);
      expect(tester.widget<TextField>(field).controller!.text, '新增地点');
    },
  );

  testWidgets('edits one location, cancels changes, and adds a location', (
    tester,
  ) async {
    CourseCustomization? saved;
    await _pumpEditor(tester, onSaved: (value) => saved = value);
    await _editSession(tester, 0);
    final field = find.byKey(const ValueKey('session-location-field'));
    expect(tester.widget<TextField>(field).controller!.text, '教学楼 A101');
    await tester.enterText(field, '  教学楼 D404  ');
    await _saveDialog(tester);
    expect(saved, isNull);
    expect(find.textContaining('教学楼 D404'), findsOneWidget);

    await _editSession(tester, 0);
    await tester.enterText(field, '不保存的地点');
    await tester.tap(find.widgetWithText(TextButton, '取消'));
    await tester.pumpAndSettle();
    expect(find.textContaining('教学楼 D404'), findsOneWidget);
    expect(find.textContaining('不保存的地点'), findsNothing);

    await _editSession(tester, 1);
    await tester.enterText(field, '   ');
    await _saveDialog(tester);
    await _tapVisible(tester, find.byKey(const ValueKey('add-session-button')));
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
    await tester.enterText(field, '  新教室  ');
    await _saveDialog(tester);
    await tester.tap(find.byKey(const ValueKey('save-course-button')));
    await tester.pumpAndSettle();

    expect(saved!.sessions.map((s) => s.location), [
      '教学楼 D404',
      '',
      '实验楼 C303',
      '新教室',
    ]);
    for (var index = 0; index < 3; index++) {
      _expectSameTime(saved!.sessions[index], _course.sessions[index]);
    }
  });

  testWidgets('batch updates only checked sessions and supports clearing', (
    tester,
  ) async {
    CourseCustomization? saved;
    await _pumpEditor(tester, onSaved: (value) => saved = value);
    await _selectSession(tester, 0);
    await _selectSession(tester, 1);
    await _openBulk(tester);
    final field = find.byKey(const ValueKey('bulk-location-field'));
    expect(find.text('已选 2 条上课安排'), findsOneWidget);
    expect(find.textContaining('存在不同地点'), findsOneWidget);
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);
    expect(find.text('留空将清除所选安排的地点'), findsOneWidget);
    await tester.enterText(field, '  统一教室  ');
    await tester.tap(find.widgetWithText(TextButton, '取消'));
    await tester.pumpAndSettle();
    expect(find.textContaining('统一教室'), findsNothing);
    expect(find.text('已选 2 项'), findsOneWidget);

    await _openBulk(tester);
    await tester.enterText(field, '  统一教室  ');
    await _saveDialog(tester);
    expect(saved, isNull);
    expect(find.textContaining('统一教室'), findsNWidgets(2));
    expect(
      find.byKey(const ValueKey('edit-selected-locations-button')),
      findsNothing,
    );

    await _selectSession(tester, 0);
    await _selectSession(tester, 1);
    await _openBulk(tester);
    expect(tester.widget<TextField>(field).controller!.text, '统一教室');
    expect(find.textContaining('存在不同地点'), findsNothing);
    await tester.enterText(field, '  ');
    await _saveDialog(tester);
    await tester.tap(find.byKey(const ValueKey('save-course-button')));
    await tester.pumpAndSettle();
    expect(saved!.sessions.map((s) => s.location), ['', '', '实验楼 C303']);
    for (var index = 0; index < 3; index++) {
      _expectSameTime(saved!.sessions[index], _course.sessions[index]);
    }
  });

  testWidgets(
    'discards location drafts when leaving without saving the course',
    (tester) async {
      CourseCustomization? saved;
      await _pumpEditor(tester, onSaved: (value) => saved = value);
      await _selectSession(tester, 0);
      await _openBulk(tester);
      await tester.enterText(
        find.byKey(const ValueKey('bulk-location-field')),
        '临时地点',
      );
      await _saveDialog(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(saved, isNull);
      expect(_course.sessions.first.location, '教学楼 A101');
    },
  );

  testWidgets(
    'mobile location dialogs remain usable with keyboard and long text',
    (tester) async {
      await _pumpEditor(tester, size: const Size(390, 844), onSaved: (_) {});
      await tester.enterText(
        find.byKey(const ValueKey('course-location-field')),
        '整门课程统一使用的长名称地点：榆中校区天山堂 A101',
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _selectSession(tester, 0);
      await _selectSession(tester, 1);
      await _openBulk(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.enterText(
        find.byKey(const ValueKey('bulk-location-field')),
        '榆中校区天山堂综合教学楼第三层东侧多媒体教室 301',
      );
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(FilledButton, '保存').hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await _saveDialog(tester);
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();

      await _editSession(tester, 0);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      final field = find.byKey(const ValueKey('session-location-field'));
      await tester.ensureVisible(field);
      await tester.pumpAndSettle();
      await tester.enterText(field, '另一间较长名称的教室 302');
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(FilledButton, '保存').hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await _saveDialog(tester);
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}

const _course = Course(
  id: 1,
  courseCode: '101',
  sequence: '1',
  name: '测试课程',
  teachers: [],
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
      week: 1,
      weekday: 1,
      startSection: 0,
      endSection: 1,
      location: '教学楼 A101',
    ),
    CourseSession(
      week: 2,
      weekday: 3,
      startSection: 2,
      endSection: 3,
      location: '教学楼 B202',
    ),
    CourseSession(
      week: 3,
      weekday: 5,
      startSection: 4,
      endSection: 5,
      location: '实验楼 C303',
    ),
  ],
);

Future<void> _pumpEditor(
  WidgetTester tester, {
  required ValueChanged<CourseCustomization?> onSaved,
  Course course = _course,
  Size size = const Size(1280, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              onSaved(
                await Navigator.of(context).push<CourseCustomization>(
                  MaterialPageRoute(
                    builder: (_) => CourseEditorPage(
                      semester: Semester(
                        id: 1,
                        displayName: '测试课表',
                        termStartDate: DateTime(2026, 2, 23),
                        courses: [course],
                      ),
                      course: course,
                    ),
                  ),
                ),
              );
            },
            child: const Text('打开编辑'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('打开编辑'));
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(
  WidgetTester tester,
  Finder finder, {
  double scrollStep = 250,
}) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      scrollStep,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Finder _row(int index) => find.byKey(ValueKey('session-row-$index'));

Future<void> _editSession(WidgetTester tester, int index) => _tapVisible(
  tester,
  find.descendant(of: _row(index), matching: find.byTooltip('编辑节次')),
);

Future<void> _selectSession(WidgetTester tester, int index) => _tapVisible(
  tester,
  find.descendant(of: _row(index), matching: find.byType(Checkbox)),
);

Future<void> _openBulk(WidgetTester tester) => _tapVisible(
  tester,
  find.byKey(const ValueKey('edit-selected-locations-button')),
);

Future<void> _saveDialog(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, '保存'));
  await tester.pumpAndSettle();
}

void _expectSameTime(CourseSession actual, CourseSession original) {
  expect(
    (actual.week, actual.weekday, actual.startSection, actual.endSection),
    (
      original.week,
      original.weekday,
      original.startSection,
      original.endSection,
    ),
  );
}
