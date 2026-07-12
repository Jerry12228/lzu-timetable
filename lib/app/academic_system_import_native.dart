import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../services/academic_course_page_recognizer.dart';

bool get isAcademicSystemImportSupported =>
    defaultTargetPlatform == TargetPlatform.android;

Route<RecognizedAcademicCoursePage> createAcademicSystemImportRoute() {
  return MaterialPageRoute(
    builder: (context) => const _AcademicSystemImportPage(),
  );
}

class _AcademicSystemImportPage extends StatefulWidget {
  const _AcademicSystemImportPage();

  @override
  State<_AcademicSystemImportPage> createState() =>
      _AcademicSystemImportPageState();
}

class _AcademicSystemImportPageState extends State<_AcademicSystemImportPage> {
  static const _coursePageUrl =
      'https://jwk.lzu.edu.cn/academic/student/currcourse/currcourse.jsdo';
  static const _captureScript = '''
    (() => JSON.stringify({
      pageUrl: window.location.href,
      html: document.documentElement.outerHTML,
      selectedYear: document.querySelector('select[name="year"]')
          ?.selectedOptions?.[0]?.textContent?.trim() || '',
      selectedTerm: document.querySelector('select[name="term"]')
          ?.selectedOptions?.[0]?.textContent?.trim() || ''
    }))()
  ''';

  final _cookieManager = WebViewCookieManager();
  late final WebViewController _controller;
  String? _currentUrl;
  bool _isLoading = true;
  bool _isRecognizing = false;
  bool _keepLogin = true;
  bool _canPop = false;
  bool _isLeaving = false;
  String? _loadError;

  bool get _isCoursePage =>
      AcademicCoursePageRecognizer.isCoursePageUrl(_currentUrl);

  @override
  void initState() {
    super.initState();
    _controller = WebViewController.fromPlatformCreationParams(
      AndroidWebViewControllerCreationParams(),
    );
    unawaited(_configureWebView());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<RecognizedAcademicCoursePage>(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          unawaited(_leave());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: '取消教务系统导入',
            onPressed: () => unawaited(_leave()),
            icon: const Icon(Icons.close),
          ),
          title: const Text('教务系统导入'),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              tooltip: '重新加载',
              onPressed: () => unawaited(_reloadCoursePage()),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Expanded(child: Text('保留登录状态')),
                  Switch(
                    value: _keepLogin,
                    onChanged: (value) {
                      setState(() => _keepLogin = value);
                    },
                  ),
                ],
              ),
            ),
            if (_isLoading) const LinearProgressIndicator(minHeight: 2),
            if (_loadError != null)
              MaterialBanner(
                content: Text(_loadError!),
                actions: [
                  TextButton(
                    onPressed: () => unawaited(_reloadCoursePage()),
                    child: const Text('重试'),
                  ),
                ],
              ),
            Expanded(child: WebViewWidget(controller: _controller)),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              key: const ValueKey('recognize-academic-course-page-button'),
              onPressed: _isCoursePage && !_isLoading && !_isRecognizing
                  ? () => unawaited(_recognizeCurrentPage())
                  : null,
              icon: Icon(_isRecognizing ? Icons.hourglass_top : Icons.search),
              label: Text(_isRecognizing ? '识别中...' : '识别当前页面'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _configureWebView() async {
    final androidController = _controller.platform;
    if (androidController is AndroidWebViewController) {
      await androidController.setMixedContentMode(MixedContentMode.alwaysAllow);
    }
    await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (url) {
          if (!mounted) {
            return;
          }
          setState(() {
            _currentUrl = url;
            _isLoading = true;
            _loadError = null;
          });
        },
        onPageFinished: (url) {
          if (!mounted) {
            return;
          }
          setState(() {
            _currentUrl = url;
            _isLoading = false;
            _loadError = null;
          });
        },
        onWebResourceError: (error) {
          if (error.isForMainFrame != true || !mounted) {
            return;
          }
          setState(() {
            _isLoading = false;
            _loadError = '页面加载失败（${error.errorCode}）：${error.description}';
          });
        },
      ),
    );
    await _reloadCoursePage();
  }

  Future<void> _reloadCoursePage() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    await _controller.loadRequest(Uri.parse(_coursePageUrl));
  }

  Future<void> _recognizeCurrentPage() async {
    if (!_isCoursePage || _isRecognizing) {
      return;
    }
    setState(() => _isRecognizing = true);
    try {
      final result = await _controller.runJavaScriptReturningResult(
        _captureScript,
      );
      final capture = _decodeCapture(result);
      final recognized = AcademicCoursePageRecognizer.recognize(capture);
      await _leave(result: recognized);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_messageForError(error))));
      }
    } finally {
      if (mounted) {
        setState(() => _isRecognizing = false);
      }
    }
  }

  AcademicCoursePageCapture _decodeCapture(Object value) {
    dynamic decoded = value;
    for (var attempt = 0; attempt < 2 && decoded is String; attempt++) {
      decoded = jsonDecode(decoded);
    }
    if (decoded is! Map) {
      throw const FormatException('无法读取当前课程安排页面');
    }
    final data = Map<String, Object?>.from(decoded);
    final pageUrl = data['pageUrl'];
    final html = data['html'];
    if (pageUrl is! String || html is! String || html.isEmpty) {
      throw const FormatException('无法读取当前课程安排页面');
    }
    return AcademicCoursePageCapture(
      pageUrl: pageUrl,
      html: html,
      selectedYear: data['selectedYear'] as String?,
      selectedTerm: data['selectedTerm'] as String?,
    );
  }

  Future<void> _leave({RecognizedAcademicCoursePage? result}) async {
    if (_isLeaving) {
      return;
    }
    _isLeaving = true;
    if (!_keepLogin) {
      try {
        await _cookieManager.clearCookies();
      } catch (_) {
        // Leaving the import page must not be blocked by cookie cleanup.
      }
    }
    if (!mounted) {
      return;
    }
    setState(() => _canPop = true);
    Navigator.of(context).pop(result);
  }

  String _messageForError(Object error) {
    if (error is FormatException) {
      return error.message;
    }
    return '识别失败，请确认当前页面已完成学期查询';
  }
}
