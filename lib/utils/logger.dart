import 'package:flutter/foundation.dart';

class Logger {
  static const String _resetColor = '\x1B[0m';
  static const String _redColor = '\x1B[31m';
  static const String _greenColor = '\x1B[32m';
  static const String _yellowColor = '\x1B[33m';
  static const String _blueColor = '\x1B[34m';
  static const String _magentaColor = '\x1B[35m';

  static void debug(String message, {String? tag}) {
    _log('DEBUG', message, tag: tag, color: _blueColor);
  }

  static void info(String message, {String? tag}) {
    _log('INFO', message, tag: tag, color: _greenColor);
  }

  static void warning(String message, {String? tag}) {
    _log('WARN', message, tag: tag, color: _yellowColor);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    _log('ERROR', message, tag: tag, color: _redColor);
    if (error != null) {
      debugPrint('$_redColor[ERROR] Error object: $error$_resetColor');
    }
    if (stackTrace != null) {
      debugPrint('$_redColor[ERROR] Stack trace:\n$stackTrace$_resetColor');
    }
  }

  static void navigation(String message, {String? from, String? to}) {
    final navTag = 'NAV${from != null ? " from:$from" : ""}${to != null ? " to:$to" : ""}';
    _log('NAV', message, tag: navTag, color: _magentaColor);
  }

  static void lifecycle(String widget, String event) {
    _log('LIFECYCLE', '$widget: $event', color: _yellowColor);
  }

  static void _log(String level, String message, {String? tag, String color = ''}) {
    final timestamp = DateTime.now().toIso8601String();
    final tagStr = tag != null ? ' [$tag]' : '';
    debugPrint('$color[$timestamp] [$level]$tagStr $message$_resetColor');
  }
}