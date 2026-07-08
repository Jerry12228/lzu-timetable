enum WeekParity { all, odd, even }

const weekdays = <String>['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];

class WeekRule {
  const WeekRule.range({
    required this.rawText,
    required this.startWeek,
    required this.endWeek,
    this.parity = WeekParity.all,
  }) : explicitWeeks = null;

  WeekRule.explicit({required this.rawText, required Iterable<int> weeks})
    : explicitWeeks = Set<int>.unmodifiable(weeks),
      startWeek = weeks.reduce((a, b) => a < b ? a : b),
      endWeek = weeks.reduce((a, b) => a > b ? a : b),
      parity = WeekParity.all;

  final String rawText;
  final int startWeek;
  final int endWeek;
  final WeekParity parity;
  final Set<int>? explicitWeeks;

  bool get isExplicit => explicitWeeks != null;

  bool occursIn(int week) {
    final weeks = explicitWeeks;
    if (weeks != null) {
      return weeks.contains(week);
    }
    if (week < startWeek || week > endWeek) {
      return false;
    }
    return switch (parity) {
      WeekParity.all => true,
      WeekParity.odd => week.isOdd,
      WeekParity.even => week.isEven,
    };
  }

  List<int> expand() {
    final weeks = explicitWeeks;
    if (weeks != null) {
      return weeks.toList()..sort();
    }
    return [
      for (var week = startWeek; week <= endWeek; week++)
        if (occursIn(week)) week,
    ];
  }
}

class PeriodDefinition {
  const PeriodDefinition({
    required this.order,
    required this.name,
    required this.sections,
    required this.startTime,
    required this.endTime,
  });

  final int order;
  final String name;
  final List<String> sections;
  final String startTime;
  final String endTime;

  int get startMinutes => parseClockMinutes(startTime);
  int get endMinutes => parseClockMinutes(endTime);
}

class CourseSession {
  const CourseSession({
    required this.weekRule,
    required this.weekday,
    required this.weekdayText,
    required this.periodName,
    required this.startTime,
    required this.endTime,
    required this.sections,
    required this.location,
  });

  final WeekRule weekRule;
  final int weekday;
  final String weekdayText;
  final String periodName;
  final String startTime;
  final String endTime;
  final List<String> sections;
  final String location;

  bool occursInWeek(int week) => weekRule.occursIn(week);

  int get startMinutes => startTime.isEmpty ? 0 : parseClockMinutes(startTime);
}

class Course {
  const Course({
    required this.courseCode,
    required this.sequence,
    required this.name,
    required this.teachers,
    required this.credits,
    required this.selectionType,
    required this.assessment,
    required this.examNature,
    required this.deferredExam,
    required this.material,
    required this.courseDetailLink,
    required this.teachingRecordLink,
    required this.processScoreLink,
    required this.sessions,
  });

  final String courseCode;
  final String sequence;
  final String name;
  final List<String> teachers;
  final String credits;
  final String selectionType;
  final String assessment;
  final String examNature;
  final String deferredExam;
  final String material;
  final String? courseDetailLink;
  final String? teachingRecordLink;
  final String? processScoreLink;
  final List<CourseSession> sessions;

  bool get hasFixedSchedule => sessions.isNotEmpty;
}

class ScheduledCourse {
  const ScheduledCourse({required this.course, required this.session});

  final Course course;
  final CourseSession session;
}

class DateRange {
  const DateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

class Semester {
  const Semester({
    required this.id,
    required this.displayName,
    required this.termStartDate,
    required this.courses,
    required this.periods,
  });

  final String id;
  final String displayName;
  final DateTime? termStartDate;
  final List<Course> courses;
  final List<PeriodDefinition> periods;

  int get maxWeek {
    var maxWeek = 1;
    for (final course in courses) {
      for (final session in course.sessions) {
        if (session.weekRule.endWeek > maxWeek) {
          maxWeek = session.weekRule.endWeek;
        }
      }
    }
    return maxWeek;
  }

  List<Course> get coursesWithoutFixedSchedule =>
      courses.where((course) => !course.hasFixedSchedule).toList();

  List<ScheduledCourse> scheduledCoursesForWeek(int week) {
    final scheduled = <ScheduledCourse>[];
    for (final course in courses) {
      for (final session in course.sessions) {
        if (session.occursInWeek(week)) {
          scheduled.add(ScheduledCourse(course: course, session: session));
        }
      }
    }
    scheduled.sort((a, b) {
      final weekdayCompare = a.session.weekday.compareTo(b.session.weekday);
      if (weekdayCompare != 0) {
        return weekdayCompare;
      }
      final timeCompare = a.session.startMinutes.compareTo(
        b.session.startMinutes,
      );
      if (timeCompare != 0) {
        return timeCompare;
      }
      return a.course.name.compareTo(b.course.name);
    });
    return scheduled;
  }

  DateRange? dateRangeForWeek(int week) {
    final startDate = termStartDate;
    if (startDate == null) {
      return null;
    }
    final start = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    ).add(Duration(days: (week - 1) * 7));
    return DateRange(start: start, end: start.add(const Duration(days: 6)));
  }
}

int parseClockMinutes(String value) {
  final parts = value.split(':');
  if (parts.length != 2) {
    throw FormatException('Invalid clock value: $value');
  }
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);
  return hour * 60 + minute;
}
