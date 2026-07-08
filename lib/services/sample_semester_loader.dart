import 'package:flutter/services.dart';

import '../models/schedule_models.dart';
import 'semester_importer.dart';

class SampleSemesterLoader {
  const SampleSemesterLoader();

  Future<List<Semester>> load() async {
    final courseHtml = await rootBundle.loadString(
      'assets/raw/2025-2026-2-courses.html',
    );
    final periodHtml = await rootBundle.loadString('assets/raw/periods.html');
    return [
      SemesterImporter.parseFromHtml(
        semesterId: '2025-2026-2',
        displayName: '2025-2026-2学期',
        termStartDate: null,
        courseHtml: courseHtml,
        periodHtml: periodHtml,
      ),
    ];
  }
}
