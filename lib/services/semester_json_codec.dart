import '../models/schedule_models.dart';
import 'semester_importer.dart';

class SemesterJsonCodec {
  const SemesterJsonCodec._();

  static Map<String, Object?> toJson(Semester semester) {
    return {
      'id': semester.id,
      'displayName': semester.displayName,
      'termStartDate': _dateToJson(semester.termStartDate),
      'courses': [for (final course in semester.courses) courseToJson(course)],
      'periods': [for (final period in semester.periods) _periodToJson(period)],
    };
  }

  static Semester fromJson(Map<String, Object?> json) {
    return Semester(
      id: _string(json, 'id'),
      displayName: _string(json, 'displayName'),
      termStartDate: _dateFromJson(json['termStartDate']),
      courses: [
        for (final course in _objectList(json['courses'], 'courses'))
          courseFromJson(course),
      ],
      periods: [
        for (final period in _objectList(json['periods'], 'periods'))
          _periodFromJson(period),
      ],
    );
  }

  static Map<String, Object?> courseToJson(Course course) =>
      _courseToJson(course);

  static Course courseFromJson(Map<String, Object?> json) =>
      _courseFromJson(json);
}

Map<String, Object?> _courseToJson(Course course) {
  return {
    'courseCode': course.courseCode,
    'sequence': course.sequence,
    'name': course.name,
    'teachers': course.teachers,
    'credits': course.credits,
    'selectionType': course.selectionType,
    'assessment': course.assessment,
    'examNature': course.examNature,
    'deferredExam': course.deferredExam,
    'material': course.material,
    'courseDetailLink': course.courseDetailLink,
    'teachingRecordLink': course.teachingRecordLink,
    'processScoreLink': course.processScoreLink,
    'sessions': [
      for (final session in course.sessions) _sessionToJson(session),
    ],
  };
}

Course _courseFromJson(Map<String, Object?> json) {
  return Course(
    courseCode: _string(json, 'courseCode'),
    sequence: _string(json, 'sequence'),
    name: _string(json, 'name'),
    teachers: _stringList(json['teachers'], 'teachers'),
    credits: _string(json, 'credits'),
    selectionType: _string(json, 'selectionType'),
    assessment: _string(json, 'assessment'),
    examNature: _string(json, 'examNature'),
    deferredExam: _string(json, 'deferredExam'),
    material: _string(json, 'material'),
    courseDetailLink: _nullableString(json['courseDetailLink']),
    teachingRecordLink: _nullableString(json['teachingRecordLink']),
    processScoreLink: _nullableString(json['processScoreLink']),
    sessions: [
      for (final session in _objectList(json['sessions'], 'sessions'))
        ..._sessionsFromJson(session),
    ],
  );
}

Map<String, Object?> _sessionToJson(CourseSession session) {
  return {
    'week': session.week,
    'weekday': session.weekday,
    'weekdayText': session.weekdayText,
    'periodName': session.periodName,
    'startTime': session.startTime,
    'endTime': session.endTime,
    'sections': session.sections,
    'location': session.location,
  };
}

List<CourseSession> _sessionsFromJson(Map<String, Object?> json) {
  final weeks = switch (json['week']) {
    final int week when week > 0 => [week],
    _ => SemesterImporter.parseWeeks(_string(json, 'weekRule')),
  };
  return [
    for (final week in weeks)
      CourseSession(
        week: week,
        weekday: _integer(json, 'weekday'),
        weekdayText: _string(json, 'weekdayText'),
        periodName: _string(json, 'periodName'),
        startTime: _string(json, 'startTime'),
        endTime: _string(json, 'endTime'),
        sections: _stringList(json['sections'], 'sections'),
        location: _string(json, 'location'),
      ),
  ];
}

Map<String, Object?> _periodToJson(PeriodDefinition period) {
  return {
    'order': period.order,
    'name': period.name,
    'sections': period.sections,
    'startTime': period.startTime,
    'endTime': period.endTime,
  };
}

PeriodDefinition _periodFromJson(Map<String, Object?> json) {
  return PeriodDefinition(
    order: _integer(json, 'order'),
    name: _string(json, 'name'),
    sections: _stringList(json['sections'], 'sections'),
    startTime: _string(json, 'startTime'),
    endTime: _string(json, 'endTime'),
  );
}

String? _dateToJson(DateTime? date) {
  if (date == null) {
    return null;
  }
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

DateTime? _dateFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw const FormatException('Invalid term start date');
  }
  return DateTime.tryParse(value) ??
      (throw const FormatException('Invalid term start date'));
}

List<Map<String, Object?>> _objectList(Object? value, String field) {
  if (value is! List) {
    throw FormatException('Invalid course schedule $field');
  }
  return [for (final item in value) _object(item, field)];
}

Map<String, Object?> _object(Object? value, String field) {
  if (value is! Map) {
    throw FormatException('Invalid course schedule $field');
  }
  try {
    return Map<String, Object?>.from(value);
  } on TypeError {
    throw FormatException('Invalid course schedule $field');
  }
}

String _string(Map<String, Object?> json, String field) {
  final value = json[field];
  if (value is! String) {
    throw FormatException('Missing course schedule $field');
  }
  return value;
}

String? _nullableString(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw const FormatException('Invalid course schedule link');
  }
  return value;
}

int _integer(Map<String, Object?> json, String field) {
  final value = json[field];
  if (value is! int) {
    throw FormatException('Missing course schedule $field');
  }
  return value;
}

List<String> _stringList(Object? value, String field) {
  if (value is! List || value.any((item) => item is! String)) {
    throw FormatException('Invalid course schedule $field');
  }
  return List<String>.from(value);
}
