import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/schedule_models.dart';

class DuplicateSemesterNameException implements Exception {
  const DuplicateSemesterNameException(this.displayName);

  final String displayName;

  @override
  String toString() => '课表名称已存在，请修改名称';
}

class TimetableRepository {
  TimetableRepository(this.database);

  final AppDatabase database;

  static const _baseVersion = 0;
  static const _overrideVersion = 1;
  static const _importedOrigin = 0;
  static const _manualOrigin = 1;

  Stream<List<Semester>> watchSemesters() {
    final trigger = database
        .customSelect(
          '''
        SELECT DISTINCT s.id
        FROM schedules s
        LEFT JOIN courses c ON c.schedule_id = s.id
        LEFT JOIN course_versions v ON v.course_id = c.id
        LEFT JOIN course_teachers t ON t.version_id = v.id
        LEFT JOIN course_meetings m ON m.version_id = v.id
        LEFT JOIN meeting_weeks w ON w.meeting_id = m.id
        ORDER BY s.created_at
      ''',
          readsFrom: {
            database.schedules,
            database.courses,
            database.courseVersions,
            database.courseTeachers,
            database.courseMeetings,
            database.meetingWeeks,
          },
        )
        .watch();
    return trigger.asyncMap((_) => loadSemesters());
  }

  Stream<Semester?> watchSemester(int semesterId) {
    final trigger = database
        .customSelect(
          '''
        SELECT s.id
        FROM schedules s
        LEFT JOIN courses c ON c.schedule_id = s.id
        LEFT JOIN course_versions v ON v.course_id = c.id
        LEFT JOIN course_teachers t ON t.version_id = v.id
        LEFT JOIN course_meetings m ON m.version_id = v.id
        LEFT JOIN meeting_weeks w ON w.meeting_id = m.id
        WHERE s.id = ?
        LIMIT 1
      ''',
          variables: [Variable<int>(semesterId)],
          readsFrom: {
            database.schedules,
            database.courses,
            database.courseVersions,
            database.courseTeachers,
            database.courseMeetings,
            database.meetingWeeks,
          },
        )
        .watch();
    return trigger.asyncMap((_) => loadSemester(semesterId));
  }

  Stream<List<ScheduledCourse>> watchWeek(int semesterId, int week) =>
      watchSemester(
        semesterId,
      ).map((semester) => semester?.scheduledCoursesForWeek(week) ?? const []);

  Future<List<Semester>> loadSemesters() async {
    final rows = await (database.select(
      database.schedules,
    )..orderBy([(row) => OrderingTerm.asc(row.createdAt)])).get();
    return [for (final row in rows) await _loadSemester(row)];
  }

  Future<Semester?> loadSemester(int semesterId) async {
    final row = await (database.select(
      database.schedules,
    )..where((schedule) => schedule.id.equals(semesterId))).getSingleOrNull();
    return row == null ? null : _loadSemester(row);
  }

  Future<List<Course>> searchCourses({
    required int semesterId,
    String? text,
    String? teacher,
    String? location,
    int? week,
    int? weekday,
  }) async {
    final clauses = <String>['effective.schedule_id = ?'];
    final variables = <Variable<Object>>[Variable<int>(semesterId)];
    final normalizedText = text?.trim();
    if (normalizedText != null && normalizedText.isNotEmpty) {
      clauses.add(
        '(version.name LIKE ? OR teacher.name LIKE ? OR meeting.location LIKE ?)',
      );
      final pattern = '%$normalizedText%';
      variables.addAll([
        Variable<String>(pattern),
        Variable<String>(pattern),
        Variable<String>(pattern),
      ]);
    }
    final normalizedTeacher = teacher?.trim();
    if (normalizedTeacher != null && normalizedTeacher.isNotEmpty) {
      clauses.add('teacher.name = ?');
      variables.add(Variable<String>(normalizedTeacher));
    }
    final normalizedLocation = location?.trim();
    if (normalizedLocation != null && normalizedLocation.isNotEmpty) {
      clauses.add('meeting.location LIKE ?');
      variables.add(Variable<String>('%$normalizedLocation%'));
    }
    if (week != null) {
      clauses.add('meeting_week.week = ?');
      variables.add(Variable<int>(week));
    }
    if (weekday != null) {
      clauses.add('meeting.weekday = ?');
      variables.add(Variable<int>(weekday));
    }
    final rows = await database
        .customSelect(
          '''
        SELECT DISTINCT effective.course_id
        FROM effective_course_versions effective
        INNER JOIN course_versions version
          ON version.id = effective.effective_version_id
        LEFT JOIN course_teachers teacher ON teacher.version_id = version.id
        LEFT JOIN course_meetings meeting ON meeting.version_id = version.id
        LEFT JOIN meeting_weeks meeting_week ON meeting_week.meeting_id = meeting.id
        WHERE ${clauses.join(' AND ')}
      ''',
          variables: variables,
          readsFrom: {
            database.courses,
            database.courseVersions,
            database.courseTeachers,
            database.courseMeetings,
            database.meetingWeeks,
          },
        )
        .get();
    final ids = {for (final row in rows) row.read<int>('course_id')};
    final semester = await loadSemester(semesterId);
    return [
      for (final course in semester?.courses ?? const <Course>[])
        if (ids.contains(course.id)) course,
    ];
  }

  Future<int> saveSchedule({
    int? semesterId,
    required Semester semester,
    required bool replaceImportedCourses,
  }) async {
    final name = semester.displayName.trim();
    final firstMonday = semester.termStartDate;
    if (name.isEmpty) throw const FormatException('请输入课表名称');
    if (firstMonday == null || firstMonday.weekday != DateTime.monday) {
      throw const FormatException('请输入有效的开学日期');
    }
    if (semester.weekCount < semester.lastScheduledWeek) {
      throw FormatException('学期总周数不得小于第${semester.lastScheduledWeek}周');
    }
    await _ensureUniqueName(name, excludingId: semesterId);

    return database.transaction(() async {
      final now = DateTime.now().toUtc();
      final id =
          semesterId ??
          await database
              .into(database.schedules)
              .insert(
                SchedulesCompanion.insert(
                  displayName: name,
                  firstMonday: _formatDate(firstMonday),
                  configuredWeekCount: semester.weekCount,
                  createdAt: now,
                  updatedAt: now,
                ),
              );
      if (semesterId != null) {
        final changed =
            await (database.update(
              database.schedules,
            )..where((row) => row.id.equals(semesterId))).write(
              SchedulesCompanion(
                displayName: Value(name),
                firstMonday: Value(_formatDate(firstMonday)),
                configuredWeekCount: Value(semester.weekCount),
                updatedAt: Value(now),
              ),
            );
        if (changed != 1) throw StateError('课程表不存在：$semesterId');
      }
      if (replaceImportedCourses) {
        await (database.update(database.courses)..where(
              (row) =>
                  row.scheduleId.equals(id) &
                  row.origin.equals(_importedOrigin),
            ))
            .write(const CoursesCompanion(sourcePresent: Value(false)));
        for (final course in semester.courses.where((item) => !item.isManual)) {
          await _upsertImportedCourse(id, course, now);
        }
      }
      return id;
    });
  }

  Future<void> deleteSemester(int semesterId) async {
    await (database.delete(
      database.schedules,
    )..where((row) => row.id.equals(semesterId))).go();
  }

  Future<void> saveCustomization({
    required int semesterId,
    required CourseCustomization customization,
  }) async {
    await database.transaction(() async {
      final courseRow =
          await (database.select(database.courses)..where(
                (row) =>
                    row.id.equals(customization.courseId) &
                    row.scheduleId.equals(semesterId),
              ))
              .getSingleOrNull();
      if (courseRow == null) {
        throw StateError('课程不存在：${customization.courseId}');
      }
      if (courseRow.origin == _manualOrigin && customization.isDeleted) {
        await (database.delete(
          database.courses,
        )..where((row) => row.id.equals(courseRow.id))).go();
        return;
      }
      final kind = courseRow.origin == _manualOrigin
          ? _baseVersion
          : _overrideVersion;
      await _writeVersion(
        courseId: courseRow.id,
        kind: kind,
        metadata: customization.metadata,
        sessions: customization.sessions,
        isDeleted: customization.isDeleted,
        now: DateTime.now().toUtc(),
      );
    });
  }

  Future<int> saveManualCourse({
    required int semesterId,
    required Course course,
  }) async {
    return database.transaction(() async {
      final now = DateTime.now().toUtc();
      var courseId = course.id;
      if (courseId == 0) {
        courseId = await database
            .into(database.courses)
            .insert(
              CoursesCompanion.insert(
                scheduleId: semesterId,
                origin: _manualOrigin,
                importKey: const Value(null),
                courseCode: Value(course.courseCode),
                sequence: Value(course.sequence),
                courseDetailLink: const Value(null),
                teachingRecordLink: const Value(null),
                processScoreLink: const Value(null),
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        final row =
            await (database.select(database.courses)..where(
                  (item) =>
                      item.id.equals(courseId) &
                      item.scheduleId.equals(semesterId) &
                      item.origin.equals(_manualOrigin),
                ))
                .getSingleOrNull();
        if (row == null) throw StateError('手动课程不存在：$courseId');
      }
      await _writeVersion(
        courseId: courseId,
        kind: _baseVersion,
        metadata: CourseMetadata.fromCourse(course),
        sessions: course.sessions,
        isDeleted: false,
        now: now,
      );
      return courseId;
    });
  }

  Future<void> clearImportedOverride(int courseId) async {
    await (database.delete(database.courseVersions)..where(
          (row) =>
              row.courseId.equals(courseId) & row.kind.equals(_overrideVersion),
        ))
        .go();
  }

  Future<Semester> _loadSemester(ScheduleRow scheduleRow) async {
    final courseRows =
        await (database.select(database.courses)
              ..where(
                (row) =>
                    row.scheduleId.equals(scheduleRow.id) &
                    (row.origin.equals(_manualOrigin) |
                        row.sourcePresent.equals(true)),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.id)]))
            .get();
    final courses = <Course>[];
    for (final row in courseRows) {
      final versions = await (database.select(
        database.courseVersions,
      )..where((version) => version.courseId.equals(row.id))).get();
      CourseVersionRow? base;
      CourseVersionRow? local;
      for (final version in versions) {
        if (version.kind == _baseVersion) base = version;
        if (version.kind == _overrideVersion) local = version;
      }
      if (base == null) throw StateError('课程 ${row.id} 缺少基础版本');
      if (local?.isDeleted == true) continue;
      final effective = local ?? base;
      final teachers =
          await (database.select(database.courseTeachers)
                ..where((teacher) => teacher.versionId.equals(effective.id))
                ..orderBy([(teacher) => OrderingTerm.asc(teacher.position)]))
              .get();
      final meetings =
          await (database.select(database.courseMeetings)
                ..where((meeting) => meeting.versionId.equals(effective.id))
                ..orderBy([(meeting) => OrderingTerm.asc(meeting.position)]))
              .get();
      final sessions = <CourseSession>[];
      for (final meeting in meetings) {
        final weeks =
            await (database.select(database.meetingWeeks)
                  ..where((week) => week.meetingId.equals(meeting.id))
                  ..orderBy([(week) => OrderingTerm.asc(week.week)]))
                .get();
        for (final week in weeks) {
          sessions.add(
            CourseSession(
              week: week.week,
              weekday: meeting.weekday,
              startSection: meeting.startSection,
              endSection: meeting.endSection,
              location: meeting.location,
            ),
          );
        }
      }
      sessions.sort(_compareSessions);
      courses.add(
        Course(
          id: row.id,
          origin: row.origin == _manualOrigin
              ? CourseOrigin.manual
              : CourseOrigin.imported,
          courseCode: row.courseCode,
          sequence: row.sequence,
          name: effective.name,
          teachers: [for (final teacher in teachers) teacher.name],
          credits: effective.credits,
          selectionType: effective.selectionType,
          assessment: effective.assessment,
          examNature: effective.examNature,
          deferredExam: effective.deferredExam,
          material: effective.material,
          courseDetailLink: row.courseDetailLink,
          teachingRecordLink: row.teachingRecordLink,
          processScoreLink: row.processScoreLink,
          sessions: sessions,
        ),
      );
    }
    return Semester(
      id: scheduleRow.id,
      displayName: scheduleRow.displayName,
      termStartDate: DateTime.parse(scheduleRow.firstMonday),
      courses: courses,
      weekCount: scheduleRow.configuredWeekCount,
    );
  }

  Future<void> _upsertImportedCourse(
    int semesterId,
    Course course,
    DateTime now,
  ) async {
    final courseCode = course.courseCode?.trim() ?? '';
    final sequence = course.sequence?.trim() ?? '';
    if (courseCode.isEmpty || sequence.isEmpty) {
      throw const FormatException('导入课程缺少课程号或课程序号');
    }
    final importKey = '$courseCode::$sequence';
    final existing =
        await (database.select(database.courses)..where(
              (row) =>
                  row.scheduleId.equals(semesterId) &
                  row.importKey.equals(importKey),
            ))
            .getSingleOrNull();
    final courseId =
        existing?.id ??
        await database
            .into(database.courses)
            .insert(
              CoursesCompanion.insert(
                scheduleId: semesterId,
                origin: _importedOrigin,
                importKey: Value(importKey),
                courseCode: Value(courseCode),
                sequence: Value(sequence),
                sourcePresent: const Value(true),
                courseDetailLink: Value(course.courseDetailLink),
                teachingRecordLink: Value(course.teachingRecordLink),
                processScoreLink: Value(course.processScoreLink),
                createdAt: now,
                updatedAt: now,
              ),
            );
    if (existing != null) {
      await (database.update(
        database.courses,
      )..where((row) => row.id.equals(existing.id))).write(
        CoursesCompanion(
          sourcePresent: const Value(true),
          courseCode: Value(courseCode),
          sequence: Value(sequence),
          courseDetailLink: Value(course.courseDetailLink),
          teachingRecordLink: Value(course.teachingRecordLink),
          processScoreLink: Value(course.processScoreLink),
          updatedAt: Value(now),
        ),
      );
    }
    await _writeVersion(
      courseId: courseId,
      kind: _baseVersion,
      metadata: CourseMetadata.fromCourse(course),
      sessions: course.sessions,
      isDeleted: false,
      now: now,
    );
  }

  Future<void> _writeVersion({
    required int courseId,
    required int kind,
    required CourseMetadata metadata,
    required List<CourseSession> sessions,
    required bool isDeleted,
    required DateTime now,
  }) async {
    final existing =
        await (database.select(database.courseVersions)..where(
              (row) => row.courseId.equals(courseId) & row.kind.equals(kind),
            ))
            .getSingleOrNull();
    final companion = CourseVersionsCompanion(
      courseId: Value(courseId),
      kind: Value(kind),
      isDeleted: Value(isDeleted),
      name: Value(metadata.name),
      credits: Value(metadata.credits),
      selectionType: Value(metadata.selectionType),
      assessment: Value(metadata.assessment),
      examNature: Value(metadata.examNature),
      deferredExam: Value(metadata.deferredExam),
      material: Value(metadata.material),
      updatedAt: Value(now),
    );
    final versionId = existing == null
        ? await database.into(database.courseVersions).insert(companion)
        : existing.id;
    if (existing != null) {
      await (database.update(
        database.courseVersions,
      )..where((row) => row.id.equals(existing.id))).write(companion);
    }
    await (database.delete(
      database.courseTeachers,
    )..where((row) => row.versionId.equals(versionId))).go();
    await (database.delete(
      database.courseMeetings,
    )..where((row) => row.versionId.equals(versionId))).go();
    for (var index = 0; index < metadata.teachers.length; index++) {
      await database
          .into(database.courseTeachers)
          .insert(
            CourseTeachersCompanion.insert(
              versionId: versionId,
              position: index,
              name: metadata.teachers[index],
            ),
          );
    }
    final grouped = <_MeetingKey, Set<int>>{};
    for (final session in sessions) {
      final key = _MeetingKey(
        weekday: session.weekday,
        startSection: session.startSection,
        endSection: session.endSection,
        location: session.location,
      );
      grouped.putIfAbsent(key, () => <int>{}).add(session.week);
    }
    var position = 0;
    for (final entry in grouped.entries) {
      final meetingId = await database
          .into(database.courseMeetings)
          .insert(
            CourseMeetingsCompanion.insert(
              versionId: versionId,
              position: position++,
              weekday: entry.key.weekday,
              startSection: entry.key.startSection,
              endSection: entry.key.endSection,
              location: Value(entry.key.location),
            ),
          );
      final weeks = entry.value.toList()..sort();
      for (final week in weeks) {
        await database
            .into(database.meetingWeeks)
            .insert(
              MeetingWeeksCompanion.insert(meetingId: meetingId, week: week),
            );
      }
    }
  }

  Future<void> _ensureUniqueName(String name, {int? excludingId}) async {
    final query = database.select(database.schedules)
      ..where((row) => row.displayName.equals(name));
    final existing = await query.getSingleOrNull();
    if (existing != null && existing.id != excludingId) {
      throw DuplicateSemesterNameException(name);
    }
  }
}

class _MeetingKey {
  const _MeetingKey({
    required this.weekday,
    required this.startSection,
    required this.endSection,
    required this.location,
  });

  final int weekday;
  final int startSection;
  final int endSection;
  final String location;

  @override
  bool operator ==(Object other) =>
      other is _MeetingKey &&
      other.weekday == weekday &&
      other.startSection == startSection &&
      other.endSection == endSection &&
      other.location == location;

  @override
  int get hashCode => Object.hash(weekday, startSection, endSection, location);
}

int _compareSessions(CourseSession a, CourseSession b) {
  final week = a.week.compareTo(b.week);
  if (week != 0) return week;
  final weekday = a.weekday.compareTo(b.weekday);
  if (weekday != 0) return weekday;
  return a.startSection.compareTo(b.startSection);
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
