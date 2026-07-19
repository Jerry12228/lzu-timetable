class AcademicCalendarDateResolver {
  const AcademicCalendarDateResolver._();

  static const host = 'jwk.lzu.edu.cn';
  static const path = '/academic/manager/calendar/date.jsp';

  static Uri buildUri({required String yearId, required String termId}) {
    final normalizedYearId = yearId.trim();
    final normalizedTermId = termId.trim();
    if (normalizedYearId.isEmpty || normalizedTermId.isEmpty) {
      throw const FormatException('无法识别当前页面的学年或学期 ID');
    }
    return Uri(
      scheme: 'https',
      host: host,
      path: path,
      queryParameters: {'year': normalizedYearId, 'term': normalizedTermId},
    );
  }

  static DateTime firstWeekMonday(String calendarContent) {
    final matches = RegExp(
      r'(\d{4})-(\d{2})-(\d{2})\s*周次\s*[=:]\s*1(?:\D|$)',
    ).allMatches(calendarContent);
    if (matches.isEmpty) {
      throw const FormatException('无法从校历中识别开学日期');
    }

    final dates = <DateTime>[for (final match in matches) _parseDate(match)]
      ..sort();
    final firstDay = dates.first;
    return switch (firstDay.weekday) {
      DateTime.monday => firstDay,
      DateTime.sunday => firstDay.add(const Duration(days: 1)),
      _ => throw const FormatException('校历开学日期不是星期一或星期日'),
    };
  }

  static DateTime _parseDate(RegExpMatch match) {
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      throw const FormatException('校历包含无效日期');
    }
    return date;
  }
}
