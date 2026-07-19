import 'package:flutter_test/flutter_test.dart';
import 'package:lzu_timetable/services/academic_calendar_date_resolver.dart';

void main() {
  group('AcademicCalendarDateResolver', () {
    test('builds the authenticated academic calendar URI from selected IDs', () {
      final uri = AcademicCalendarDateResolver.buildUri(
        yearId: '46',
        termId: '1',
      );

      expect(
        uri.toString(),
        'https://jwk.lzu.edu.cn/academic/manager/calendar/date.jsp?year=46&term=1',
      );
    });

    test('keeps a Monday first week start unchanged', () {
      final monday = AcademicCalendarDateResolver.firstWeekMonday('''
        2026-03-09 周次=1
        2026-03-10 周次=1
        2026-03-16 周次=2
      ''');

      expect(monday, DateTime(2026, 3, 9));
    });

    test('moves a Sunday first week start to Monday', () {
      final monday = AcademicCalendarDateResolver.firstWeekMonday('''
        2021-02-21 周次=1
        2021-02-22 周次=1
        2021-02-23 周次=1
      ''');

      expect(monday, DateTime(2021, 2, 22));
    });

    test('uses the earliest first-week date in the response', () {
      final monday = AcademicCalendarDateResolver.firstWeekMonday('''
        2026-03-10 周次=1
        2026-03-09 周次=1
      ''');

      expect(monday, DateTime(2026, 3, 9));
    });

    test('rejects missing, invalid, and unsupported first-week dates', () {
      expect(
        () => AcademicCalendarDateResolver.firstWeekMonday('2026-03-09 周次=2'),
        throwsFormatException,
      );
      expect(
        () => AcademicCalendarDateResolver.firstWeekMonday('2026-02-30 周次=1'),
        throwsFormatException,
      );
      expect(
        () => AcademicCalendarDateResolver.firstWeekMonday('2026-03-10 周次=1'),
        throwsFormatException,
      );
    });
  });
}
