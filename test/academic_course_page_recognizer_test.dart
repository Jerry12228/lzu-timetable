import 'dart:io';

import 'package:course_schedule/services/academic_course_page_recognizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const coursePageUrl =
      'https://jwk.lzu.edu.cn/academic/student/currcourse/currcourse.jsdo';
  final courseHtml = File(
    'assets/raw/2025-2026-2-courses.html',
  ).readAsStringSync();
  final legacyPageHtml = File(
    'assets/raw/lzu-currcourse-page.html',
  ).readAsStringSync();

  test('extracts the selected academic year and term from the page html', () {
    final metadata = AcademicCoursePageRecognizer.extractMetadata(
      AcademicCoursePageCapture(pageUrl: coursePageUrl, html: legacyPageHtml),
    );

    expect(metadata.year, '2002');
    expect(metadata.term, '秋');
    expect(metadata.displayName, '2002秋课程表');
  });

  test(
    'uses the current JavaScript selected options before html attributes',
    () {
      final metadata = AcademicCoursePageRecognizer.extractMetadata(
        AcademicCoursePageCapture(
          pageUrl: coursePageUrl,
          html: legacyPageHtml,
          selectedYear: '2026',
          selectedTerm: '春',
        ),
      );

      expect(metadata.displayName, '2026春课程表');
    },
  );

  test('recognizes a complete page and validates its course data', () {
    final recognized = AcademicCoursePageRecognizer.recognize(
      AcademicCoursePageCapture(
        pageUrl: coursePageUrl,
        html:
            '''
          <select name="year"><option selected>2026</option></select>
          <select name="term"><option selected>春</option></select>
          $courseHtml
          $legacyPageHtml
        ''',
      ),
    );

    expect(recognized.displayName, '2026春课程表');
    expect(recognized.courseCount, 19);
  });

  test('rejects pages outside the academic course page url', () {
    expect(
      () => AcademicCoursePageRecognizer.extractMetadata(
        const AcademicCoursePageCapture(
          pageUrl: 'https://sso.lzu.edu.cn/login',
          html: '<html></html>',
        ),
      ),
      throwsFormatException,
    );
  });
}
