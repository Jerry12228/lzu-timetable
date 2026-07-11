const weekdays = <String>['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];

const timetableSectionOrder = <String>[
  '第1节',
  '第2节',
  '第3节',
  '第4节',
  '中午1节',
  '中午2节',
  '第5节',
  '第6节',
  '第7节',
  '第8节',
  '第9节',
  '第10节',
  '第11节',
  '第12节',
];

const manualCourseCodePrefix = 'local-manual-';

class TimetableCellSelection {
  const TimetableCellSelection({
    required this.week,
    required this.weekday,
    required this.section,
    this.date,
  });

  final int week;
  final int weekday;
  final String section;
  final DateTime? date;
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
    required this.week,
    required this.weekday,
    required this.weekdayText,
    required this.periodName,
    required this.startTime,
    required this.endTime,
    required this.sections,
    required this.location,
  });

  final int week;
  final int weekday;
  final String weekdayText;
  final String periodName;
  final String startTime;
  final String endTime;
  final List<String> sections;
  final String location;

  bool occursInWeek(int value) => week == value;

  int get startMinutes => startTime.isEmpty ? 0 : parseClockMinutes(startTime);

  CourseSession copyWith({
    int? week,
    int? weekday,
    String? weekdayText,
    String? periodName,
    String? startTime,
    String? endTime,
    List<String>? sections,
    String? location,
  }) {
    return CourseSession(
      week: week ?? this.week,
      weekday: weekday ?? this.weekday,
      weekdayText: weekdayText ?? this.weekdayText,
      periodName: periodName ?? this.periodName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sections: sections ?? this.sections,
      location: location ?? this.location,
    );
  }
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
  bool get isManual => courseCode.startsWith(manualCourseCodePrefix);

  Course copyWith({
    String? name,
    List<String>? teachers,
    String? credits,
    String? selectionType,
    String? assessment,
    String? examNature,
    String? deferredExam,
    String? material,
    List<CourseSession>? sessions,
  }) {
    return Course(
      courseCode: courseCode,
      sequence: sequence,
      name: name ?? this.name,
      teachers: teachers ?? this.teachers,
      credits: credits ?? this.credits,
      selectionType: selectionType ?? this.selectionType,
      assessment: assessment ?? this.assessment,
      examNature: examNature ?? this.examNature,
      deferredExam: deferredExam ?? this.deferredExam,
      material: material ?? this.material,
      courseDetailLink: courseDetailLink,
      teachingRecordLink: teachingRecordLink,
      processScoreLink: processScoreLink,
      sessions: sessions ?? this.sessions,
    );
  }
}

class CourseKey {
  const CourseKey({required this.courseCode, required this.sequence});

  factory CourseKey.fromCourse(Course course) =>
      CourseKey(courseCode: course.courseCode, sequence: course.sequence);

  final String courseCode;
  final String sequence;

  String get value => '$courseCode::$sequence';

  @override
  bool operator ==(Object other) =>
      other is CourseKey &&
      other.courseCode == courseCode &&
      other.sequence == sequence;

  @override
  int get hashCode => Object.hash(courseCode, sequence);
}

class CourseMetadata {
  const CourseMetadata({
    required this.name,
    required this.teachers,
    required this.credits,
    required this.selectionType,
    required this.assessment,
    required this.examNature,
    required this.deferredExam,
    required this.material,
  });

  factory CourseMetadata.fromCourse(Course course) {
    return CourseMetadata(
      name: course.name,
      teachers: course.teachers,
      credits: course.credits,
      selectionType: course.selectionType,
      assessment: course.assessment,
      examNature: course.examNature,
      deferredExam: course.deferredExam,
      material: course.material,
    );
  }

  final String name;
  final List<String> teachers;
  final String credits;
  final String selectionType;
  final String assessment;
  final String examNature;
  final String deferredExam;
  final String material;

  CourseMetadata copyWith({
    String? name,
    List<String>? teachers,
    String? credits,
    String? selectionType,
    String? assessment,
    String? examNature,
    String? deferredExam,
    String? material,
  }) {
    return CourseMetadata(
      name: name ?? this.name,
      teachers: teachers ?? this.teachers,
      credits: credits ?? this.credits,
      selectionType: selectionType ?? this.selectionType,
      assessment: assessment ?? this.assessment,
      examNature: examNature ?? this.examNature,
      deferredExam: deferredExam ?? this.deferredExam,
      material: material ?? this.material,
    );
  }

  Course applyTo(Course source, List<CourseSession> sessions) {
    return source.copyWith(
      name: name,
      teachers: teachers,
      credits: credits,
      selectionType: selectionType,
      assessment: assessment,
      examNature: examNature,
      deferredExam: deferredExam,
      material: material,
      sessions: sessions,
    );
  }
}

class CourseCustomization {
  const CourseCustomization({
    required this.courseKey,
    required this.metadata,
    required this.sessions,
    this.isDeleted = false,
  });

  factory CourseCustomization.fromCourse(Course course) {
    return CourseCustomization(
      courseKey: CourseKey.fromCourse(course),
      metadata: CourseMetadata.fromCourse(course),
      sessions: course.sessions,
    );
  }

  factory CourseCustomization.deleted(Course course) {
    return CourseCustomization(
      courseKey: CourseKey.fromCourse(course),
      metadata: CourseMetadata.fromCourse(course),
      sessions: course.sessions,
      isDeleted: true,
    );
  }

  final CourseKey courseKey;
  final CourseMetadata metadata;
  final List<CourseSession> sessions;
  final bool isDeleted;

  Course applyTo(Course source) => metadata.applyTo(source, sessions);
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
        if (session.week > maxWeek) {
          maxWeek = session.week;
        }
      }
    }
    return maxWeek;
  }

  List<Course> get coursesWithoutFixedSchedule =>
      courses.where((course) => !course.hasFixedSchedule).toList();

  Semester copyWith({
    String? id,
    String? displayName,
    DateTime? termStartDate,
    List<Course>? courses,
    List<PeriodDefinition>? periods,
  }) {
    return Semester(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      termStartDate: termStartDate ?? this.termStartDate,
      courses: courses ?? this.courses,
      periods: periods ?? this.periods,
    );
  }

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
