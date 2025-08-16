import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:ui';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/AppThemeMode.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/responsive_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/localization_provider.dart';
import '../profile/futurist_profile_screen.dart';
import '../services/network_recharge_screen.dart';
import '../services/futuristic_network_recharge_screen.dart';
import '../services/electricity_payment_screen.dart';
import '../services/water_payment_screen.dart';
import '../services/school_payment_screen.dart';
import '../transactions/transactions_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class FuturisticDashboardScreen extends ConsumerStatefulWidget {
  static const String routeName = '/futuristic-dashboard';

  const FuturisticDashboardScreen({super.key});

  @override
  ConsumerState<FuturisticDashboardScreen> createState() => _FuturisticDashboardScreenState();
}

class _FuturisticDashboardScreenState extends ConsumerState<FuturisticDashboardScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _sparkleController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _sparkleAnimation;

  int _selectedIndex = 0;
  bool _isWifiCardExpanded = false;

  @override
  void initState() {
    super.initState();
    AppLogger.logScreenEntry('FuturisticDashboard');
    AppLogger.logAnimation('FuturisticDashboard', 'Initializing animations');

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutQuart),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() {
    AppLogger.logAnimation('FuturisticDashboard', 'Starting all animations');
    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _sparkleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    AppLogger.logAnimation('FuturisticDashboard', 'Disposing animations');
    AppLogger.logScreenExit('FuturisticDashboard');
    _mainController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserAsyncProvider);
    final isRTL = ref.watch(isRTLProvider);
    final customColors = ref.watch(customColorsProvider);

    print('🎨 [FuturisticDashboard] Building UI...');

    return Scaffold(
      backgroundColor: customColors['background'],
      body: currentUserAsync.when(
        data: (user) {
          print('✅ [FuturisticDashboard] User data loaded: ${user?.name}');
          return _buildMainContent(context, user, isRTL);
        },
        loading: () {
          print('⏳ [FuturisticDashboard] Loading user data...');
          return _buildLoadingScreen();
        },
        error: (error, _) {
          print('❌ [FuturisticDashboard] Error loading user: $error');
          return _buildErrorScreen(error.toString());
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, user, bool isRTL) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = ResponsiveUtils.isTablet(context) || ResponsiveUtils.isDesktop(context);
    final isMobile = ResponsiveUtils.isMobile(context);

    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Stack(
              children: [
                // Background gradient with animation
                _buildAnimatedBackground(),

                // Floating particles
                _buildFloatingParticles(),

                // Main content
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                            maxWidth: constraints.maxWidth,
                          ),
                          child: CustomScrollView(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              // Futuristic header
                              _buildFuturisticHeader(context, user, isTablet),

                              // Quick WiFi recharge section (highlighted)
                              _buildQuickWiFiSection(context, isTablet),

                              // Services grid
                              _buildServicesGrid(context, isTablet),

                              // Recent transactions
                              _buildRecentTransactions(context, isTablet),

                              // Bottom spacing
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 100),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Floating action button
                _buildFloatingActions(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryDarkColor,
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
            AppTheme.primaryLightColor,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: BackgroundPatternPainter(_rotationAnimation.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _sparkleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlesPainter(_sparkleAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildFuturisticHeader(BuildContext context, user, bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // User greeting with holographic effect
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: AppTheme.cardShadow,
                              ),
                              child: Text(
                                'أهلاً بك',
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.name ?? 'مستخدم',
                        style: TextStyle(
                          fontSize: isTablet ? 32 : 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textOnPrimary,
                          fontFamily: 'Cairo',
                          shadows: [
                            Shadow(
                              color: AppTheme.primaryColor.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Profile avatar with glow
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      print('🔄 [FuturisticDashboard] Navigating to profile...');
                      Navigator.of(context).pushNamed(FuturisticProfileScreen.routeName);
                    },
                    child: Container(
                      width: isTablet ? 80 : 60,
                      height: isTablet ? 80 : 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.surfaceColor,
                        ),
                        child: Icon(
                          Icons.person,
                          color: AppTheme.primaryColor,
                          size: isTablet ? 40 : 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Balance card with holographic effect
            _buildBalanceCard(context, user, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, user, bool isTablet) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isTablet ? 32 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.2),
                  AppTheme.secondaryColor.withOpacity(0.1),
                  AppTheme.accentColor.withOpacity(0.1),
                ],
              ),
              borderRadius: AppTheme.largeRadius,
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'الرصيد الحالي',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          color: AppTheme.textSecondary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.successColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'نشط',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${user?.balance?.toStringAsFixed(0) ?? '0'} ريال',
                  style: TextStyle(
                    fontSize: isTablet ? 36 : 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    fontFamily: 'Cairo',
                    shadows: [
                      Shadow(
                        color: AppTheme.primaryColor.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // إضافة أزرار شحن المحفظة
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          print('🔄 [FuturisticDashboard] Opening wallet charge...');
                          Navigator.of(context).pushNamed('/wallet-charge');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: AppTheme.successGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.successColor.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: AppTheme.textPrimary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'شحن المحفظة',
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: AppTheme.surfaceColor.withOpacity(0.05),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, color: AppTheme.primaryColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'تحويل',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickWiFiSection(BuildContext context, bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'شحن الواي فاي السريع',
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textOnPrimary,
                      fontFamily: 'Cairo',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 2 * math.pi,
                      child: Icon(
                        Icons.wifi,
                        color: AppTheme.primaryColor,
                        size: isTablet ? 32 : 28,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Enhanced WiFi card
            GestureDetector(
              onTap: () {
                print('🔄 [FuturisticDashboard] Opening futuristic WiFi recharge...');
                Navigator.of(context).pushNamed(FuturisticNetworkRechargeScreen.routeName);
              },
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: isTablet ? 200 : 160,
                        maxHeight: isTablet ? 220 : 180,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.3),
                            AppTheme.secondaryColor.withOpacity(0.2),
                            AppTheme.accentColor.withOpacity(0.2),
                            AppTheme.errorColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: AppTheme.largeRadius,
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: AppTheme.heavyShadow,
                      ),
                      child: ClipRRect(
                        borderRadius: AppTheme.largeRadius,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: EdgeInsets.all(isTablet ? 32 : 24),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor.withOpacity(0.1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: isTablet ? 60 : 50,
                                        height: isTablet ? 60 : 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: AppTheme.primaryGradient,
                                          boxShadow: AppTheme.cardShadow,
                                        ),
                                        child: Icon(
                                          Icons.wifi,
                                          color: AppTheme.textPrimary,
                                          size: isTablet ? 30 : 25,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'شحن فوري',
                                              style: TextStyle(
                                                fontSize: isTablet ? 20 : 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textOnPrimary,
                                                fontFamily: 'Cairo',
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'جميع الشبكات متاحة',
                                              style: TextStyle(
                                                fontSize: isTablet ? 14 : 12,
                                                color: AppTheme.textSecondary,
                                                fontFamily: 'Cairo',
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: AppTheme.primaryColor,
                                        size: isTablet ? 24 : 20,
                                      ),
                                    ],
                                  ),
                                ),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    _buildQuickAmountChip('500', isTablet),
                                    _buildQuickAmountChip('1000', isTablet),
                                    _buildQuickAmountChip('2000', isTablet),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountChip(String amount, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        '$amount ريال',
        style: TextStyle(
          fontSize: isTablet ? 12 : 10,
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context, bool isTablet) {
    final services = [
      {
        'title': 'شحن الكهرباء',
        'subtitle': 'دفع فواتير الكهرباء',
        'icon': Icons.electrical_services,
        'color': AppTheme.accentColor,
        'route': '/futuristic-electricity-payment',
      },
      {
        'title': 'دفع المياه',
        'subtitle': 'فواتير المياه والصرف',
        'icon': Icons.water_drop,
        'color': AppTheme.infoColor,
        'route': '/futuristic-water-payment',
      },
      {
        'title': 'رسوم المدارس',
        'subtitle': 'دفع رسوم التعليم',
        'icon': Icons.school,
        'color': AppTheme.successColor,
        'route': '/futuristic-school-payment',
      },
      {
        'title': 'سجل المعاملات',
        'subtitle': 'تاريخ العمليات',
        'icon': Icons.history,
        'color': AppTheme.warningColor,
        'route': TransactionsScreen.routeName,
      },
    ];

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الخدمات الأخرى',
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textOnPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return _buildServiceCard(
                  context,
                  service['title'] as String,
                  service['subtitle'] as String,
                  service['icon'] as IconData,
                  service['color'] as Color,
                  service['route'] as String,
                  isTablet,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon,
      Color color,
      String route,
      bool isTablet,
      ) {
    return GestureDetector(
      onTap: () {
        print('🔄 [FuturisticDashboard] Navigating to: $route');
        Navigator.of(context).pushNamed(route);
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: AppTheme.largeRadius,
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: AppTheme.largeRadius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor.withOpacity(0.05),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: isTablet ? 50 : 40,
                        height: isTablet ? 50 : 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withOpacity(0.2),
                          border: Border.all(
                            color: color,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: isTablet ? 25 : 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textOnPrimary,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          color: AppTheme.textSecondary,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, bool isTablet) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'آخر المعاملات',
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textOnPrimary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    print('🔄 [FuturisticDashboard] Navigating to transactions...');
                    Navigator.of(context).pushNamed(TransactionsScreen.routeName);
                  },
                  child: Text(
                    'عرض الكل',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.surfaceColor.withOpacity(0.1),
                    AppTheme.surfaceColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: AppTheme.largeRadius,
                border: Border.all(
                  color: AppTheme.borderColor,
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _sparkleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_sparkleAnimation.value * 0.1),
                          child: Icon(
                            Icons.history,
                            size: isTablet ? 60 : 50,
                            color: AppTheme.textHint,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد معاملات حديثة',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        color: AppTheme.textSecondary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ابدأ أول معاملة من الخدمات أعلاه',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: AppTheme.textHint,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActions(BuildContext context) {
    return Positioned(
      bottom: 30,
      right: 30,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: FloatingActionButton(
              onPressed: () {
                print('🔄 [FuturisticDashboard] FAB pressed - quick actions');
                _showQuickActions(context);
              },
              backgroundColor: AppTheme.primaryColor,
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value * 2 * math.pi,
                    child: Icon(
                      Icons.add,
                      color: AppTheme.textPrimary,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    print('✨ [FuturisticDashboard] Showing quick actions modal');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQuickActionsModal(context),
    );
  }

  Widget _buildQuickActionsModal(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.9),
            AppTheme.secondaryColor.withOpacity(0.9),
          ],
        ),
        borderRadius: AppTheme.largeRadius,
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: AppTheme.largeRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'إجراءات سريعة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textOnPrimary,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickActionButton(
                      Icons.wifi,
                      'شحن واي فاي',
                      AppTheme.primaryColor,
                          () => Navigator.of(context).pushNamed(FuturisticNetworkRechargeScreen.routeName),
                    ),
                    _buildQuickActionButton(
                      Icons.electrical_services,
                      'دفع كهرباء',
                      AppTheme.accentColor,
                          () => Navigator.of(context).pushNamed(ElectricityPaymentScreen.routeName),
                    ),
                    _buildQuickActionButton(
                      Icons.history,
                      'المعاملات',
                      AppTheme.warningColor,
                          () => Navigator.of(context).pushNamed(TransactionsScreen.routeName),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
      IconData icon,
      String label,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: () {
        print('🔄 [FuturisticDashboard] Quick action: $label');
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textOnPrimary,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryDarkColor,
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
            AppTheme.primaryLightColor,
          ],
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryDarkColor,
            AppTheme.primaryColor,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'خطأ في تحميل البيانات',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textOnPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  final double animationValue;

  BackgroundPatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppTheme.primaryColor.withOpacity(0.1);

    // Draw animated geometric patterns
    for (int i = 0; i < 20; i++) {
      final offset = Offset(
        (size.width * 0.1 * i) + (animationValue * 50),
        (size.height * 0.1 * i) + (animationValue * 30),
      );

      canvas.drawCircle(
        offset,
        20 + (animationValue * 10),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class ParticlesPainter extends CustomPainter {
  final double animationValue;

  ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppTheme.primaryColor.withOpacity(0.3);

    // Draw floating particles
    for (int i = 0; i < 50; i++) {
      final x = (size.width * math.Random(i).nextDouble()) + (math.sin(animationValue * 2 * math.pi + i) * 20);
      final y = (size.height * math.Random(i + 100).nextDouble()) + (math.cos(animationValue * 2 * math.pi + i) * 15);

      canvas.drawCircle(
        Offset(x, y),
        2 + (math.sin(animationValue * 4 * math.pi + i) * 1),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
