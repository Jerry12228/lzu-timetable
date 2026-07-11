import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/schedule_models.dart';
import 'semester_importer.dart';
import 'semester_json_codec.dart';

class CourseCustomizationStore {
  CourseCustomizationStore({SharedPreferences? preferences})
    : _preferencesFuture = preferences == null
          ? SharedPreferences.getInstance()
          : Future.value(preferences);

  static const _storageKey = 'course_schedule_course_customizations_v1';
  static const _manualCoursesStorageKey = 'course_schedule_manual_courses_v1';

  final Future<SharedPreferences> _preferencesFuture;

  Future<Semester> applyToSemester(Semester semester) async {
    final customizations = await loadForSemester(semester.id);
    final manualCourses = await loadManualCourses(semester.id);
    final courses = <Course>[];
    for (final course in [...semester.courses, ...manualCourses]) {
      final customization = customizations[CourseKey.fromCourse(course)];
      if (customization == null) {
        courses.add(course);
      } else if (!customization.isDeleted) {
        courses.add(customization.applyTo(course));
      }
    }
    return semester.copyWith(courses: courses);
  }

  Future<List<Course>> loadManualCourses(String semesterId) async {
    final all = await _readAllManualCourses();
    return all[semesterId] ?? const [];
  }

  Future<void> saveManualCourse({
    required String semesterId,
    required Course course,
  }) async {
    final all = await _readAllManualCourses();
    final courses = [...(all[semesterId] ?? const <Course>[])];
    final key = CourseKey.fromCourse(course);
    final existingIndex = courses.indexWhere(
      (item) => CourseKey.fromCourse(item) == key,
    );
    if (existingIndex == -1) {
      courses.add(course);
    } else {
      courses[existingIndex] = course;
    }
    all[semesterId] = courses;
    await _writeAllManualCourses(all);
  }

  Future<Map<CourseKey, CourseCustomization>> loadForSemester(
    String semesterId,
  ) async {
    final all = await _readAll();
    final rawSemester = all[semesterId];
    if (rawSemester is! Map) {
      return const {};
    }
    final customizations = <CourseKey, CourseCustomization>{};
    final needsRewrite = _containsLegacyWeekRules(rawSemester);
    for (final value in rawSemester.values) {
      if (value is! Map) {
        continue;
      }
      try {
        final customization = _customizationFromJson(
          Map<String, Object?>.from(value),
        );
        customizations[customization.courseKey] = customization;
      } on FormatException {
        // Ignore one malformed local override instead of blocking the timetable.
      }
    }
    if (needsRewrite) {
      all[semesterId] = {
        for (final customization in customizations.values)
          customization.courseKey.value: _customizationToJson(customization),
      };
      await _writeAll(all);
    }
    return customizations;
  }

  Future<void> saveCustomization({
    required String semesterId,
    required CourseCustomization customization,
  }) async {
    final all = await _readAll();
    final rawSemester = all[semesterId];
    final semesterOverrides = rawSemester is Map
        ? Map<String, Object?>.from(rawSemester)
        : <String, Object?>{};
    semesterOverrides[customization.courseKey.value] = _customizationToJson(
      customization,
    );
    all[semesterId] = semesterOverrides;
    await _writeAll(all);
  }

  Future<Map<String, Object?>> _readAll() async {
    final preferences = await _preferencesFuture;
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <String, Object?>{};
    }
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return <String, Object?>{};
    }
    if (decoded is! Map) {
      return <String, Object?>{};
    }
    return Map<String, Object?>.from(decoded);
  }

  Future<void> _writeAll(Map<String, Object?> value) async {
    final preferences = await _preferencesFuture;
    await preferences.setString(_storageKey, jsonEncode(value));
  }

  Future<Map<String, List<Course>>> _readAllManualCourses() async {
    final preferences = await _preferencesFuture;
    final raw = preferences.getString(_manualCoursesStorageKey);
    if (raw == null || raw.isEmpty) {
      return <String, List<Course>>{};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return <String, List<Course>>{};
      }
      final coursesBySemester = <String, List<Course>>{};
      for (final entry in decoded.entries) {
        if (entry.key is! String || entry.value is! List) {
          continue;
        }
        coursesBySemester[entry.key as String] = [
          for (final value in entry.value as List)
            if (value is Map)
              SemesterJsonCodec.courseFromJson(
                Map<String, Object?>.from(value),
              ),
        ];
      }
      return coursesBySemester;
    } on FormatException {
      return <String, List<Course>>{};
    }
  }

  Future<void> _writeAllManualCourses(
    Map<String, List<Course>> coursesBySemester,
  ) async {
    final preferences = await _preferencesFuture;
    await preferences.setString(
      _manualCoursesStorageKey,
      jsonEncode({
        for (final entry in coursesBySemester.entries)
          entry.key: [
            for (final course in entry.value)
              SemesterJsonCodec.courseToJson(course),
          ],
      }),
    );
  }
}

Map<String, Object?> _customizationToJson(CourseCustomization customization) {
  return {
    'courseCode': customization.courseKey.courseCode,
    'sequence': customization.courseKey.sequence,
    'deleted': customization.isDeleted,
    'metadata': {
      'name': customization.metadata.name,
      'teachers': customization.metadata.teachers,
      'credits': customization.metadata.credits,
      'selectionType': customization.metadata.selectionType,
      'assessment': customization.metadata.assessment,
      'examNature': customization.metadata.examNature,
      'deferredExam': customization.metadata.deferredExam,
      'material': customization.metadata.material,
    },
    'sessions': [
      for (final session in customization.sessions)
        {
          'week': session.week,
          'weekday': session.weekday,
          'weekdayText': session.weekdayText,
          'periodName': session.periodName,
          'startTime': session.startTime,
          'endTime': session.endTime,
          'sections': session.sections,
          'location': session.location,
        },
    ],
  };
}

CourseCustomization _customizationFromJson(Map<String, Object?> json) {
  final metadata = json['metadata'];
  final sessions = json['sessions'];
  if (metadata is! Map || sessions is! List) {
    throw const FormatException('Invalid course customization');
  }
  final metadataMap = Map<String, Object?>.from(metadata);
  return CourseCustomization(
    courseKey: CourseKey(
      courseCode: _string(json, 'courseCode'),
      sequence: _string(json, 'sequence'),
    ),
    isDeleted: json['deleted'] == true,
    metadata: CourseMetadata(
      name: _string(metadataMap, 'name'),
      teachers: _stringList(metadataMap['teachers']),
      credits: _string(metadataMap, 'credits'),
      selectionType: _string(metadataMap, 'selectionType'),
      assessment: _string(metadataMap, 'assessment'),
      examNature: _string(metadataMap, 'examNature'),
      deferredExam: _string(metadataMap, 'deferredExam'),
      material: _string(metadataMap, 'material'),
    ),
    sessions: [
      for (final item in sessions)
        ..._sessionsFromJson(
          item is Map
              ? Map<String, Object?>.from(item)
              : throw const FormatException('Invalid course session'),
        ),
    ],
  );
}

List<CourseSession> _sessionsFromJson(Map<String, Object?> json) {
  final weekday = json['weekday'];
  if (weekday is! int) {
    throw const FormatException('Invalid course session weekday');
  }
  final weeks = switch (json['week']) {
    final int week when week > 0 => [week],
    _ => SemesterImporter.parseWeeks(_string(json, 'weekRule')),
  };
  return [
    for (final week in weeks)
      CourseSession(
        week: week,
        weekday: weekday,
        weekdayText: _string(json, 'weekdayText'),
        periodName: _string(json, 'periodName'),
        startTime: _string(json, 'startTime'),
        endTime: _string(json, 'endTime'),
        sections: _stringList(json['sections']),
        location: _string(json, 'location'),
      ),
  ];
}

bool _containsLegacyWeekRules(Object? value) {
  return switch (value) {
    Map() => value.entries.any(
      (entry) =>
          entry.key == 'weekRule' || _containsLegacyWeekRules(entry.value),
    ),
    List() => value.any(_containsLegacyWeekRules),
    _ => false,
  };
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw FormatException('Missing course customization field: $key');
  }
  return value;
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    throw const FormatException('Invalid course customization list');
  }
  return [
    for (final item in value)
      if (item is String) item,
  ];
}
