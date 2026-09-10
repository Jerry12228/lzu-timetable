import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lzu_timetable/app/week_selector.dart';

void main() {
  for (final width in [390.0, 1280.0]) {
    testWidgets('scrolls weeks without changing selection at width $width', (
      tester,
    ) async {
      await _pumpSelector(tester, width: width);
      expect(find.byType(OutlinedButton), findsNWidgets(29));
      expect(
        tester.getTopLeft(_button(1)).dy,
        tester.getTopLeft(_button(2)).dy,
      );
      expect(_selector(tester).selectedWeek, 1);

      await tester.drag(find.byType(WeekSelector), const Offset(-4000, 0));
      await tester.pumpAndSettle();
      expect(_selector(tester).selectedWeek, 1);
      _expectVisible(tester, 30);

      await tester.tap(_button(30));
      await tester.pumpAndSettle();
      expect(_selector(tester).selectedWeek, 30);
      expect(find.widgetWithText(FilledButton, '第30周'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('supports mouse dragging and both theme modes', (tester) async {
    for (final brightness in Brightness.values) {
      await _pumpSelector(tester, brightness: brightness);
      final start = tester.getCenter(find.byType(WeekSelector));
      final gesture = await tester.startGesture(
        start,
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveBy(const Offset(-25, 0));
      await gesture.moveBy(const Offset(-250, 0));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_offset(tester), greaterThan(0));
      expect(_selector(tester).selectedWeek, 1);
      final context = tester.element(_button(1));
      final button = tester.widget<FilledButton>(_button(1));
      expect(
        button.defaultStyleOf(context).backgroundColor!.resolve({}),
        Theme.of(context).colorScheme.primary,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'reveals selected week on changes but preserves ordinary scrolling',
    (tester) async {
      await _pumpSelector(tester, selectedWeek: 28);
      _expectVisible(tester, 28);

      await tester.drag(find.byType(WeekSelector), const Offset(4000, 0));
      await tester.pumpAndSettle();
      final offset = _offset(tester);
      await _pumpSelector(tester, selectedWeek: 28);
      expect(_offset(tester), offset);

      await _pumpSelector(tester, selectedWeek: 28, width: 1280);
      _expectVisible(tester, 28);
      await _pumpSelector(tester, selectedWeek: 28, maxWeek: 35, width: 1280);
      _expectVisible(tester, 28);
      await _pumpSelector(tester, selectedWeek: 8, maxWeek: 8);
      _expectVisible(tester, 8);
      expect(find.text('第9周'), findsNothing);

      await _pumpSelector(tester, selectedWeek: 1, maxWeek: 1);
      _expectVisible(tester, 1);
      expect(_offset(tester), 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('revealing a week does not scroll the enclosing preview page', (
    tester,
  ) async {
    final pageController = ScrollController();
    addTearDown(pageController.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            controller: pageController,
            children: [
              const SizedBox(height: 300),
              WeekSelector(maxWeek: 30, selectedWeek: 28, onChanged: (_) {}),
              const SizedBox(height: 1000),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(pageController.offset, 0);
    _expectVisible(tester, 28);
  });
}

Future<void> _pumpSelector(
  WidgetTester tester, {
  double width = 390,
  int maxWeek = 30,
  int selectedWeek = 1,
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  var week = selectedWeek;
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: brightness,
        ),
      ),
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) {
            return WeekSelector(
              maxWeek: maxWeek,
              selectedWeek: week,
              onChanged: (value) => setState(() => week = value),
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _button(int week) => find.byKey(ValueKey('week-button-$week'));

WeekSelector _selector(WidgetTester tester) =>
    tester.widget<WeekSelector>(find.byType(WeekSelector));

double _offset(WidgetTester tester) => tester
    .widget<SingleChildScrollView>(
      find.descendant(
        of: find.byType(WeekSelector),
        matching: find.byType(SingleChildScrollView),
      ),
    )
    .controller!
    .offset;

void _expectVisible(WidgetTester tester, int week) {
  final viewport = tester.getRect(find.byType(WeekSelector));
  final button = tester.getRect(_button(week));
  expect(button.left, greaterThanOrEqualTo(viewport.left));
  expect(button.right, lessThanOrEqualTo(viewport.right));
  expect(_button(week).hitTestable(), findsOneWidget);
}
