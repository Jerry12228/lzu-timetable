import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/schedule_models.dart';
import 'semester_importer.dart';
import 'semester_json_codec.dart';

class DuplicateSemesterNameException implements Exception {
  const DuplicateSemesterNameException(this.displayName);

  final String displayName;

  @override
  String toString() => '课表名称已存在，请修改名称';
}

class ImportedSemesterRecord {
  const ImportedSemesterRecord({
    required this.semester,
    required this.createdAt,
  });

  final Semester semester;
  final DateTime createdAt;

  String get id => semester.id;
  String get displayName => semester.displayName;
  DateTime get termStartDate => semester.termStartDate!;

  Semester toSemester() => semester;

  Map<String, Object?> toJson() => {
    'semester': SemesterJsonCodec.toJson(semester),
    'createdAt': createdAt.toIso8601String(),
  };

  factory ImportedSemesterRecord.fromJson(Map<String, Object?> json) {
    return ImportedSemesterRecord(
      semester: SemesterJsonCodec.fromJson(_object(json['semester'])),
      createdAt: DateTime.parse(_string(json, 'createdAt')),
    );
  }

  factory ImportedSemesterRecord.fromLegacyHtmlJson(Map<String, Object?> json) {
    final semester = SemesterImporter.parseCourseHtml(
      semesterId: _string(json, 'id'),
      displayName: _string(json, 'displayName'),
      termStartDate: DateTime.parse(_string(json, 'termStartDate')),
      courseHtml: _string(json, 'courseHtml'),
    );
    return ImportedSemesterRecord(
      semester: semester,
      createdAt: DateTime.parse(_string(json, 'createdAt')),
    );
  }
}

class ImportedSemesterStore {
  ImportedSemesterStore({SharedPreferences? preferences})
    : _preferencesFuture = preferences == null
          ? SharedPreferences.getInstance()
          : Future.value(preferences);

  static const _recordsKey = 'course_schedule_imported_semesters_v1';

  final Future<SharedPreferences> _preferencesFuture;

  Future<List<ImportedSemesterRecord>> loadRecords() async {
    final preferences = await _preferencesFuture;
    final items = preferences.getStringList(_recordsKey) ?? const [];
    var requiresMigration = false;
    final records = <ImportedSemesterRecord>[];
    for (final item in items) {
      final json = _object(jsonDecode(item));
      if (json.containsKey('courseHtml')) {
        records.add(ImportedSemesterRecord.fromLegacyHtmlJson(json));
        requiresMigration = true;
      } else {
        records.add(ImportedSemesterRecord.fromJson(json));
        requiresMigration =
            requiresMigration ||
            _containsLegacyWeekRules(json['semester']) ||
            _isMissingWeekCount(json['semester']);
      }
    }
    records.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (requiresMigration) {
      await _writeRecords(records);
    }
    return records;
  }

  Future<List<Semester>> loadSemesters() async {
    final records = await loadRecords();
    return records.map((record) => record.toSemester()).toList();
  }

  Future<ImportedSemesterRecord> addRecord({
    required Semester semester,
    required Iterable<String> existingDisplayNames,
  }) {
    return saveRecord(
      semester: semester,
      existingDisplayNames: existingDisplayNames,
    );
  }

  Future<ImportedSemesterRecord> saveRecord({
    String? semesterId,
    required Semester semester,
    required Iterable<String> existingDisplayNames,
  }) async {
    final normalizedName = semester.displayName.trim();
    if (normalizedName.isEmpty) {
      throw const FormatException('请输入课表名称');
    }
    if (semester.termStartDate == null) {
      throw const FormatException('请输入有效的第一周星期一日期');
    }

    final records = await loadRecords();
    final existingIndex = semesterId == null
        ? -1
        : records.indexWhere((record) => record.id == semesterId);
    final names = {
      for (final name in existingDisplayNames) name.trim(),
      for (final record in records)
        if (record.id != semesterId) record.displayName.trim(),
    };
    if (names.contains(normalizedName)) {
      throw DuplicateSemesterNameException(normalizedName);
    }

    final now = DateTime.now();
    final id = semesterId ?? 'imported-${now.microsecondsSinceEpoch}';
    final record = ImportedSemesterRecord(
      semester: semester.copyWith(id: id, displayName: normalizedName),
      createdAt: existingIndex == -1 ? now : records[existingIndex].createdAt,
    );
    final updatedRecords = [...records];
    if (existingIndex == -1) {
      updatedRecords.add(record);
    } else {
      updatedRecords[existingIndex] = record;
    }
    await _writeRecords(updatedRecords);
    return record;
  }

  Future<void> deleteSemester(String semesterId) async {
    final records = await loadRecords();
    await _writeRecords(
      records.where((record) => record.id != semesterId).toList(),
    );
  }

  Future<void> _writeRecords(List<ImportedSemesterRecord> records) async {
    final preferences = await _preferencesFuture;
    await preferences.setStringList(
      _recordsKey,
      records.map((record) => jsonEncode(record.toJson())).toList(),
    );
  }
}

Map<String, Object?> _object(Object? value) {
  if (value is! Map) {
    throw const FormatException('本地课表数据格式无效');
  }
  try {
    return Map<String, Object?>.from(value);
  } on TypeError {
    throw const FormatException('本地课表数据格式无效');
  }
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String) {
    throw FormatException('本地课表缺少字段：$key');
  }
  return value;
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

bool _isMissingWeekCount(Object? value) {
  if (value is! Map) {
    return false;
  }
  return !value.containsKey('weekCount');
}
