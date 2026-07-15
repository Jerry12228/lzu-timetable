import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('ScheduleRow')
class Schedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get displayName => text().unique()();
  TextColumn get firstMonday => text()();
  IntColumn get configuredWeekCount => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<String> get customConstraints => ['CHECK (configured_week_count > 0)'];
}

@DataClassName('CourseRow')
class Courses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get scheduleId =>
      integer().references(Schedules, #id, onDelete: KeyAction.cascade)();
  IntColumn get origin => integer()();
  TextColumn get importKey => text().nullable()();
  TextColumn get courseCode => text().nullable()();
  TextColumn get sequence => text().nullable()();
  BoolColumn get sourcePresent => boolean().withDefault(const Constant(true))();
  TextColumn get courseDetailLink => text().nullable()();
  TextColumn get teachingRecordLink => text().nullable()();
  TextColumn get processScoreLink => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {scheduleId, importKey},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (origin IN (0, 1))',
    "CHECK (origin = 1 OR (import_key IS NOT NULL AND course_code <> '' AND sequence <> ''))",
  ];
}

@DataClassName('CourseVersionRow')
class CourseVersions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get courseId =>
      integer().references(Courses, #id, onDelete: KeyAction.cascade)();
  IntColumn get kind => integer()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get name => text()();
  TextColumn get credits => text().withDefault(const Constant(''))();
  TextColumn get selectionType => text().withDefault(const Constant(''))();
  TextColumn get assessment => text().withDefault(const Constant(''))();
  TextColumn get examNature => text().withDefault(const Constant(''))();
  TextColumn get deferredExam => text().withDefault(const Constant(''))();
  TextColumn get material => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {courseId, kind},
  ];

  @override
  List<String> get customConstraints => ['CHECK (kind IN (0, 1))'];
}

@DataClassName('CourseTeacherRow')
class CourseTeachers extends Table {
  IntColumn get versionId =>
      integer().references(CourseVersions, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get name => text()();

  @override
  Set<Column<Object>> get primaryKey => {versionId, position};
}

@DataClassName('CourseMeetingRow')
class CourseMeetings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get versionId =>
      integer().references(CourseVersions, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  IntColumn get weekday => integer()();
  IntColumn get startSection => integer()();
  IntColumn get endSection => integer()();
  TextColumn get location => text().withDefault(const Constant(''))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {versionId, position},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (weekday BETWEEN 1 AND 7)',
    'CHECK (start_section BETWEEN 0 AND 13)',
    'CHECK (end_section BETWEEN start_section AND 13)',
  ];
}

@DataClassName('MeetingWeekRow')
class MeetingWeeks extends Table {
  IntColumn get meetingId =>
      integer().references(CourseMeetings, #id, onDelete: KeyAction.cascade)();
  IntColumn get week => integer()();

  @override
  Set<Column<Object>> get primaryKey => {meetingId, week};

  @override
  List<String> get customConstraints => ['CHECK (week > 0)'];
}

@DriftDatabase(
  tables: [
    Schedules,
    Courses,
    CourseVersions,
    CourseTeachers,
    CourseMeetings,
    MeetingWeeks,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createEffectiveCourseView();
      await customStatement(
        'CREATE INDEX course_schedule_idx ON courses(schedule_id, origin, source_present)',
      );
      await customStatement(
        'CREATE INDEX teacher_name_idx ON course_teachers(name)',
      );
      await customStatement(
        'CREATE INDEX meeting_time_idx ON course_meetings(weekday, start_section, end_section)',
      );
      await customStatement(
        'CREATE INDEX meeting_week_idx ON meeting_weeks(week, meeting_id)',
      );
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _createEffectiveCourseView() {
    return customStatement('''
      CREATE VIEW effective_course_versions AS
      SELECT
        c.id AS course_id,
        c.schedule_id AS schedule_id,
        c.origin AS origin,
        COALESCE(local_version.id, base_version.id) AS effective_version_id
      FROM courses c
      INNER JOIN course_versions base_version
        ON base_version.course_id = c.id AND base_version.kind = 0
      LEFT JOIN course_versions local_version
        ON local_version.course_id = c.id AND local_version.kind = 1
      WHERE (c.origin = 1 OR c.source_present = 1)
        AND COALESCE(local_version.is_deleted, 0) = 0
    ''');
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'lzu_timetable_v2',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
      ),
    );
  }
}
