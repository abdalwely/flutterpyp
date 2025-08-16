import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../core/utils/logger.dart';
import '../widgets/animated_widgets.dart';
import 'admin/futuristic_admin_dashboard.dart';
import 'auth/futuristic_login_screen.dart';
import 'home/enhanced_dashboard_screen.dart';
import 'home/futuristic_dashboard_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static const String routeName = '/';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    AppLogger.logScreenEntry('SplashScreen');
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      _textController.forward();
    });
  }

  void _initializeApp() async {
    // Wait for minimum splash time
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Get current auth state and navigate accordingly
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() {
    final authState = ref.read(authControllerProvider);

    authState.when(
      data: (user) {
        if (!mounted) return;

        if (user != null) {
          AppLogger.logAuthEvent('User authenticated', userId: user.uid, details: 'Navigating to dashboard');
          AppLogger.logScreenExit('SplashScreen');

          // توجيه المدير لصفحة الإدارة
          if (user.isAdmin) {
            Navigator.of(context).pushReplacementNamed(
              FuturisticAdminDashboardScreen.routeName,
            );
          } else {
            Navigator.of(context).pushReplacementNamed(
              FuturisticDashboardScreen.routeName,
            );
          }
        } else {
          AppLogger.logAuthEvent('User not authenticated', details: 'Navigating to login');
          AppLogger.logScreenExit('SplashScreen');
          Navigator.of(context).pushReplacementNamed(
            FuturisticLoginScreen.routeName,
          );
        }
      },
      loading: () {
        // Wait a bit more for auth to load, then check again
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) _checkAuthAndNavigate();
        });
      },
      error: (error, _) {
        AppLogger.logAuthEvent('Auth error', details: error.toString());
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            FuturisticLoginScreen.routeName,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo
                      AnimatedBuilder(
                        animation: _logoAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoAnimation.value,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.payment,
                                size: 80,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Animated Text
                      AnimatedBuilder(
                        animation: _textAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _textAnimation.value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - _textAnimation.value)),
                              child: Column(
                                children: [
                                  const Text(
                                    'PayPoint',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Cairo',
                                      letterSpacing: 3,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    child: const Text(
                                      'منصة الدفع الإلكتروني الشاملة',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Loading Indicator
              Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const PulseWidget(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'جارٍ تحضير التطبيق...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
