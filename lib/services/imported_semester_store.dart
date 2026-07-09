import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/schedule_models.dart';
import 'semester_importer.dart';

class DuplicateSemesterNameException implements Exception {
  const DuplicateSemesterNameException(this.displayName);

  final String displayName;

  @override
  String toString() => '课表名称已存在，请修改名称';
}

class ImportedSemesterRecord {
  const ImportedSemesterRecord({
    required this.id,
    required this.displayName,
    required this.termStartDate,
    required this.courseHtml,
    required this.createdAt,
  });

  final String id;
  final String displayName;
  final DateTime termStartDate;
  final String courseHtml;
  final DateTime createdAt;

  Semester toSemester() {
    return SemesterImporter.parseCourseHtml(
      semesterId: id,
      displayName: displayName,
      termStartDate: termStartDate,
      courseHtml: courseHtml,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'displayName': displayName,
    'termStartDate': _formatDate(termStartDate),
    'courseHtml': courseHtml,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ImportedSemesterRecord.fromJson(Map<String, Object?> json) {
    return ImportedSemesterRecord(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      termStartDate: DateTime.parse(json['termStartDate'] as String),
      courseHtml: json['courseHtml'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
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
    return items
        .map((item) => jsonDecode(item) as Map<String, Object?>)
        .map(ImportedSemesterRecord.fromJson)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<List<Semester>> loadSemesters() async {
    final records = await loadRecords();
    return records.map((record) => record.toSemester()).toList();
  }

  Future<ImportedSemesterRecord> addRecord({
    required String displayName,
    required DateTime termStartDate,
    required String courseHtml,
    required Iterable<String> existingDisplayNames,
  }) async {
    final normalizedName = displayName.trim();
    if (normalizedName.isEmpty) {
      throw const FormatException('请输入课表名称');
    }
    final records = await loadRecords();
    final names = {
      for (final name in existingDisplayNames) name.trim(),
      for (final record in records) record.displayName.trim(),
    };
    if (names.contains(normalizedName)) {
      throw DuplicateSemesterNameException(normalizedName);
    }

    final now = DateTime.now();
    final record = ImportedSemesterRecord(
      id: 'imported-${now.microsecondsSinceEpoch}',
      displayName: normalizedName,
      termStartDate: termStartDate,
      courseHtml: courseHtml,
      createdAt: now,
    );
    await _writeRecords([...records, record]);
    return record;
  }

  Future<void> _writeRecords(List<ImportedSemesterRecord> records) async {
    final preferences = await _preferencesFuture;
    await preferences.setStringList(
      _recordsKey,
      records.map((record) => jsonEncode(record.toJson())).toList(),
    );
  }
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
