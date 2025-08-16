import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  success,
  navigation,
  api,
  animation,
  user_action,
}

class AppLogger {
  static const String _appName = 'PayPoint';
  static const Map<LogLevel, String> _levelEmojis = {
    LogLevel.debug: '🐛',
    LogLevel.info: 'ℹ️',
    LogLevel.warning: '⚠️',
    LogLevel.error: '❌',
    LogLevel.success: '✅',
    LogLevel.navigation: '🔄',
    LogLevel.api: '🌐',
    LogLevel.animation: '✨',
    LogLevel.user_action: '👤',
  };
  
  static const Map<LogLevel, String> _levelColors = {
    LogLevel.debug: '\x1B[36m',      // Cyan
    LogLevel.info: '\x1B[34m',       // Blue
    LogLevel.warning: '\x1B[33m',    // Yellow
    LogLevel.error: '\x1B[31m',      // Red
    LogLevel.success: '\x1B[32m',    // Green
    LogLevel.navigation: '\x1B[35m', // Magenta
    LogLevel.api: '\x1B[96m',        // Light Cyan
    LogLevel.animation: '\x1B[95m',  // Light Magenta
    LogLevel.user_action: '\x1B[93m', // Light Yellow
  };
  
  static const String _resetColor = '\x1B[0m';
  
  static void _log(LogLevel level, String tag, String message, {Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode && level == LogLevel.debug) return;
    
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final emoji = _levelEmojis[level] ?? 'ℹ️';
    final color = _levelColors[level] ?? '';
    final levelName = level.name.toUpperCase().padRight(10);
    
    final formattedMessage = '$color$emoji [$_appName] [$levelName] [$timestamp] [$tag] $message$_resetColor';
    
    // Print to console
    print(formattedMessage);
    
    // Log to developer console for better debugging
    developer.log(
      message,
      name: '$_appName:$tag',
      level: _getDeveloperLogLevel(level),
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  static int _getDeveloperLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.success:
        return 800;
      case LogLevel.navigation:
        return 700;
      case LogLevel.api:
        return 750;
      case LogLevel.animation:
        return 600;
      case LogLevel.user_action:
        return 750;
    }
  }

  // Debug logs
  static void debug(String tag, String message) {
    _log(LogLevel.debug, tag, message);
  }

  // Info logs
  static void info(String tag, String message) {
    _log(LogLevel.info, tag, message);
  }

  // Warning logs
  static void warning(String tag, String message) {
    _log(LogLevel.warning, tag, message);
  }

  // Error logs
  static void error(String tag, String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, tag, message, error: error, stackTrace: stackTrace);
  }

  // Success logs
  static void success(String tag, String message) {
    _log(LogLevel.success, tag, message);
  }

  // Navigation logs
  static void navigation(String tag, String message) {
    _log(LogLevel.navigation, tag, message);
  }

  // API logs
  static void api(String tag, String message) {
    _log(LogLevel.api, tag, message);
  }

  // Animation logs
  static void animation(String tag, String message) {
    _log(LogLevel.animation, tag, message);
  }

  // User action logs
  static void userAction(String tag, String message) {
    _log(LogLevel.user_action, tag, message);
  }
  
  // Specialized logging methods
  static void logScreenEntry(String screenName) {
    navigation('Navigation', 'Entered screen: $screenName');
  }
  
  static void logScreenExit(String screenName) {
    navigation('Navigation', 'Exited screen: $screenName');
  }
  
  static void logUserAction(String action, {Map<String, dynamic>? data}) {
    final dataStr = data != null ? ' | Data: $data' : '';
    userAction('UserAction', 'Action: $action$dataStr');
  }
  
  static void logApiCall(String endpoint, {String method = 'GET', Map<String, dynamic>? data}) {
    final dataStr = data != null ? ' | Data: $data' : '';
    api('API', '$method $endpoint$dataStr');
  }
  
  static void logApiResponse(String endpoint, {bool success = true, String? message, dynamic data}) {
    final status = success ? 'SUCCESS' : 'FAILED';
    final msg = message != null ? ' | Message: $message' : '';
    final dataStr = data != null ? ' | Data: $data' : '';
    api('API', '$endpoint - $status$msg$dataStr');
  }
  
  static void logError(String component, String operation, Object error, {StackTrace? stackTrace}) {
    AppLogger.error(component, 'Error in $operation: $error', error: error, stackTrace: stackTrace);
  }
  
  static void logSuccess(String component, String operation, {String? additionalInfo}) {
    final info = additionalInfo != null ? ' | $additionalInfo' : '';
    success(component, '$operation completed successfully$info');
  }
  
  static void logAnimation(String component, String animationType, {String? details}) {
    final detailsStr = details != null ? ' | $details' : '';
    animation(component, '$animationType animation$detailsStr');
  }
  
  // Performance logging
  static void logPerformance(String operation, Duration duration, {String? additionalInfo}) {
    final info = additionalInfo != null ? ' | $additionalInfo' : '';
    final ms = duration.inMilliseconds;

  }
  
  // Firebase logging
  static void logFirebaseOperation(String operation, {bool success = true, String? details}) {
    final status = success ? 'SUCCESS' : 'FAILED';
    final detailsStr = details != null ? ' | $details' : '';
    api('Firebase', '$operation - $status$detailsStr');
  }
  
  // Auth logging
  static void logAuthEvent(String event, {String? userId, String? details}) {
    final userStr = userId != null ? ' | User: $userId' : '';
    final detailsStr = details != null ? ' | $details' : '';
    info('Auth', '$event$userStr$detailsStr');
  }
  
  // State management logging
  static void logStateChange(String provider, String oldState, String newState) {
    info('State', '$provider: $oldState → $newState');
  }
  
  // Network logging
  static void logNetworkEvent(String event, {String? details}) {
    final detailsStr = details != null ? ' | $details' : '';
    info('Network', '$event$detailsStr');
  }
  
  // Payment logging
  static void logPaymentEvent(String event, {double? amount, String? provider, String? status}) {
    final amountStr = amount != null ? ' | Amount: $amount' : '';
    final providerStr = provider != null ? ' | Provider: $provider' : '';
    final statusStr = status != null ? ' | Status: $status' : '';
    info('Payment', '$event$amountStr$providerStr$statusStr');
  }
  
  // App lifecycle logging
  static void logAppLifecycle(String event) {
    info('Lifecycle', 'App $event');
  }
  
  // Custom separator for better readability
  static void separator({String? title}) {
    final line = '=' * 80;
    if (title != null) {
      final padding = (80 - title.length - 2) ~/ 2;
      final paddedTitle = '${' ' * padding}$title${' ' * padding}';
      print('\x1B[96m$line\x1B[0m');
      print('\x1B[96m$paddedTitle\x1B[0m');
      print('\x1B[96m$line\x1B[0m');
    } else {
      print('\x1B[96m$line\x1B[0m');
    }
  }
  
  // App startup logging
  static void logAppStart() {
    separator(title: 'PayPoint App Starting');
    info('App', 'PayPoint application is starting up...');
    info('App', 'Version: 1.0.0');
    info('App', 'Debug mode: ${kDebugMode ? 'ON' : 'OFF'}');
    info('App', 'Platform: Flutter');
    separator();
  }
  
  // Feature usage tracking
  static void logFeatureUsed(String feature, {Map<String, dynamic>? context}) {
    final contextStr = context != null ? ' | Context: $context' : '';
    userAction('Feature', 'Used: $feature$contextStr');
  }
  
  // Error boundary
  static void logUnhandledException(Object error, StackTrace stackTrace, {String? context}) {
    separator(title: 'UNHANDLED EXCEPTION');
    AppLogger.error('App', 'Unhandled exception${context != null ? ' in $context' : ''}', 
                   error: error, stackTrace: stackTrace);
    separator();
  }
}

// Extension for easy logging from any class
extension LoggerExtension on Object {
  void logDebug(String message) {
    AppLogger.debug(runtimeType.toString(), message);
  }
  
  void logInfo(String message) {
    AppLogger.info(runtimeType.toString(), message);
  }
  
  void logWarning(String message) {
    AppLogger.warning(runtimeType.toString(), message);
  }
  
  void logError(String message, {Object? error, StackTrace? stackTrace}) {
    AppLogger.error(runtimeType.toString(), message, error: error, stackTrace: stackTrace);
  }
  
  void logSuccess(String message) {
    AppLogger.success(runtimeType.toString(), message);
  }
  
  void logNavigation(String message) {
    AppLogger.navigation(runtimeType.toString(), message);
  }
  
  void logUserAction(String action, {Map<String, dynamic>? data}) {
    AppLogger.logUserAction(action, data: data);
  }
}
