import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/admin_service.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'core/testing/operation_tester.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start app logging
  AppLogger.logAppStart();

  try {
    // Initialize Firebase
    AppLogger.info('Firebase', 'Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.success('Firebase', 'Firebase initialized successfully');
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.surfaceColor,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
    
    // Initialize SharedPreferences
    AppLogger.info('Storage', 'Initializing SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    AppLogger.success('Storage', 'SharedPreferences initialized successfully');

    // Initialize Admin Service and create default admin
    try {
      AppLogger.info('Admin', 'Initializing admin service...');
      final adminService = AdminService();
      await adminService.createDefaultAdmin();
      AppLogger.success('Admin', 'Admin service initialized successfully');
    } catch (e) {
      AppLogger.warning('Admin', 'Admin service initialization failed: $e');
    }

    // Set app configuration
    AppLogger.info('Config', 'Setting app configuration...');
    await _setAppConfiguration();

    // Setup error handling
    AppLogger.info('ErrorHandling', 'Setting up error handling...');
    setupErrorHandling();

    // Mark app start for performance monitoring
    PerformanceMonitor.markAppStart();

    AppLogger.separator(title: 'APP READY');
    AppLogger.success('App', 'PayPoint App is starting...');

    // Run comprehensive system test in debug mode
    if (kDebugMode) {
      AppLogger.info('Testing', 'Running system tests...');
      OperationTester.testFeatures();
      OperationTester.testPerformance();
    }

    runApp(
      const ProviderScope(
        child: PayPointApp(),
      ),
    );
  } catch (e) {
    AppLogger.error('App', 'Critical error during app initialization', error: e);
    
    // Run app with fallback configuration
    runApp(
      MaterialApp(
        title: 'PayPoint - خطأ في التهيئة',
        theme: AppTheme.lightTheme,
        home: ErrorScreen(error: e.toString()),
      ),
    );
  }
}

Future<void> _setAppConfiguration() async {
  try {
    // Enable edge-to-edge display
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );
    
    // Set app-wide text scale factor
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    AppLogger.success('Config', 'App configuration set successfully');
  } catch (e) {
    AppLogger.warning('Config', 'Could not set app configuration: $e');
  }
}

// Error Screen for critical initialization failures
class ErrorScreen extends StatelessWidget {
  final String error;
  
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.errorColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppTheme.errorColor,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                const Text(
                  'PayPoint',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    letterSpacing: 2,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                const Text(
                  'تطبيق الدفع الإلكتروني',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontFamily: 'Cairo',
                  ),
                ),
                
                const SizedBox(height: 50),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                //    backdropFilter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.warning,
                        color: Colors.amber,
                        size: 48,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      const Text(
                        'خطأ في تشغيل التطبيق',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      const Text(
                        'حدث خطأ أثناء تهيئة التطبيق. يرجى التأكد من اتصال الإنترنت وإعادة المحاولة.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'تفاصيل الخطأ:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              error,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Restart the app
                                SystemNavigator.pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.errorColor,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'إعادة التشغيل',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Try to continue with fallback mode
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const ProviderScope(
                                      child: PayPointApp(),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'المحاولة',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// App Info and Debugging
class AppInfo {
  static const String name = 'PayPoint';
  static const String version = '1.0.0';
  static const String buildNumber = '1';
  static const String description = 'تطبيق PayPoint متعدد الخدمات للدفع الإلكتروني';
  
  static void printAppInfo() {
    print('📱 App Name: $name');
    print('🔢 Version: $version');
    print('🏗️ Build: $buildNumber');
    print('📝 Description: $description');
    print('🎯 Mode: Production Ready');
    print('🔥 Firebase: Enabled');
    print('🔒 Auth: Enabled');
    print('📊 Firestore: Enabled');
  }
  
  static Map<String, dynamic> getAppInfo() {
    return {
      'name': name,
      'version': version,
      'buildNumber': buildNumber,
      'description': description,
      'isDebug': kDebugMode,
      'firebaseEnabled': true,
      'authEnabled': true,
      'firestoreEnabled': true,
    };
  }
}

// Global navigator key for navigation from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Global error handling
void setupErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AppLogger.logUnhandledException(details.exception, details.stack ?? StackTrace.current,
                                   context: 'Flutter Framework');
  };

  ui.PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.logUnhandledException(error, stack, context: 'Platform');
    return true;
  };
}

// Performance monitoring
class PerformanceMonitor {
  static DateTime? _appStartTime;
  static DateTime? _splashEndTime;
  static DateTime? _firstFrameTime;
  
  static void markAppStart() {
    _appStartTime = DateTime.now();
    AppLogger.logPerformance('App Start', Duration.zero, additionalInfo: 'Marked start time');
  }

  static void markSplashEnd() {
    _splashEndTime = DateTime.now();
    if (_appStartTime != null) {
      final duration = _splashEndTime!.difference(_appStartTime!);
      AppLogger.logPerformance('Splash Screen', duration);
    }
  }

  static void markFirstFrame() {
    _firstFrameTime = DateTime.now();
    if (_appStartTime != null) {
      final duration = _firstFrameTime!.difference(_appStartTime!);
      AppLogger.logPerformance('First Frame', duration);
    }
  }
  
  static Map<String, int> getPerformanceMetrics() {
    final now = DateTime.now();
    return {
      'app_start_to_now': _appStartTime != null 
          ? now.difference(_appStartTime!).inMilliseconds 
          : 0,
      'splash_duration': _appStartTime != null && _splashEndTime != null
          ? _splashEndTime!.difference(_appStartTime!).inMilliseconds
          : 0,
      'time_to_first_frame': _appStartTime != null && _firstFrameTime != null
          ? _firstFrameTime!.difference(_appStartTime!).inMilliseconds
          : 0,
    };
  }
}
