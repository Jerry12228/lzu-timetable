import 'package:flutter/material.dart';

import '../services/academic_course_page_recognizer.dart';

bool get isAcademicSystemImportSupported => false;

Route<RecognizedAcademicCoursePage> createAcademicSystemImportRoute() {
  throw UnsupportedError('当前平台不支持教务系统导入');
}
