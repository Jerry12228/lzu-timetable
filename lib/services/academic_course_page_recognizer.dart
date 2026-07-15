import 'package:html/parser.dart' as html_parser;

import 'semester_importer.dart';

class AcademicCoursePageCapture {
  const AcademicCoursePageCapture({
    required this.pageUrl,
    required this.html,
    this.selectedYear,
    this.selectedTerm,
  });

  final String pageUrl;
  final String html;
  final String? selectedYear;
  final String? selectedTerm;
}

class AcademicSemesterMetadata {
  const AcademicSemesterMetadata({required this.year, required this.term});

  final String year;
  final String term;

  String get displayName => '$year$term课程表';
}

class RecognizedAcademicCoursePage {
  const RecognizedAcademicCoursePage({
    required this.displayName,
    required this.courseHtml,
    required this.courseCount,
  });

  final String displayName;
  final String courseHtml;
  final int courseCount;
}

class AcademicCoursePageRecognizer {
  const AcademicCoursePageRecognizer._();

  static const host = 'jwk.lzu.edu.cn';
  static const path = '/academic/student/currcourse/currcourse.jsdo';

  static bool isCoursePageUrl(String? value) {
    final uri = value == null ? null : Uri.tryParse(value);
    return uri != null && uri.host == host && uri.path == path;
  }

  static AcademicSemesterMetadata extractMetadata(
    AcademicCoursePageCapture capture,
  ) {
    if (!isCoursePageUrl(capture.pageUrl)) {
      throw const FormatException('请先完成登录并返回教务系统课程安排页面');
    }
    final document = html_parser.parse(capture.html);
    final year = _firstNonEmpty(
      capture.selectedYear,
      document.querySelector('select[name="year"] option[selected]')?.text,
    );
    final term = _firstNonEmpty(
      capture.selectedTerm,
      document.querySelector('select[name="term"] option[selected]')?.text,
    );
    if (year == null || term == null) {
      throw const FormatException('无法识别当前页面的学年或学期');
    }
    return AcademicSemesterMetadata(year: year, term: term);
  }

  static RecognizedAcademicCoursePage recognize(
    AcademicCoursePageCapture capture,
  ) {
    final metadata = extractMetadata(capture);
    final semester = SemesterImporter.parseCourseHtml(
      semesterId: 0,
      displayName: metadata.displayName,
      termStartDate: null,
      courseHtml: capture.html,
    );
    return RecognizedAcademicCoursePage(
      displayName: metadata.displayName,
      courseHtml: capture.html,
      courseCount: semester.courses.length,
    );
  }

  static String? _firstNonEmpty(String? primary, String? fallback) {
    final first = primary?.trim();
    if (first != null && first.isNotEmpty) {
      return first;
    }
    final second = fallback?.trim();
    return second == null || second.isEmpty ? null : second;
  }
}
