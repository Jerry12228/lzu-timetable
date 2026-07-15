// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SchedulesTable extends Schedules
    with TableInfo<$SchedulesTable, ScheduleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _firstMondayMeta = const VerificationMeta(
    'firstMonday',
  );
  @override
  late final GeneratedColumn<String> firstMonday = GeneratedColumn<String>(
    'first_monday',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configuredWeekCountMeta =
      const VerificationMeta('configuredWeekCount');
  @override
  late final GeneratedColumn<int> configuredWeekCount = GeneratedColumn<int>(
    'configured_week_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    firstMonday,
    configuredWeekCount,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('first_monday')) {
      context.handle(
        _firstMondayMeta,
        firstMonday.isAcceptableOrUnknown(
          data['first_monday']!,
          _firstMondayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstMondayMeta);
    }
    if (data.containsKey('configured_week_count')) {
      context.handle(
        _configuredWeekCountMeta,
        configuredWeekCount.isAcceptableOrUnknown(
          data['configured_week_count']!,
          _configuredWeekCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_configuredWeekCountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      firstMonday: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_monday'],
      )!,
      configuredWeekCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}configured_week_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SchedulesTable createAlias(String alias) {
    return $SchedulesTable(attachedDatabase, alias);
  }
}

class ScheduleRow extends DataClass implements Insertable<ScheduleRow> {
  final int id;
  final String displayName;
  final String firstMonday;
  final int configuredWeekCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ScheduleRow({
    required this.id,
    required this.displayName,
    required this.firstMonday,
    required this.configuredWeekCount,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['display_name'] = Variable<String>(displayName);
    map['first_monday'] = Variable<String>(firstMonday);
    map['configured_week_count'] = Variable<int>(configuredWeekCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SchedulesCompanion toCompanion(bool nullToAbsent) {
    return SchedulesCompanion(
      id: Value(id),
      displayName: Value(displayName),
      firstMonday: Value(firstMonday),
      configuredWeekCount: Value(configuredWeekCount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ScheduleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleRow(
      id: serializer.fromJson<int>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      firstMonday: serializer.fromJson<String>(json['firstMonday']),
      configuredWeekCount: serializer.fromJson<int>(
        json['configuredWeekCount'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'displayName': serializer.toJson<String>(displayName),
      'firstMonday': serializer.toJson<String>(firstMonday),
      'configuredWeekCount': serializer.toJson<int>(configuredWeekCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ScheduleRow copyWith({
    int? id,
    String? displayName,
    String? firstMonday,
    int? configuredWeekCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ScheduleRow(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    firstMonday: firstMonday ?? this.firstMonday,
    configuredWeekCount: configuredWeekCount ?? this.configuredWeekCount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ScheduleRow copyWithCompanion(SchedulesCompanion data) {
    return ScheduleRow(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      firstMonday: data.firstMonday.present
          ? data.firstMonday.value
          : this.firstMonday,
      configuredWeekCount: data.configuredWeekCount.present
          ? data.configuredWeekCount.value
          : this.configuredWeekCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleRow(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('firstMonday: $firstMonday, ')
          ..write('configuredWeekCount: $configuredWeekCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    firstMonday,
    configuredWeekCount,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleRow &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.firstMonday == this.firstMonday &&
          other.configuredWeekCount == this.configuredWeekCount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SchedulesCompanion extends UpdateCompanion<ScheduleRow> {
  final Value<int> id;
  final Value<String> displayName;
  final Value<String> firstMonday;
  final Value<int> configuredWeekCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SchedulesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.firstMonday = const Value.absent(),
    this.configuredWeekCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SchedulesCompanion.insert({
    this.id = const Value.absent(),
    required String displayName,
    required String firstMonday,
    required int configuredWeekCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : displayName = Value(displayName),
       firstMonday = Value(firstMonday),
       configuredWeekCount = Value(configuredWeekCount),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ScheduleRow> custom({
    Expression<int>? id,
    Expression<String>? displayName,
    Expression<String>? firstMonday,
    Expression<int>? configuredWeekCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (firstMonday != null) 'first_monday': firstMonday,
      if (configuredWeekCount != null)
        'configured_week_count': configuredWeekCount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SchedulesCompanion copyWith({
    Value<int>? id,
    Value<String>? displayName,
    Value<String>? firstMonday,
    Value<int>? configuredWeekCount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return SchedulesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      firstMonday: firstMonday ?? this.firstMonday,
      configuredWeekCount: configuredWeekCount ?? this.configuredWeekCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (firstMonday.present) {
      map['first_monday'] = Variable<String>(firstMonday.value);
    }
    if (configuredWeekCount.present) {
      map['configured_week_count'] = Variable<int>(configuredWeekCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchedulesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('firstMonday: $firstMonday, ')
          ..write('configuredWeekCount: $configuredWeekCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CoursesTable extends Courses with TableInfo<$CoursesTable, CourseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _scheduleIdMeta = const VerificationMeta(
    'scheduleId',
  );
  @override
  late final GeneratedColumn<int> scheduleId = GeneratedColumn<int>(
    'schedule_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES schedules (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<int> origin = GeneratedColumn<int>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importKeyMeta = const VerificationMeta(
    'importKey',
  );
  @override
  late final GeneratedColumn<String> importKey = GeneratedColumn<String>(
    'import_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _courseCodeMeta = const VerificationMeta(
    'courseCode',
  );
  @override
  late final GeneratedColumn<String> courseCode = GeneratedColumn<String>(
    'course_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<String> sequence = GeneratedColumn<String>(
    'sequence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourcePresentMeta = const VerificationMeta(
    'sourcePresent',
  );
  @override
  late final GeneratedColumn<bool> sourcePresent = GeneratedColumn<bool>(
    'source_present',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("source_present" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _courseDetailLinkMeta = const VerificationMeta(
    'courseDetailLink',
  );
  @override
  late final GeneratedColumn<String> courseDetailLink = GeneratedColumn<String>(
    'course_detail_link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _teachingRecordLinkMeta =
      const VerificationMeta('teachingRecordLink');
  @override
  late final GeneratedColumn<String> teachingRecordLink =
      GeneratedColumn<String>(
        'teaching_record_link',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _processScoreLinkMeta = const VerificationMeta(
    'processScoreLink',
  );
  @override
  late final GeneratedColumn<String> processScoreLink = GeneratedColumn<String>(
    'process_score_link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scheduleId,
    origin,
    importKey,
    courseCode,
    sequence,
    sourcePresent,
    courseDetailLink,
    teachingRecordLink,
    processScoreLink,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'courses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
        _scheduleIdMeta,
        scheduleId.isAcceptableOrUnknown(data['schedule_id']!, _scheduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scheduleIdMeta);
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('import_key')) {
      context.handle(
        _importKeyMeta,
        importKey.isAcceptableOrUnknown(data['import_key']!, _importKeyMeta),
      );
    }
    if (data.containsKey('course_code')) {
      context.handle(
        _courseCodeMeta,
        courseCode.isAcceptableOrUnknown(data['course_code']!, _courseCodeMeta),
      );
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    }
    if (data.containsKey('source_present')) {
      context.handle(
        _sourcePresentMeta,
        sourcePresent.isAcceptableOrUnknown(
          data['source_present']!,
          _sourcePresentMeta,
        ),
      );
    }
    if (data.containsKey('course_detail_link')) {
      context.handle(
        _courseDetailLinkMeta,
        courseDetailLink.isAcceptableOrUnknown(
          data['course_detail_link']!,
          _courseDetailLinkMeta,
        ),
      );
    }
    if (data.containsKey('teaching_record_link')) {
      context.handle(
        _teachingRecordLinkMeta,
        teachingRecordLink.isAcceptableOrUnknown(
          data['teaching_record_link']!,
          _teachingRecordLinkMeta,
        ),
      );
    }
    if (data.containsKey('process_score_link')) {
      context.handle(
        _processScoreLinkMeta,
        processScoreLink.isAcceptableOrUnknown(
          data['process_score_link']!,
          _processScoreLinkMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {scheduleId, importKey},
  ];
  @override
  CourseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      scheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schedule_id'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}origin'],
      )!,
      importKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}import_key'],
      ),
      courseCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_code'],
      ),
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sequence'],
      ),
      sourcePresent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}source_present'],
      )!,
      courseDetailLink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_detail_link'],
      ),
      teachingRecordLink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teaching_record_link'],
      ),
      processScoreLink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}process_score_link'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CoursesTable createAlias(String alias) {
    return $CoursesTable(attachedDatabase, alias);
  }
}

class CourseRow extends DataClass implements Insertable<CourseRow> {
  final int id;
  final int scheduleId;
  final int origin;
  final String? importKey;
  final String? courseCode;
  final String? sequence;
  final bool sourcePresent;
  final String? courseDetailLink;
  final String? teachingRecordLink;
  final String? processScoreLink;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CourseRow({
    required this.id,
    required this.scheduleId,
    required this.origin,
    this.importKey,
    this.courseCode,
    this.sequence,
    required this.sourcePresent,
    this.courseDetailLink,
    this.teachingRecordLink,
    this.processScoreLink,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['schedule_id'] = Variable<int>(scheduleId);
    map['origin'] = Variable<int>(origin);
    if (!nullToAbsent || importKey != null) {
      map['import_key'] = Variable<String>(importKey);
    }
    if (!nullToAbsent || courseCode != null) {
      map['course_code'] = Variable<String>(courseCode);
    }
    if (!nullToAbsent || sequence != null) {
      map['sequence'] = Variable<String>(sequence);
    }
    map['source_present'] = Variable<bool>(sourcePresent);
    if (!nullToAbsent || courseDetailLink != null) {
      map['course_detail_link'] = Variable<String>(courseDetailLink);
    }
    if (!nullToAbsent || teachingRecordLink != null) {
      map['teaching_record_link'] = Variable<String>(teachingRecordLink);
    }
    if (!nullToAbsent || processScoreLink != null) {
      map['process_score_link'] = Variable<String>(processScoreLink);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CoursesCompanion toCompanion(bool nullToAbsent) {
    return CoursesCompanion(
      id: Value(id),
      scheduleId: Value(scheduleId),
      origin: Value(origin),
      importKey: importKey == null && nullToAbsent
          ? const Value.absent()
          : Value(importKey),
      courseCode: courseCode == null && nullToAbsent
          ? const Value.absent()
          : Value(courseCode),
      sequence: sequence == null && nullToAbsent
          ? const Value.absent()
          : Value(sequence),
      sourcePresent: Value(sourcePresent),
      courseDetailLink: courseDetailLink == null && nullToAbsent
          ? const Value.absent()
          : Value(courseDetailLink),
      teachingRecordLink: teachingRecordLink == null && nullToAbsent
          ? const Value.absent()
          : Value(teachingRecordLink),
      processScoreLink: processScoreLink == null && nullToAbsent
          ? const Value.absent()
          : Value(processScoreLink),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CourseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseRow(
      id: serializer.fromJson<int>(json['id']),
      scheduleId: serializer.fromJson<int>(json['scheduleId']),
      origin: serializer.fromJson<int>(json['origin']),
      importKey: serializer.fromJson<String?>(json['importKey']),
      courseCode: serializer.fromJson<String?>(json['courseCode']),
      sequence: serializer.fromJson<String?>(json['sequence']),
      sourcePresent: serializer.fromJson<bool>(json['sourcePresent']),
      courseDetailLink: serializer.fromJson<String?>(json['courseDetailLink']),
      teachingRecordLink: serializer.fromJson<String?>(
        json['teachingRecordLink'],
      ),
      processScoreLink: serializer.fromJson<String?>(json['processScoreLink']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scheduleId': serializer.toJson<int>(scheduleId),
      'origin': serializer.toJson<int>(origin),
      'importKey': serializer.toJson<String?>(importKey),
      'courseCode': serializer.toJson<String?>(courseCode),
      'sequence': serializer.toJson<String?>(sequence),
      'sourcePresent': serializer.toJson<bool>(sourcePresent),
      'courseDetailLink': serializer.toJson<String?>(courseDetailLink),
      'teachingRecordLink': serializer.toJson<String?>(teachingRecordLink),
      'processScoreLink': serializer.toJson<String?>(processScoreLink),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CourseRow copyWith({
    int? id,
    int? scheduleId,
    int? origin,
    Value<String?> importKey = const Value.absent(),
    Value<String?> courseCode = const Value.absent(),
    Value<String?> sequence = const Value.absent(),
    bool? sourcePresent,
    Value<String?> courseDetailLink = const Value.absent(),
    Value<String?> teachingRecordLink = const Value.absent(),
    Value<String?> processScoreLink = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CourseRow(
    id: id ?? this.id,
    scheduleId: scheduleId ?? this.scheduleId,
    origin: origin ?? this.origin,
    importKey: importKey.present ? importKey.value : this.importKey,
    courseCode: courseCode.present ? courseCode.value : this.courseCode,
    sequence: sequence.present ? sequence.value : this.sequence,
    sourcePresent: sourcePresent ?? this.sourcePresent,
    courseDetailLink: courseDetailLink.present
        ? courseDetailLink.value
        : this.courseDetailLink,
    teachingRecordLink: teachingRecordLink.present
        ? teachingRecordLink.value
        : this.teachingRecordLink,
    processScoreLink: processScoreLink.present
        ? processScoreLink.value
        : this.processScoreLink,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CourseRow copyWithCompanion(CoursesCompanion data) {
    return CourseRow(
      id: data.id.present ? data.id.value : this.id,
      scheduleId: data.scheduleId.present
          ? data.scheduleId.value
          : this.scheduleId,
      origin: data.origin.present ? data.origin.value : this.origin,
      importKey: data.importKey.present ? data.importKey.value : this.importKey,
      courseCode: data.courseCode.present
          ? data.courseCode.value
          : this.courseCode,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      sourcePresent: data.sourcePresent.present
          ? data.sourcePresent.value
          : this.sourcePresent,
      courseDetailLink: data.courseDetailLink.present
          ? data.courseDetailLink.value
          : this.courseDetailLink,
      teachingRecordLink: data.teachingRecordLink.present
          ? data.teachingRecordLink.value
          : this.teachingRecordLink,
      processScoreLink: data.processScoreLink.present
          ? data.processScoreLink.value
          : this.processScoreLink,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseRow(')
          ..write('id: $id, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('origin: $origin, ')
          ..write('importKey: $importKey, ')
          ..write('courseCode: $courseCode, ')
          ..write('sequence: $sequence, ')
          ..write('sourcePresent: $sourcePresent, ')
          ..write('courseDetailLink: $courseDetailLink, ')
          ..write('teachingRecordLink: $teachingRecordLink, ')
          ..write('processScoreLink: $processScoreLink, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scheduleId,
    origin,
    importKey,
    courseCode,
    sequence,
    sourcePresent,
    courseDetailLink,
    teachingRecordLink,
    processScoreLink,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseRow &&
          other.id == this.id &&
          other.scheduleId == this.scheduleId &&
          other.origin == this.origin &&
          other.importKey == this.importKey &&
          other.courseCode == this.courseCode &&
          other.sequence == this.sequence &&
          other.sourcePresent == this.sourcePresent &&
          other.courseDetailLink == this.courseDetailLink &&
          other.teachingRecordLink == this.teachingRecordLink &&
          other.processScoreLink == this.processScoreLink &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CoursesCompanion extends UpdateCompanion<CourseRow> {
  final Value<int> id;
  final Value<int> scheduleId;
  final Value<int> origin;
  final Value<String?> importKey;
  final Value<String?> courseCode;
  final Value<String?> sequence;
  final Value<bool> sourcePresent;
  final Value<String?> courseDetailLink;
  final Value<String?> teachingRecordLink;
  final Value<String?> processScoreLink;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CoursesCompanion({
    this.id = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.origin = const Value.absent(),
    this.importKey = const Value.absent(),
    this.courseCode = const Value.absent(),
    this.sequence = const Value.absent(),
    this.sourcePresent = const Value.absent(),
    this.courseDetailLink = const Value.absent(),
    this.teachingRecordLink = const Value.absent(),
    this.processScoreLink = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CoursesCompanion.insert({
    this.id = const Value.absent(),
    required int scheduleId,
    required int origin,
    this.importKey = const Value.absent(),
    this.courseCode = const Value.absent(),
    this.sequence = const Value.absent(),
    this.sourcePresent = const Value.absent(),
    this.courseDetailLink = const Value.absent(),
    this.teachingRecordLink = const Value.absent(),
    this.processScoreLink = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : scheduleId = Value(scheduleId),
       origin = Value(origin),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CourseRow> custom({
    Expression<int>? id,
    Expression<int>? scheduleId,
    Expression<int>? origin,
    Expression<String>? importKey,
    Expression<String>? courseCode,
    Expression<String>? sequence,
    Expression<bool>? sourcePresent,
    Expression<String>? courseDetailLink,
    Expression<String>? teachingRecordLink,
    Expression<String>? processScoreLink,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (origin != null) 'origin': origin,
      if (importKey != null) 'import_key': importKey,
      if (courseCode != null) 'course_code': courseCode,
      if (sequence != null) 'sequence': sequence,
      if (sourcePresent != null) 'source_present': sourcePresent,
      if (courseDetailLink != null) 'course_detail_link': courseDetailLink,
      if (teachingRecordLink != null)
        'teaching_record_link': teachingRecordLink,
      if (processScoreLink != null) 'process_score_link': processScoreLink,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CoursesCompanion copyWith({
    Value<int>? id,
    Value<int>? scheduleId,
    Value<int>? origin,
    Value<String?>? importKey,
    Value<String?>? courseCode,
    Value<String?>? sequence,
    Value<bool>? sourcePresent,
    Value<String?>? courseDetailLink,
    Value<String?>? teachingRecordLink,
    Value<String?>? processScoreLink,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CoursesCompanion(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      origin: origin ?? this.origin,
      importKey: importKey ?? this.importKey,
      courseCode: courseCode ?? this.courseCode,
      sequence: sequence ?? this.sequence,
      sourcePresent: sourcePresent ?? this.sourcePresent,
      courseDetailLink: courseDetailLink ?? this.courseDetailLink,
      teachingRecordLink: teachingRecordLink ?? this.teachingRecordLink,
      processScoreLink: processScoreLink ?? this.processScoreLink,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<int>(scheduleId.value);
    }
    if (origin.present) {
      map['origin'] = Variable<int>(origin.value);
    }
    if (importKey.present) {
      map['import_key'] = Variable<String>(importKey.value);
    }
    if (courseCode.present) {
      map['course_code'] = Variable<String>(courseCode.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<String>(sequence.value);
    }
    if (sourcePresent.present) {
      map['source_present'] = Variable<bool>(sourcePresent.value);
    }
    if (courseDetailLink.present) {
      map['course_detail_link'] = Variable<String>(courseDetailLink.value);
    }
    if (teachingRecordLink.present) {
      map['teaching_record_link'] = Variable<String>(teachingRecordLink.value);
    }
    if (processScoreLink.present) {
      map['process_score_link'] = Variable<String>(processScoreLink.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoursesCompanion(')
          ..write('id: $id, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('origin: $origin, ')
          ..write('importKey: $importKey, ')
          ..write('courseCode: $courseCode, ')
          ..write('sequence: $sequence, ')
          ..write('sourcePresent: $sourcePresent, ')
          ..write('courseDetailLink: $courseDetailLink, ')
          ..write('teachingRecordLink: $teachingRecordLink, ')
          ..write('processScoreLink: $processScoreLink, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CourseVersionsTable extends CourseVersions
    with TableInfo<$CourseVersionsTable, CourseVersionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<int> courseId = GeneratedColumn<int>(
    'course_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES courses (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<int> kind = GeneratedColumn<int>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditsMeta = const VerificationMeta(
    'credits',
  );
  @override
  late final GeneratedColumn<String> credits = GeneratedColumn<String>(
    'credits',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _selectionTypeMeta = const VerificationMeta(
    'selectionType',
  );
  @override
  late final GeneratedColumn<String> selectionType = GeneratedColumn<String>(
    'selection_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _assessmentMeta = const VerificationMeta(
    'assessment',
  );
  @override
  late final GeneratedColumn<String> assessment = GeneratedColumn<String>(
    'assessment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _examNatureMeta = const VerificationMeta(
    'examNature',
  );
  @override
  late final GeneratedColumn<String> examNature = GeneratedColumn<String>(
    'exam_nature',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _deferredExamMeta = const VerificationMeta(
    'deferredExam',
  );
  @override
  late final GeneratedColumn<String> deferredExam = GeneratedColumn<String>(
    'deferred_exam',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _materialMeta = const VerificationMeta(
    'material',
  );
  @override
  late final GeneratedColumn<String> material = GeneratedColumn<String>(
    'material',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    courseId,
    kind,
    isDeleted,
    name,
    credits,
    selectionType,
    assessment,
    examNature,
    deferredExam,
    material,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseVersionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('credits')) {
      context.handle(
        _creditsMeta,
        credits.isAcceptableOrUnknown(data['credits']!, _creditsMeta),
      );
    }
    if (data.containsKey('selection_type')) {
      context.handle(
        _selectionTypeMeta,
        selectionType.isAcceptableOrUnknown(
          data['selection_type']!,
          _selectionTypeMeta,
        ),
      );
    }
    if (data.containsKey('assessment')) {
      context.handle(
        _assessmentMeta,
        assessment.isAcceptableOrUnknown(data['assessment']!, _assessmentMeta),
      );
    }
    if (data.containsKey('exam_nature')) {
      context.handle(
        _examNatureMeta,
        examNature.isAcceptableOrUnknown(data['exam_nature']!, _examNatureMeta),
      );
    }
    if (data.containsKey('deferred_exam')) {
      context.handle(
        _deferredExamMeta,
        deferredExam.isAcceptableOrUnknown(
          data['deferred_exam']!,
          _deferredExamMeta,
        ),
      );
    }
    if (data.containsKey('material')) {
      context.handle(
        _materialMeta,
        material.isAcceptableOrUnknown(data['material']!, _materialMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {courseId, kind},
  ];
  @override
  CourseVersionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseVersionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}course_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kind'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      credits: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}credits'],
      )!,
      selectionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selection_type'],
      )!,
      assessment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assessment'],
      )!,
      examNature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exam_nature'],
      )!,
      deferredExam: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deferred_exam'],
      )!,
      material: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CourseVersionsTable createAlias(String alias) {
    return $CourseVersionsTable(attachedDatabase, alias);
  }
}

class CourseVersionRow extends DataClass
    implements Insertable<CourseVersionRow> {
  final int id;
  final int courseId;
  final int kind;
  final bool isDeleted;
  final String name;
  final String credits;
  final String selectionType;
  final String assessment;
  final String examNature;
  final String deferredExam;
  final String material;
  final DateTime updatedAt;
  const CourseVersionRow({
    required this.id,
    required this.courseId,
    required this.kind,
    required this.isDeleted,
    required this.name,
    required this.credits,
    required this.selectionType,
    required this.assessment,
    required this.examNature,
    required this.deferredExam,
    required this.material,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['course_id'] = Variable<int>(courseId);
    map['kind'] = Variable<int>(kind);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['name'] = Variable<String>(name);
    map['credits'] = Variable<String>(credits);
    map['selection_type'] = Variable<String>(selectionType);
    map['assessment'] = Variable<String>(assessment);
    map['exam_nature'] = Variable<String>(examNature);
    map['deferred_exam'] = Variable<String>(deferredExam);
    map['material'] = Variable<String>(material);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CourseVersionsCompanion toCompanion(bool nullToAbsent) {
    return CourseVersionsCompanion(
      id: Value(id),
      courseId: Value(courseId),
      kind: Value(kind),
      isDeleted: Value(isDeleted),
      name: Value(name),
      credits: Value(credits),
      selectionType: Value(selectionType),
      assessment: Value(assessment),
      examNature: Value(examNature),
      deferredExam: Value(deferredExam),
      material: Value(material),
      updatedAt: Value(updatedAt),
    );
  }

  factory CourseVersionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseVersionRow(
      id: serializer.fromJson<int>(json['id']),
      courseId: serializer.fromJson<int>(json['courseId']),
      kind: serializer.fromJson<int>(json['kind']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      name: serializer.fromJson<String>(json['name']),
      credits: serializer.fromJson<String>(json['credits']),
      selectionType: serializer.fromJson<String>(json['selectionType']),
      assessment: serializer.fromJson<String>(json['assessment']),
      examNature: serializer.fromJson<String>(json['examNature']),
      deferredExam: serializer.fromJson<String>(json['deferredExam']),
      material: serializer.fromJson<String>(json['material']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'courseId': serializer.toJson<int>(courseId),
      'kind': serializer.toJson<int>(kind),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'name': serializer.toJson<String>(name),
      'credits': serializer.toJson<String>(credits),
      'selectionType': serializer.toJson<String>(selectionType),
      'assessment': serializer.toJson<String>(assessment),
      'examNature': serializer.toJson<String>(examNature),
      'deferredExam': serializer.toJson<String>(deferredExam),
      'material': serializer.toJson<String>(material),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CourseVersionRow copyWith({
    int? id,
    int? courseId,
    int? kind,
    bool? isDeleted,
    String? name,
    String? credits,
    String? selectionType,
    String? assessment,
    String? examNature,
    String? deferredExam,
    String? material,
    DateTime? updatedAt,
  }) => CourseVersionRow(
    id: id ?? this.id,
    courseId: courseId ?? this.courseId,
    kind: kind ?? this.kind,
    isDeleted: isDeleted ?? this.isDeleted,
    name: name ?? this.name,
    credits: credits ?? this.credits,
    selectionType: selectionType ?? this.selectionType,
    assessment: assessment ?? this.assessment,
    examNature: examNature ?? this.examNature,
    deferredExam: deferredExam ?? this.deferredExam,
    material: material ?? this.material,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CourseVersionRow copyWithCompanion(CourseVersionsCompanion data) {
    return CourseVersionRow(
      id: data.id.present ? data.id.value : this.id,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      kind: data.kind.present ? data.kind.value : this.kind,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      name: data.name.present ? data.name.value : this.name,
      credits: data.credits.present ? data.credits.value : this.credits,
      selectionType: data.selectionType.present
          ? data.selectionType.value
          : this.selectionType,
      assessment: data.assessment.present
          ? data.assessment.value
          : this.assessment,
      examNature: data.examNature.present
          ? data.examNature.value
          : this.examNature,
      deferredExam: data.deferredExam.present
          ? data.deferredExam.value
          : this.deferredExam,
      material: data.material.present ? data.material.value : this.material,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseVersionRow(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('kind: $kind, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('name: $name, ')
          ..write('credits: $credits, ')
          ..write('selectionType: $selectionType, ')
          ..write('assessment: $assessment, ')
          ..write('examNature: $examNature, ')
          ..write('deferredExam: $deferredExam, ')
          ..write('material: $material, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    courseId,
    kind,
    isDeleted,
    name,
    credits,
    selectionType,
    assessment,
    examNature,
    deferredExam,
    material,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseVersionRow &&
          other.id == this.id &&
          other.courseId == this.courseId &&
          other.kind == this.kind &&
          other.isDeleted == this.isDeleted &&
          other.name == this.name &&
          other.credits == this.credits &&
          other.selectionType == this.selectionType &&
          other.assessment == this.assessment &&
          other.examNature == this.examNature &&
          other.deferredExam == this.deferredExam &&
          other.material == this.material &&
          other.updatedAt == this.updatedAt);
}

class CourseVersionsCompanion extends UpdateCompanion<CourseVersionRow> {
  final Value<int> id;
  final Value<int> courseId;
  final Value<int> kind;
  final Value<bool> isDeleted;
  final Value<String> name;
  final Value<String> credits;
  final Value<String> selectionType;
  final Value<String> assessment;
  final Value<String> examNature;
  final Value<String> deferredExam;
  final Value<String> material;
  final Value<DateTime> updatedAt;
  const CourseVersionsCompanion({
    this.id = const Value.absent(),
    this.courseId = const Value.absent(),
    this.kind = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.name = const Value.absent(),
    this.credits = const Value.absent(),
    this.selectionType = const Value.absent(),
    this.assessment = const Value.absent(),
    this.examNature = const Value.absent(),
    this.deferredExam = const Value.absent(),
    this.material = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CourseVersionsCompanion.insert({
    this.id = const Value.absent(),
    required int courseId,
    required int kind,
    this.isDeleted = const Value.absent(),
    required String name,
    this.credits = const Value.absent(),
    this.selectionType = const Value.absent(),
    this.assessment = const Value.absent(),
    this.examNature = const Value.absent(),
    this.deferredExam = const Value.absent(),
    this.material = const Value.absent(),
    required DateTime updatedAt,
  }) : courseId = Value(courseId),
       kind = Value(kind),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<CourseVersionRow> custom({
    Expression<int>? id,
    Expression<int>? courseId,
    Expression<int>? kind,
    Expression<bool>? isDeleted,
    Expression<String>? name,
    Expression<String>? credits,
    Expression<String>? selectionType,
    Expression<String>? assessment,
    Expression<String>? examNature,
    Expression<String>? deferredExam,
    Expression<String>? material,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (courseId != null) 'course_id': courseId,
      if (kind != null) 'kind': kind,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (name != null) 'name': name,
      if (credits != null) 'credits': credits,
      if (selectionType != null) 'selection_type': selectionType,
      if (assessment != null) 'assessment': assessment,
      if (examNature != null) 'exam_nature': examNature,
      if (deferredExam != null) 'deferred_exam': deferredExam,
      if (material != null) 'material': material,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CourseVersionsCompanion copyWith({
    Value<int>? id,
    Value<int>? courseId,
    Value<int>? kind,
    Value<bool>? isDeleted,
    Value<String>? name,
    Value<String>? credits,
    Value<String>? selectionType,
    Value<String>? assessment,
    Value<String>? examNature,
    Value<String>? deferredExam,
    Value<String>? material,
    Value<DateTime>? updatedAt,
  }) {
    return CourseVersionsCompanion(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      kind: kind ?? this.kind,
      isDeleted: isDeleted ?? this.isDeleted,
      name: name ?? this.name,
      credits: credits ?? this.credits,
      selectionType: selectionType ?? this.selectionType,
      assessment: assessment ?? this.assessment,
      examNature: examNature ?? this.examNature,
      deferredExam: deferredExam ?? this.deferredExam,
      material: material ?? this.material,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<int>(courseId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(kind.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (credits.present) {
      map['credits'] = Variable<String>(credits.value);
    }
    if (selectionType.present) {
      map['selection_type'] = Variable<String>(selectionType.value);
    }
    if (assessment.present) {
      map['assessment'] = Variable<String>(assessment.value);
    }
    if (examNature.present) {
      map['exam_nature'] = Variable<String>(examNature.value);
    }
    if (deferredExam.present) {
      map['deferred_exam'] = Variable<String>(deferredExam.value);
    }
    if (material.present) {
      map['material'] = Variable<String>(material.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseVersionsCompanion(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('kind: $kind, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('name: $name, ')
          ..write('credits: $credits, ')
          ..write('selectionType: $selectionType, ')
          ..write('assessment: $assessment, ')
          ..write('examNature: $examNature, ')
          ..write('deferredExam: $deferredExam, ')
          ..write('material: $material, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CourseTeachersTable extends CourseTeachers
    with TableInfo<$CourseTeachersTable, CourseTeacherRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseTeachersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _versionIdMeta = const VerificationMeta(
    'versionId',
  );
  @override
  late final GeneratedColumn<int> versionId = GeneratedColumn<int>(
    'version_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES course_versions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [versionId, position, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_teachers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseTeacherRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('version_id')) {
      context.handle(
        _versionIdMeta,
        versionId.isAcceptableOrUnknown(data['version_id']!, _versionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_versionIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {versionId, position};
  @override
  CourseTeacherRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseTeacherRow(
      versionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CourseTeachersTable createAlias(String alias) {
    return $CourseTeachersTable(attachedDatabase, alias);
  }
}

class CourseTeacherRow extends DataClass
    implements Insertable<CourseTeacherRow> {
  final int versionId;
  final int position;
  final String name;
  const CourseTeacherRow({
    required this.versionId,
    required this.position,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['version_id'] = Variable<int>(versionId);
    map['position'] = Variable<int>(position);
    map['name'] = Variable<String>(name);
    return map;
  }

  CourseTeachersCompanion toCompanion(bool nullToAbsent) {
    return CourseTeachersCompanion(
      versionId: Value(versionId),
      position: Value(position),
      name: Value(name),
    );
  }

  factory CourseTeacherRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseTeacherRow(
      versionId: serializer.fromJson<int>(json['versionId']),
      position: serializer.fromJson<int>(json['position']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'versionId': serializer.toJson<int>(versionId),
      'position': serializer.toJson<int>(position),
      'name': serializer.toJson<String>(name),
    };
  }

  CourseTeacherRow copyWith({int? versionId, int? position, String? name}) =>
      CourseTeacherRow(
        versionId: versionId ?? this.versionId,
        position: position ?? this.position,
        name: name ?? this.name,
      );
  CourseTeacherRow copyWithCompanion(CourseTeachersCompanion data) {
    return CourseTeacherRow(
      versionId: data.versionId.present ? data.versionId.value : this.versionId,
      position: data.position.present ? data.position.value : this.position,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseTeacherRow(')
          ..write('versionId: $versionId, ')
          ..write('position: $position, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(versionId, position, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseTeacherRow &&
          other.versionId == this.versionId &&
          other.position == this.position &&
          other.name == this.name);
}

class CourseTeachersCompanion extends UpdateCompanion<CourseTeacherRow> {
  final Value<int> versionId;
  final Value<int> position;
  final Value<String> name;
  final Value<int> rowid;
  const CourseTeachersCompanion({
    this.versionId = const Value.absent(),
    this.position = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CourseTeachersCompanion.insert({
    required int versionId,
    required int position,
    required String name,
    this.rowid = const Value.absent(),
  }) : versionId = Value(versionId),
       position = Value(position),
       name = Value(name);
  static Insertable<CourseTeacherRow> custom({
    Expression<int>? versionId,
    Expression<int>? position,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (versionId != null) 'version_id': versionId,
      if (position != null) 'position': position,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CourseTeachersCompanion copyWith({
    Value<int>? versionId,
    Value<int>? position,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return CourseTeachersCompanion(
      versionId: versionId ?? this.versionId,
      position: position ?? this.position,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (versionId.present) {
      map['version_id'] = Variable<int>(versionId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseTeachersCompanion(')
          ..write('versionId: $versionId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CourseMeetingsTable extends CourseMeetings
    with TableInfo<$CourseMeetingsTable, CourseMeetingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseMeetingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _versionIdMeta = const VerificationMeta(
    'versionId',
  );
  @override
  late final GeneratedColumn<int> versionId = GeneratedColumn<int>(
    'version_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES course_versions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startSectionMeta = const VerificationMeta(
    'startSection',
  );
  @override
  late final GeneratedColumn<int> startSection = GeneratedColumn<int>(
    'start_section',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endSectionMeta = const VerificationMeta(
    'endSection',
  );
  @override
  late final GeneratedColumn<int> endSection = GeneratedColumn<int>(
    'end_section',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    versionId,
    position,
    weekday,
    startSection,
    endSection,
    location,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_meetings';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseMeetingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('version_id')) {
      context.handle(
        _versionIdMeta,
        versionId.isAcceptableOrUnknown(data['version_id']!, _versionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_versionIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('start_section')) {
      context.handle(
        _startSectionMeta,
        startSection.isAcceptableOrUnknown(
          data['start_section']!,
          _startSectionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startSectionMeta);
    }
    if (data.containsKey('end_section')) {
      context.handle(
        _endSectionMeta,
        endSection.isAcceptableOrUnknown(data['end_section']!, _endSectionMeta),
      );
    } else if (isInserting) {
      context.missing(_endSectionMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {versionId, position},
  ];
  @override
  CourseMeetingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseMeetingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      versionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
      startSection: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_section'],
      )!,
      endSection: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_section'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
    );
  }

  @override
  $CourseMeetingsTable createAlias(String alias) {
    return $CourseMeetingsTable(attachedDatabase, alias);
  }
}

class CourseMeetingRow extends DataClass
    implements Insertable<CourseMeetingRow> {
  final int id;
  final int versionId;
  final int position;
  final int weekday;
  final int startSection;
  final int endSection;
  final String location;
  const CourseMeetingRow({
    required this.id,
    required this.versionId,
    required this.position,
    required this.weekday,
    required this.startSection,
    required this.endSection,
    required this.location,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['version_id'] = Variable<int>(versionId);
    map['position'] = Variable<int>(position);
    map['weekday'] = Variable<int>(weekday);
    map['start_section'] = Variable<int>(startSection);
    map['end_section'] = Variable<int>(endSection);
    map['location'] = Variable<String>(location);
    return map;
  }

  CourseMeetingsCompanion toCompanion(bool nullToAbsent) {
    return CourseMeetingsCompanion(
      id: Value(id),
      versionId: Value(versionId),
      position: Value(position),
      weekday: Value(weekday),
      startSection: Value(startSection),
      endSection: Value(endSection),
      location: Value(location),
    );
  }

  factory CourseMeetingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseMeetingRow(
      id: serializer.fromJson<int>(json['id']),
      versionId: serializer.fromJson<int>(json['versionId']),
      position: serializer.fromJson<int>(json['position']),
      weekday: serializer.fromJson<int>(json['weekday']),
      startSection: serializer.fromJson<int>(json['startSection']),
      endSection: serializer.fromJson<int>(json['endSection']),
      location: serializer.fromJson<String>(json['location']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'versionId': serializer.toJson<int>(versionId),
      'position': serializer.toJson<int>(position),
      'weekday': serializer.toJson<int>(weekday),
      'startSection': serializer.toJson<int>(startSection),
      'endSection': serializer.toJson<int>(endSection),
      'location': serializer.toJson<String>(location),
    };
  }

  CourseMeetingRow copyWith({
    int? id,
    int? versionId,
    int? position,
    int? weekday,
    int? startSection,
    int? endSection,
    String? location,
  }) => CourseMeetingRow(
    id: id ?? this.id,
    versionId: versionId ?? this.versionId,
    position: position ?? this.position,
    weekday: weekday ?? this.weekday,
    startSection: startSection ?? this.startSection,
    endSection: endSection ?? this.endSection,
    location: location ?? this.location,
  );
  CourseMeetingRow copyWithCompanion(CourseMeetingsCompanion data) {
    return CourseMeetingRow(
      id: data.id.present ? data.id.value : this.id,
      versionId: data.versionId.present ? data.versionId.value : this.versionId,
      position: data.position.present ? data.position.value : this.position,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      startSection: data.startSection.present
          ? data.startSection.value
          : this.startSection,
      endSection: data.endSection.present
          ? data.endSection.value
          : this.endSection,
      location: data.location.present ? data.location.value : this.location,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseMeetingRow(')
          ..write('id: $id, ')
          ..write('versionId: $versionId, ')
          ..write('position: $position, ')
          ..write('weekday: $weekday, ')
          ..write('startSection: $startSection, ')
          ..write('endSection: $endSection, ')
          ..write('location: $location')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    versionId,
    position,
    weekday,
    startSection,
    endSection,
    location,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseMeetingRow &&
          other.id == this.id &&
          other.versionId == this.versionId &&
          other.position == this.position &&
          other.weekday == this.weekday &&
          other.startSection == this.startSection &&
          other.endSection == this.endSection &&
          other.location == this.location);
}

class CourseMeetingsCompanion extends UpdateCompanion<CourseMeetingRow> {
  final Value<int> id;
  final Value<int> versionId;
  final Value<int> position;
  final Value<int> weekday;
  final Value<int> startSection;
  final Value<int> endSection;
  final Value<String> location;
  const CourseMeetingsCompanion({
    this.id = const Value.absent(),
    this.versionId = const Value.absent(),
    this.position = const Value.absent(),
    this.weekday = const Value.absent(),
    this.startSection = const Value.absent(),
    this.endSection = const Value.absent(),
    this.location = const Value.absent(),
  });
  CourseMeetingsCompanion.insert({
    this.id = const Value.absent(),
    required int versionId,
    required int position,
    required int weekday,
    required int startSection,
    required int endSection,
    this.location = const Value.absent(),
  }) : versionId = Value(versionId),
       position = Value(position),
       weekday = Value(weekday),
       startSection = Value(startSection),
       endSection = Value(endSection);
  static Insertable<CourseMeetingRow> custom({
    Expression<int>? id,
    Expression<int>? versionId,
    Expression<int>? position,
    Expression<int>? weekday,
    Expression<int>? startSection,
    Expression<int>? endSection,
    Expression<String>? location,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (versionId != null) 'version_id': versionId,
      if (position != null) 'position': position,
      if (weekday != null) 'weekday': weekday,
      if (startSection != null) 'start_section': startSection,
      if (endSection != null) 'end_section': endSection,
      if (location != null) 'location': location,
    });
  }

  CourseMeetingsCompanion copyWith({
    Value<int>? id,
    Value<int>? versionId,
    Value<int>? position,
    Value<int>? weekday,
    Value<int>? startSection,
    Value<int>? endSection,
    Value<String>? location,
  }) {
    return CourseMeetingsCompanion(
      id: id ?? this.id,
      versionId: versionId ?? this.versionId,
      position: position ?? this.position,
      weekday: weekday ?? this.weekday,
      startSection: startSection ?? this.startSection,
      endSection: endSection ?? this.endSection,
      location: location ?? this.location,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (versionId.present) {
      map['version_id'] = Variable<int>(versionId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (startSection.present) {
      map['start_section'] = Variable<int>(startSection.value);
    }
    if (endSection.present) {
      map['end_section'] = Variable<int>(endSection.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseMeetingsCompanion(')
          ..write('id: $id, ')
          ..write('versionId: $versionId, ')
          ..write('position: $position, ')
          ..write('weekday: $weekday, ')
          ..write('startSection: $startSection, ')
          ..write('endSection: $endSection, ')
          ..write('location: $location')
          ..write(')'))
        .toString();
  }
}

class $MeetingWeeksTable extends MeetingWeeks
    with TableInfo<$MeetingWeeksTable, MeetingWeekRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeetingWeeksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _meetingIdMeta = const VerificationMeta(
    'meetingId',
  );
  @override
  late final GeneratedColumn<int> meetingId = GeneratedColumn<int>(
    'meeting_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES course_meetings (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _weekMeta = const VerificationMeta('week');
  @override
  late final GeneratedColumn<int> week = GeneratedColumn<int>(
    'week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [meetingId, week];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meeting_weeks';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeetingWeekRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('meeting_id')) {
      context.handle(
        _meetingIdMeta,
        meetingId.isAcceptableOrUnknown(data['meeting_id']!, _meetingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_meetingIdMeta);
    }
    if (data.containsKey('week')) {
      context.handle(
        _weekMeta,
        week.isAcceptableOrUnknown(data['week']!, _weekMeta),
      );
    } else if (isInserting) {
      context.missing(_weekMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {meetingId, week};
  @override
  MeetingWeekRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeetingWeekRow(
      meetingId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meeting_id'],
      )!,
      week: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week'],
      )!,
    );
  }

  @override
  $MeetingWeeksTable createAlias(String alias) {
    return $MeetingWeeksTable(attachedDatabase, alias);
  }
}

class MeetingWeekRow extends DataClass implements Insertable<MeetingWeekRow> {
  final int meetingId;
  final int week;
  const MeetingWeekRow({required this.meetingId, required this.week});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['meeting_id'] = Variable<int>(meetingId);
    map['week'] = Variable<int>(week);
    return map;
  }

  MeetingWeeksCompanion toCompanion(bool nullToAbsent) {
    return MeetingWeeksCompanion(
      meetingId: Value(meetingId),
      week: Value(week),
    );
  }

  factory MeetingWeekRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeetingWeekRow(
      meetingId: serializer.fromJson<int>(json['meetingId']),
      week: serializer.fromJson<int>(json['week']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'meetingId': serializer.toJson<int>(meetingId),
      'week': serializer.toJson<int>(week),
    };
  }

  MeetingWeekRow copyWith({int? meetingId, int? week}) => MeetingWeekRow(
    meetingId: meetingId ?? this.meetingId,
    week: week ?? this.week,
  );
  MeetingWeekRow copyWithCompanion(MeetingWeeksCompanion data) {
    return MeetingWeekRow(
      meetingId: data.meetingId.present ? data.meetingId.value : this.meetingId,
      week: data.week.present ? data.week.value : this.week,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeetingWeekRow(')
          ..write('meetingId: $meetingId, ')
          ..write('week: $week')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(meetingId, week);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeetingWeekRow &&
          other.meetingId == this.meetingId &&
          other.week == this.week);
}

class MeetingWeeksCompanion extends UpdateCompanion<MeetingWeekRow> {
  final Value<int> meetingId;
  final Value<int> week;
  final Value<int> rowid;
  const MeetingWeeksCompanion({
    this.meetingId = const Value.absent(),
    this.week = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeetingWeeksCompanion.insert({
    required int meetingId,
    required int week,
    this.rowid = const Value.absent(),
  }) : meetingId = Value(meetingId),
       week = Value(week);
  static Insertable<MeetingWeekRow> custom({
    Expression<int>? meetingId,
    Expression<int>? week,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (meetingId != null) 'meeting_id': meetingId,
      if (week != null) 'week': week,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeetingWeeksCompanion copyWith({
    Value<int>? meetingId,
    Value<int>? week,
    Value<int>? rowid,
  }) {
    return MeetingWeeksCompanion(
      meetingId: meetingId ?? this.meetingId,
      week: week ?? this.week,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (meetingId.present) {
      map['meeting_id'] = Variable<int>(meetingId.value);
    }
    if (week.present) {
      map['week'] = Variable<int>(week.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeetingWeeksCompanion(')
          ..write('meetingId: $meetingId, ')
          ..write('week: $week, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SchedulesTable schedules = $SchedulesTable(this);
  late final $CoursesTable courses = $CoursesTable(this);
  late final $CourseVersionsTable courseVersions = $CourseVersionsTable(this);
  late final $CourseTeachersTable courseTeachers = $CourseTeachersTable(this);
  late final $CourseMeetingsTable courseMeetings = $CourseMeetingsTable(this);
  late final $MeetingWeeksTable meetingWeeks = $MeetingWeeksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    schedules,
    courses,
    courseVersions,
    courseTeachers,
    courseMeetings,
    meetingWeeks,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'schedules',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('courses', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'courses',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('course_versions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'course_versions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('course_teachers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'course_versions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('course_meetings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'course_meetings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('meeting_weeks', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SchedulesTableCreateCompanionBuilder =
    SchedulesCompanion Function({
      Value<int> id,
      required String displayName,
      required String firstMonday,
      required int configuredWeekCount,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$SchedulesTableUpdateCompanionBuilder =
    SchedulesCompanion Function({
      Value<int> id,
      Value<String> displayName,
      Value<String> firstMonday,
      Value<int> configuredWeekCount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$SchedulesTableReferences
    extends BaseReferences<_$AppDatabase, $SchedulesTable, ScheduleRow> {
  $$SchedulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CoursesTable, List<CourseRow>> _coursesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.courses,
    aliasName: 'schedules__id__courses__schedule_id',
  );

  $$CoursesTableProcessedTableManager get coursesRefs {
    final manager = $$CoursesTableTableManager(
      $_db,
      $_db.courses,
    ).filter((f) => f.scheduleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_coursesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstMonday => $composableBuilder(
    column: $table.firstMonday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get configuredWeekCount => $composableBuilder(
    column: $table.configuredWeekCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> coursesRefs(
    Expression<bool> Function($$CoursesTableFilterComposer f) f,
  ) {
    final $$CoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.scheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableFilterComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstMonday => $composableBuilder(
    column: $table.firstMonday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get configuredWeekCount => $composableBuilder(
    column: $table.configuredWeekCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firstMonday => $composableBuilder(
    column: $table.firstMonday,
    builder: (column) => column,
  );

  GeneratedColumn<int> get configuredWeekCount => $composableBuilder(
    column: $table.configuredWeekCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> coursesRefs<T extends Object>(
    Expression<T> Function($$CoursesTableAnnotationComposer a) f,
  ) {
    final $$CoursesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.scheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableAnnotationComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchedulesTable,
          ScheduleRow,
          $$SchedulesTableFilterComposer,
          $$SchedulesTableOrderingComposer,
          $$SchedulesTableAnnotationComposer,
          $$SchedulesTableCreateCompanionBuilder,
          $$SchedulesTableUpdateCompanionBuilder,
          (ScheduleRow, $$SchedulesTableReferences),
          ScheduleRow,
          PrefetchHooks Function({bool coursesRefs})
        > {
  $$SchedulesTableTableManager(_$AppDatabase db, $SchedulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> firstMonday = const Value.absent(),
                Value<int> configuredWeekCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SchedulesCompanion(
                id: id,
                displayName: displayName,
                firstMonday: firstMonday,
                configuredWeekCount: configuredWeekCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String displayName,
                required String firstMonday,
                required int configuredWeekCount,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => SchedulesCompanion.insert(
                id: id,
                displayName: displayName,
                firstMonday: firstMonday,
                configuredWeekCount: configuredWeekCount,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({coursesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (coursesRefs) db.courses],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (coursesRefs)
                    await $_getPrefetchedData<
                      ScheduleRow,
                      $SchedulesTable,
                      CourseRow
                    >(
                      currentTable: table,
                      referencedTable: $$SchedulesTableReferences
                          ._coursesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SchedulesTableReferences(db, table, p0).coursesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.scheduleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchedulesTable,
      ScheduleRow,
      $$SchedulesTableFilterComposer,
      $$SchedulesTableOrderingComposer,
      $$SchedulesTableAnnotationComposer,
      $$SchedulesTableCreateCompanionBuilder,
      $$SchedulesTableUpdateCompanionBuilder,
      (ScheduleRow, $$SchedulesTableReferences),
      ScheduleRow,
      PrefetchHooks Function({bool coursesRefs})
    >;
typedef $$CoursesTableCreateCompanionBuilder =
    CoursesCompanion Function({
      Value<int> id,
      required int scheduleId,
      required int origin,
      Value<String?> importKey,
      Value<String?> courseCode,
      Value<String?> sequence,
      Value<bool> sourcePresent,
      Value<String?> courseDetailLink,
      Value<String?> teachingRecordLink,
      Value<String?> processScoreLink,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$CoursesTableUpdateCompanionBuilder =
    CoursesCompanion Function({
      Value<int> id,
      Value<int> scheduleId,
      Value<int> origin,
      Value<String?> importKey,
      Value<String?> courseCode,
      Value<String?> sequence,
      Value<bool> sourcePresent,
      Value<String?> courseDetailLink,
      Value<String?> teachingRecordLink,
      Value<String?> processScoreLink,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$CoursesTableReferences
    extends BaseReferences<_$AppDatabase, $CoursesTable, CourseRow> {
  $$CoursesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SchedulesTable _scheduleIdTable(_$AppDatabase db) =>
      db.schedules.createAlias('courses__schedule_id__schedules__id');

  $$SchedulesTableProcessedTableManager get scheduleId {
    final $_column = $_itemColumn<int>('schedule_id')!;

    final manager = $$SchedulesTableTableManager(
      $_db,
      $_db.schedules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CourseVersionsTable, List<CourseVersionRow>>
  _courseVersionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.courseVersions,
    aliasName: 'courses__id__course_versions__course_id',
  );

  $$CourseVersionsTableProcessedTableManager get courseVersionsRefs {
    final manager = $$CourseVersionsTableTableManager(
      $_db,
      $_db.courseVersions,
    ).filter((f) => f.courseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_courseVersionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CoursesTableFilterComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importKey => $composableBuilder(
    column: $table.importKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseCode => $composableBuilder(
    column: $table.courseCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sourcePresent => $composableBuilder(
    column: $table.sourcePresent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseDetailLink => $composableBuilder(
    column: $table.courseDetailLink,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teachingRecordLink => $composableBuilder(
    column: $table.teachingRecordLink,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get processScoreLink => $composableBuilder(
    column: $table.processScoreLink,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SchedulesTableFilterComposer get scheduleId {
    final $$SchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleId,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableFilterComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> courseVersionsRefs(
    Expression<bool> Function($$CourseVersionsTableFilterComposer f) f,
  ) {
    final $$CourseVersionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseVersions,
      getReferencedColumn: (t) => t.courseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseVersionsTableFilterComposer(
            $db: $db,
            $table: $db.courseVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CoursesTableOrderingComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importKey => $composableBuilder(
    column: $table.importKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseCode => $composableBuilder(
    column: $table.courseCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sourcePresent => $composableBuilder(
    column: $table.sourcePresent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseDetailLink => $composableBuilder(
    column: $table.courseDetailLink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teachingRecordLink => $composableBuilder(
    column: $table.teachingRecordLink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get processScoreLink => $composableBuilder(
    column: $table.processScoreLink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SchedulesTableOrderingComposer get scheduleId {
    final $$SchedulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleId,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableOrderingComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoursesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get importKey =>
      $composableBuilder(column: $table.importKey, builder: (column) => column);

  GeneratedColumn<String> get courseCode => $composableBuilder(
    column: $table.courseCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<bool> get sourcePresent => $composableBuilder(
    column: $table.sourcePresent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get courseDetailLink => $composableBuilder(
    column: $table.courseDetailLink,
    builder: (column) => column,
  );

  GeneratedColumn<String> get teachingRecordLink => $composableBuilder(
    column: $table.teachingRecordLink,
    builder: (column) => column,
  );

  GeneratedColumn<String> get processScoreLink => $composableBuilder(
    column: $table.processScoreLink,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SchedulesTableAnnotationComposer get scheduleId {
    final $$SchedulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleId,
      referencedTable: $db.schedules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulesTableAnnotationComposer(
            $db: $db,
            $table: $db.schedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> courseVersionsRefs<T extends Object>(
    Expression<T> Function($$CourseVersionsTableAnnotationComposer a) f,
  ) {
    final $$CourseVersionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseVersions,
      getReferencedColumn: (t) => t.courseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseVersionsTableAnnotationComposer(
            $db: $db,
            $table: $db.courseVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CoursesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoursesTable,
          CourseRow,
          $$CoursesTableFilterComposer,
          $$CoursesTableOrderingComposer,
          $$CoursesTableAnnotationComposer,
          $$CoursesTableCreateCompanionBuilder,
          $$CoursesTableUpdateCompanionBuilder,
          (CourseRow, $$CoursesTableReferences),
          CourseRow,
          PrefetchHooks Function({bool scheduleId, bool courseVersionsRefs})
        > {
  $$CoursesTableTableManager(_$AppDatabase db, $CoursesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoursesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> scheduleId = const Value.absent(),
                Value<int> origin = const Value.absent(),
                Value<String?> importKey = const Value.absent(),
                Value<String?> courseCode = const Value.absent(),
                Value<String?> sequence = const Value.absent(),
                Value<bool> sourcePresent = const Value.absent(),
                Value<String?> courseDetailLink = const Value.absent(),
                Value<String?> teachingRecordLink = const Value.absent(),
                Value<String?> processScoreLink = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CoursesCompanion(
                id: id,
                scheduleId: scheduleId,
                origin: origin,
                importKey: importKey,
                courseCode: courseCode,
                sequence: sequence,
                sourcePresent: sourcePresent,
                courseDetailLink: courseDetailLink,
                teachingRecordLink: teachingRecordLink,
                processScoreLink: processScoreLink,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int scheduleId,
                required int origin,
                Value<String?> importKey = const Value.absent(),
                Value<String?> courseCode = const Value.absent(),
                Value<String?> sequence = const Value.absent(),
                Value<bool> sourcePresent = const Value.absent(),
                Value<String?> courseDetailLink = const Value.absent(),
                Value<String?> teachingRecordLink = const Value.absent(),
                Value<String?> processScoreLink = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => CoursesCompanion.insert(
                id: id,
                scheduleId: scheduleId,
                origin: origin,
                importKey: importKey,
                courseCode: courseCode,
                sequence: sequence,
                sourcePresent: sourcePresent,
                courseDetailLink: courseDetailLink,
                teachingRecordLink: teachingRecordLink,
                processScoreLink: processScoreLink,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CoursesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({scheduleId = false, courseVersionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (courseVersionsRefs) db.courseVersions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (scheduleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.scheduleId,
                                    referencedTable: $$CoursesTableReferences
                                        ._scheduleIdTable(db),
                                    referencedColumn: $$CoursesTableReferences
                                        ._scheduleIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (courseVersionsRefs)
                        await $_getPrefetchedData<
                          CourseRow,
                          $CoursesTable,
                          CourseVersionRow
                        >(
                          currentTable: table,
                          referencedTable: $$CoursesTableReferences
                              ._courseVersionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CoursesTableReferences(
                                db,
                                table,
                                p0,
                              ).courseVersionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.courseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CoursesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoursesTable,
      CourseRow,
      $$CoursesTableFilterComposer,
      $$CoursesTableOrderingComposer,
      $$CoursesTableAnnotationComposer,
      $$CoursesTableCreateCompanionBuilder,
      $$CoursesTableUpdateCompanionBuilder,
      (CourseRow, $$CoursesTableReferences),
      CourseRow,
      PrefetchHooks Function({bool scheduleId, bool courseVersionsRefs})
    >;
typedef $$CourseVersionsTableCreateCompanionBuilder =
    CourseVersionsCompanion Function({
      Value<int> id,
      required int courseId,
      required int kind,
      Value<bool> isDeleted,
      required String name,
      Value<String> credits,
      Value<String> selectionType,
      Value<String> assessment,
      Value<String> examNature,
      Value<String> deferredExam,
      Value<String> material,
      required DateTime updatedAt,
    });
typedef $$CourseVersionsTableUpdateCompanionBuilder =
    CourseVersionsCompanion Function({
      Value<int> id,
      Value<int> courseId,
      Value<int> kind,
      Value<bool> isDeleted,
      Value<String> name,
      Value<String> credits,
      Value<String> selectionType,
      Value<String> assessment,
      Value<String> examNature,
      Value<String> deferredExam,
      Value<String> material,
      Value<DateTime> updatedAt,
    });

final class $$CourseVersionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CourseVersionsTable, CourseVersionRow> {
  $$CourseVersionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CoursesTable _courseIdTable(_$AppDatabase db) =>
      db.courses.createAlias('course_versions__course_id__courses__id');

  $$CoursesTableProcessedTableManager get courseId {
    final $_column = $_itemColumn<int>('course_id')!;

    final manager = $$CoursesTableTableManager(
      $_db,
      $_db.courses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_courseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CourseTeachersTable, List<CourseTeacherRow>>
  _courseTeachersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.courseTeachers,
    aliasName: 'course_versions__id__course_teachers__version_id',
  );

  $$CourseTeachersTableProcessedTableManager get courseTeachersRefs {
    final manager = $$CourseTeachersTableTableManager(
      $_db,
      $_db.courseTeachers,
    ).filter((f) => f.versionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_courseTeachersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CourseMeetingsTable, List<CourseMeetingRow>>
  _courseMeetingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.courseMeetings,
    aliasName: 'course_versions__id__course_meetings__version_id',
  );

  $$CourseMeetingsTableProcessedTableManager get courseMeetingsRefs {
    final manager = $$CourseMeetingsTableTableManager(
      $_db,
      $_db.courseMeetings,
    ).filter((f) => f.versionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_courseMeetingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CourseVersionsTableFilterComposer
    extends Composer<_$AppDatabase, $CourseVersionsTable> {
  $$CourseVersionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectionType => $composableBuilder(
    column: $table.selectionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assessment => $composableBuilder(
    column: $table.assessment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examNature => $composableBuilder(
    column: $table.examNature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deferredExam => $composableBuilder(
    column: $table.deferredExam,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CoursesTableFilterComposer get courseId {
    final $$CoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableFilterComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> courseTeachersRefs(
    Expression<bool> Function($$CourseTeachersTableFilterComposer f) f,
  ) {
    final $$CourseTeachersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseTeachers,
      getReferencedColumn: (t) => t.versionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseTeachersTableFilterComposer(
            $db: $db,
            $table: $db.courseTeachers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> courseMeetingsRefs(
    Expression<bool> Function($$CourseMeetingsTableFilterComposer f) f,
  ) {
    final $$CourseMeetingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseMeetings,
      getReferencedColumn: (t) => t.versionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseMeetingsTableFilterComposer(
            $db: $db,
            $table: $db.courseMeetings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CourseVersionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseVersionsTable> {
  $$CourseVersionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectionType => $composableBuilder(
    column: $table.selectionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assessment => $composableBuilder(
    column: $table.assessment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examNature => $composableBuilder(
    column: $table.examNature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deferredExam => $composableBuilder(
    column: $table.deferredExam,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CoursesTableOrderingComposer get courseId {
    final $$CoursesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableOrderingComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CourseVersionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseVersionsTable> {
  $$CourseVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get credits =>
      $composableBuilder(column: $table.credits, builder: (column) => column);

  GeneratedColumn<String> get selectionType => $composableBuilder(
    column: $table.selectionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assessment => $composableBuilder(
    column: $table.assessment,
    builder: (column) => column,
  );

  GeneratedColumn<String> get examNature => $composableBuilder(
    column: $table.examNature,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deferredExam => $composableBuilder(
    column: $table.deferredExam,
    builder: (column) => column,
  );

  GeneratedColumn<String> get material =>
      $composableBuilder(column: $table.material, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CoursesTableAnnotationComposer get courseId {
    final $$CoursesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableAnnotationComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> courseTeachersRefs<T extends Object>(
    Expression<T> Function($$CourseTeachersTableAnnotationComposer a) f,
  ) {
    final $$CourseTeachersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseTeachers,
      getReferencedColumn: (t) => t.versionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseTeachersTableAnnotationComposer(
            $db: $db,
            $table: $db.courseTeachers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> courseMeetingsRefs<T extends Object>(
    Expression<T> Function($$CourseMeetingsTableAnnotationComposer a) f,
  ) {
    final $$CourseMeetingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courseMeetings,
      getReferencedColumn: (t) => t.versionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseMeetingsTableAnnotationComposer(
            $db: $db,
            $table: $db.courseMeetings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CourseVersionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourseVersionsTable,
          CourseVersionRow,
          $$CourseVersionsTableFilterComposer,
          $$CourseVersionsTableOrderingComposer,
          $$CourseVersionsTableAnnotationComposer,
          $$CourseVersionsTableCreateCompanionBuilder,
          $$CourseVersionsTableUpdateCompanionBuilder,
          (CourseVersionRow, $$CourseVersionsTableReferences),
          CourseVersionRow,
          PrefetchHooks Function({
            bool courseId,
            bool courseTeachersRefs,
            bool courseMeetingsRefs,
          })
        > {
  $$CourseVersionsTableTableManager(
    _$AppDatabase db,
    $CourseVersionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourseVersionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CourseVersionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> courseId = const Value.absent(),
                Value<int> kind = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> credits = const Value.absent(),
                Value<String> selectionType = const Value.absent(),
                Value<String> assessment = const Value.absent(),
                Value<String> examNature = const Value.absent(),
                Value<String> deferredExam = const Value.absent(),
                Value<String> material = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CourseVersionsCompanion(
                id: id,
                courseId: courseId,
                kind: kind,
                isDeleted: isDeleted,
                name: name,
                credits: credits,
                selectionType: selectionType,
                assessment: assessment,
                examNature: examNature,
                deferredExam: deferredExam,
                material: material,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int courseId,
                required int kind,
                Value<bool> isDeleted = const Value.absent(),
                required String name,
                Value<String> credits = const Value.absent(),
                Value<String> selectionType = const Value.absent(),
                Value<String> assessment = const Value.absent(),
                Value<String> examNature = const Value.absent(),
                Value<String> deferredExam = const Value.absent(),
                Value<String> material = const Value.absent(),
                required DateTime updatedAt,
              }) => CourseVersionsCompanion.insert(
                id: id,
                courseId: courseId,
                kind: kind,
                isDeleted: isDeleted,
                name: name,
                credits: credits,
                selectionType: selectionType,
                assessment: assessment,
                examNature: examNature,
                deferredExam: deferredExam,
                material: material,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CourseVersionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                courseId = false,
                courseTeachersRefs = false,
                courseMeetingsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (courseTeachersRefs) db.courseTeachers,
                    if (courseMeetingsRefs) db.courseMeetings,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (courseId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.courseId,
                                    referencedTable:
                                        $$CourseVersionsTableReferences
                                            ._courseIdTable(db),
                                    referencedColumn:
                                        $$CourseVersionsTableReferences
                                            ._courseIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (courseTeachersRefs)
                        await $_getPrefetchedData<
                          CourseVersionRow,
                          $CourseVersionsTable,
                          CourseTeacherRow
                        >(
                          currentTable: table,
                          referencedTable: $$CourseVersionsTableReferences
                              ._courseTeachersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CourseVersionsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseTeachersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.versionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (courseMeetingsRefs)
                        await $_getPrefetchedData<
                          CourseVersionRow,
                          $CourseVersionsTable,
                          CourseMeetingRow
                        >(
                          currentTable: table,
                          referencedTable: $$CourseVersionsTableReferences
                              ._courseMeetingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CourseVersionsTableReferences(
                                db,
                                table,
                                p0,
                              ).courseMeetingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.versionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CourseVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourseVersionsTable,
      CourseVersionRow,
      $$CourseVersionsTableFilterComposer,
      $$CourseVersionsTableOrderingComposer,
      $$CourseVersionsTableAnnotationComposer,
      $$CourseVersionsTableCreateCompanionBuilder,
      $$CourseVersionsTableUpdateCompanionBuilder,
      (CourseVersionRow, $$CourseVersionsTableReferences),
      CourseVersionRow,
      PrefetchHooks Function({
        bool courseId,
        bool courseTeachersRefs,
        bool courseMeetingsRefs,
      })
    >;
typedef $$CourseTeachersTableCreateCompanionBuilder =
    CourseTeachersCompanion Function({
      required int versionId,
      required int position,
      required String name,
      Value<int> rowid,
    });
typedef $$CourseTeachersTableUpdateCompanionBuilder =
    CourseTeachersCompanion Function({
      Value<int> versionId,
      Value<int> position,
      Value<String> name,
      Value<int> rowid,
    });

final class $$CourseTeachersTableReferences
    extends
        BaseReferences<_$AppDatabase, $CourseTeachersTable, CourseTeacherRow> {
  $$CourseTeachersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CourseVersionsTable _versionIdTable(_$AppDatabase db) => db
      .courseVersions
      .createAlias('course_teachers__version_id__course_versions__id');

  $$CourseVersionsTableProcessedTableManager get versionId {
    final $_column = $_itemColumn<int>('version_id')!;

    final manager = $$CourseVersionsTableTableManager(
      $_db,
      $_db.courseVersions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_versionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CourseTeachersTableFilterComposer
    extends Composer<_$AppDatabase, $CourseTeachersTable> {
  $$CourseTeachersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$CourseVersionsTableFilterComposer get versionId {
    final $$CourseVersionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.courseVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseVersionsTableFilterComposer(
            $db: $db,
            $table: $db.courseVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CourseTeachersTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseTeachersTable> {
  $$CourseTeachersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$CourseVersionsTableOrderingComposer get versionId {
    final $$CourseVersionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.courseVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseVersionsTableOrderingComposer(
            $db: $db,
            $table: $db.courseVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CourseTeachersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseTeachersTable> {
  $$CourseTeachersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$CourseVersionsTableAnnotationComposer get versionId {
    final $$CourseVersionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.courseVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseVersionsTableAnnotationComposer(
            $db: $db,
            $table: $db.courseVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CourseTeachersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourseTeachersTable,
          CourseTeacherRow,
          $$CourseTeachersTableFilterComposer,
          $$CourseTeachersTableOrderingComposer,
          $$CourseTeachersTableAnnotationComposer,
          $$CourseTeachersTableCreateCompanionBuilder,
          $$CourseTeachersTableUpdateCompanionBuilder,
          (CourseTeacherRow, $$CourseTeachersTableReferences),
          CourseTeacherRow,
          PrefetchHooks Function({bool versionId})
        > {
  $$CourseTeachersTableTableManager(
    _$AppDatabase db,
    $CourseTeachersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseTeachersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourseTeachersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CourseTeachersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> versionId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CourseTeachersCompanion(
                versionId: versionId,
                position: position,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int versionId,
                required int position,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => CourseTeachersCompanion.insert(
                versionId: versionId,
                position: position,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CourseTeachersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({versionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (versionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.versionId,
                                referencedTable: $$CourseTeachersTableReferences
                                    ._versionIdTable(db),
                                referencedColumn:
                                    $$CourseTeachersTableReferences
                                        ._versionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CourseTeachersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourseTeachersTable,
      CourseTeacherRow,
      $$CourseTeachersTableFilterComposer,
      $$CourseTeachersTableOrderingComposer,
      $$CourseTeachersTableAnnotationComposer,
      $$CourseTeachersTableCreateCompanionBuilder,
      $$CourseTeachersTableUpdateCompanionBuilder,
      (CourseTeacherRow, $$CourseTeachersTableReferences),
      CourseTeacherRow,
      PrefetchHooks Function({bool versionId})
    >;
typedef $$CourseMeetingsTableCreateCompanionBuilder =
    CourseMeetingsCompanion Function({
      Value<int> id,
      required int versionId,
      required int position,
      required int weekday,
      required int startSection,
      required int endSection,
      Value<String> location,
    });
typedef $$CourseMeetingsTableUpdateCompanionBuilder =
    CourseMeetingsCompanion Function({
      Value<int> id,
      Value<int> versionId,
      Value<int> position,
      Value<int> weekday,
      Value<int> startSection,
      Value<int> endSection,
      Value<String> location,
    });

final class $$CourseMeetingsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CourseMeetingsTable, CourseMeetingRow> {
  $$CourseMeetingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CourseVersionsTable _versionIdTable(_$AppDatabase db) => db
      .courseVersions
      .createAlias('course_meetings__version_id__course_versions__id');

  $$CourseVersionsTableProcessedTableManager get versionId {
    final $_column = $_itemColumn<int>('version_id')!;

    final manager = $$CourseVersionsTableTableManager(
      $_db,
      $_db.courseVersions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_versionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MeetingWeeksTable, List<MeetingWeekRow>>
  _meetingWeeksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.meetingWeeks,
    aliasName: 'course_meetings__id__meeting_weeks__meeting_id',
  );

  $$MeetingWeeksTableProcessedTableManager get meetingWeeksRefs {
    final manager = $$MeetingWeeksTableTableManager(
      $_db,
      $_db.meetingWeeks,
    ).filter((f) => f.meetingId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_meetingWeeksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CourseMeetingsTableFilterComposer
    extends Composer<_$AppDatabase, $CourseMeetingsTable> {
  $$CourseMeetingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startSection => $composableBuilder(
    column: $table.startSection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endSection => $composableBuilder(
    column: $table.endSection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  $$CourseVersionsTableFilterComposer get versionId {
    final $$CourseVersionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.courseVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseVersionsTableFilterComposer(
            $db: $db,
            $table: $db.courseVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> meetingWeeksRefs(
    Expression<bool> Function($$MeetingWeeksTableFilterComposer f) f,
  ) {
    final $$MeetingWeeksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.meetingWeeks,
      getReferencedColumn: (t) => t.meetingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeetingWeeksTableFilterComposer(
            $db: $db,
            $table: $db.meetingWeeks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CourseMeetingsTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseMeetingsTable> {
  $$CourseMeetingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startSection => $composableBuilder(
    column: $table.startSection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endSection => $composableBuilder(
    column: $table.endSection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  $$CourseVersionsTableOrderingComposer get versionId {
    final $$CourseVersionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.courseVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseVersionsTableOrderingComposer(
            $db: $db,
            $table: $db.courseVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CourseMeetingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseMeetingsTable> {
  $$CourseMeetingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<int> get startSection => $composableBuilder(
    column: $table.startSection,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endSection => $composableBuilder(
    column: $table.endSection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  $$CourseVersionsTableAnnotationComposer get versionId {
    final $$CourseVersionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.versionId,
      referencedTable: $db.courseVersions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseVersionsTableAnnotationComposer(
            $db: $db,
            $table: $db.courseVersions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> meetingWeeksRefs<T extends Object>(
    Expression<T> Function($$MeetingWeeksTableAnnotationComposer a) f,
  ) {
    final $$MeetingWeeksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.meetingWeeks,
      getReferencedColumn: (t) => t.meetingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeetingWeeksTableAnnotationComposer(
            $db: $db,
            $table: $db.meetingWeeks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CourseMeetingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourseMeetingsTable,
          CourseMeetingRow,
          $$CourseMeetingsTableFilterComposer,
          $$CourseMeetingsTableOrderingComposer,
          $$CourseMeetingsTableAnnotationComposer,
          $$CourseMeetingsTableCreateCompanionBuilder,
          $$CourseMeetingsTableUpdateCompanionBuilder,
          (CourseMeetingRow, $$CourseMeetingsTableReferences),
          CourseMeetingRow,
          PrefetchHooks Function({bool versionId, bool meetingWeeksRefs})
        > {
  $$CourseMeetingsTableTableManager(
    _$AppDatabase db,
    $CourseMeetingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseMeetingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourseMeetingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CourseMeetingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> versionId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> weekday = const Value.absent(),
                Value<int> startSection = const Value.absent(),
                Value<int> endSection = const Value.absent(),
                Value<String> location = const Value.absent(),
              }) => CourseMeetingsCompanion(
                id: id,
                versionId: versionId,
                position: position,
                weekday: weekday,
                startSection: startSection,
                endSection: endSection,
                location: location,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int versionId,
                required int position,
                required int weekday,
                required int startSection,
                required int endSection,
                Value<String> location = const Value.absent(),
              }) => CourseMeetingsCompanion.insert(
                id: id,
                versionId: versionId,
                position: position,
                weekday: weekday,
                startSection: startSection,
                endSection: endSection,
                location: location,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CourseMeetingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({versionId = false, meetingWeeksRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (meetingWeeksRefs) db.meetingWeeks,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (versionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.versionId,
                                    referencedTable:
                                        $$CourseMeetingsTableReferences
                                            ._versionIdTable(db),
                                    referencedColumn:
                                        $$CourseMeetingsTableReferences
                                            ._versionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (meetingWeeksRefs)
                        await $_getPrefetchedData<
                          CourseMeetingRow,
                          $CourseMeetingsTable,
                          MeetingWeekRow
                        >(
                          currentTable: table,
                          referencedTable: $$CourseMeetingsTableReferences
                              ._meetingWeeksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CourseMeetingsTableReferences(
                                db,
                                table,
                                p0,
                              ).meetingWeeksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.meetingId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CourseMeetingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourseMeetingsTable,
      CourseMeetingRow,
      $$CourseMeetingsTableFilterComposer,
      $$CourseMeetingsTableOrderingComposer,
      $$CourseMeetingsTableAnnotationComposer,
      $$CourseMeetingsTableCreateCompanionBuilder,
      $$CourseMeetingsTableUpdateCompanionBuilder,
      (CourseMeetingRow, $$CourseMeetingsTableReferences),
      CourseMeetingRow,
      PrefetchHooks Function({bool versionId, bool meetingWeeksRefs})
    >;
typedef $$MeetingWeeksTableCreateCompanionBuilder =
    MeetingWeeksCompanion Function({
      required int meetingId,
      required int week,
      Value<int> rowid,
    });
typedef $$MeetingWeeksTableUpdateCompanionBuilder =
    MeetingWeeksCompanion Function({
      Value<int> meetingId,
      Value<int> week,
      Value<int> rowid,
    });

final class $$MeetingWeeksTableReferences
    extends BaseReferences<_$AppDatabase, $MeetingWeeksTable, MeetingWeekRow> {
  $$MeetingWeeksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CourseMeetingsTable _meetingIdTable(_$AppDatabase db) => db
      .courseMeetings
      .createAlias('meeting_weeks__meeting_id__course_meetings__id');

  $$CourseMeetingsTableProcessedTableManager get meetingId {
    final $_column = $_itemColumn<int>('meeting_id')!;

    final manager = $$CourseMeetingsTableTableManager(
      $_db,
      $_db.courseMeetings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_meetingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MeetingWeeksTableFilterComposer
    extends Composer<_$AppDatabase, $MeetingWeeksTable> {
  $$MeetingWeeksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get week => $composableBuilder(
    column: $table.week,
    builder: (column) => ColumnFilters(column),
  );

  $$CourseMeetingsTableFilterComposer get meetingId {
    final $$CourseMeetingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.meetingId,
      referencedTable: $db.courseMeetings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseMeetingsTableFilterComposer(
            $db: $db,
            $table: $db.courseMeetings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeetingWeeksTableOrderingComposer
    extends Composer<_$AppDatabase, $MeetingWeeksTable> {
  $$MeetingWeeksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get week => $composableBuilder(
    column: $table.week,
    builder: (column) => ColumnOrderings(column),
  );

  $$CourseMeetingsTableOrderingComposer get meetingId {
    final $$CourseMeetingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.meetingId,
      referencedTable: $db.courseMeetings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseMeetingsTableOrderingComposer(
            $db: $db,
            $table: $db.courseMeetings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeetingWeeksTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeetingWeeksTable> {
  $$MeetingWeeksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get week =>
      $composableBuilder(column: $table.week, builder: (column) => column);

  $$CourseMeetingsTableAnnotationComposer get meetingId {
    final $$CourseMeetingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.meetingId,
      referencedTable: $db.courseMeetings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CourseMeetingsTableAnnotationComposer(
            $db: $db,
            $table: $db.courseMeetings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeetingWeeksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeetingWeeksTable,
          MeetingWeekRow,
          $$MeetingWeeksTableFilterComposer,
          $$MeetingWeeksTableOrderingComposer,
          $$MeetingWeeksTableAnnotationComposer,
          $$MeetingWeeksTableCreateCompanionBuilder,
          $$MeetingWeeksTableUpdateCompanionBuilder,
          (MeetingWeekRow, $$MeetingWeeksTableReferences),
          MeetingWeekRow,
          PrefetchHooks Function({bool meetingId})
        > {
  $$MeetingWeeksTableTableManager(_$AppDatabase db, $MeetingWeeksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeetingWeeksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeetingWeeksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeetingWeeksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> meetingId = const Value.absent(),
                Value<int> week = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeetingWeeksCompanion(
                meetingId: meetingId,
                week: week,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int meetingId,
                required int week,
                Value<int> rowid = const Value.absent(),
              }) => MeetingWeeksCompanion.insert(
                meetingId: meetingId,
                week: week,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MeetingWeeksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({meetingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (meetingId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.meetingId,
                                referencedTable: $$MeetingWeeksTableReferences
                                    ._meetingIdTable(db),
                                referencedColumn: $$MeetingWeeksTableReferences
                                    ._meetingIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MeetingWeeksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeetingWeeksTable,
      MeetingWeekRow,
      $$MeetingWeeksTableFilterComposer,
      $$MeetingWeeksTableOrderingComposer,
      $$MeetingWeeksTableAnnotationComposer,
      $$MeetingWeeksTableCreateCompanionBuilder,
      $$MeetingWeeksTableUpdateCompanionBuilder,
      (MeetingWeekRow, $$MeetingWeeksTableReferences),
      MeetingWeekRow,
      PrefetchHooks Function({bool meetingId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db, _db.schedules);
  $$CoursesTableTableManager get courses =>
      $$CoursesTableTableManager(_db, _db.courses);
  $$CourseVersionsTableTableManager get courseVersions =>
      $$CourseVersionsTableTableManager(_db, _db.courseVersions);
  $$CourseTeachersTableTableManager get courseTeachers =>
      $$CourseTeachersTableTableManager(_db, _db.courseTeachers);
  $$CourseMeetingsTableTableManager get courseMeetings =>
      $$CourseMeetingsTableTableManager(_db, _db.courseMeetings);
  $$MeetingWeeksTableTableManager get meetingWeeks =>
      $$MeetingWeeksTableTableManager(_db, _db.meetingWeeks);
}
