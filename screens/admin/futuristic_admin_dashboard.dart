import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypoint/screens/admin/schools_management_screen.dart';
import 'package:paypoint/screens/admin/transactions_admin_screen.dart';
import 'dart:math' as math;
import 'dart:ui';

import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/firestore_provider.dart';
import 'cards_management_screen.dart';


class FuturisticAdminDashboardScreen extends ConsumerStatefulWidget {
  static const String routeName = '/futuristic-admin-dashboard';

  const FuturisticAdminDashboardScreen({super.key});

  @override
  ConsumerState<FuturisticAdminDashboardScreen> createState() => _FuturisticAdminDashboardScreenState();
}

class _FuturisticAdminDashboardScreenState extends ConsumerState<FuturisticAdminDashboardScreen>
    with TickerProviderStateMixin {

  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _sparkleController;
  late AnimationController _floatingController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuart),
    ));

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutExpo),
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _sparkleController.repeat(reverse: true);
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _sparkleController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserAsyncProvider);

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _mainController,
          _pulseController,
          _rotationController,
          _sparkleController,
          _floatingController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Animated Background
              CustomPaint(
                painter: AdminBackgroundPainter(
                  rotationValue: _rotationAnimation.value,
                  sparkleValue: _sparkleAnimation.value,
                ),
                size: Size.infinite,
              ),

              // Floating Particles
              CustomPaint(
                painter: AdminParticlesPainter(
                  animationValue: _sparkleAnimation.value,
                  floatingValue: _floatingAnimation.value,
                ),
                size: Size.infinite,
              ),

              // Main Content
              currentUserAsync.when(
                data: (user) {
                  if (user == null || !user.isAdmin) {
                    return _buildUnauthorizedContent();
                  }
                  return _buildAdminContent(context, user);
                },
                loading: () => _buildLoadingContent(),
                error: (error, _) => _buildErrorContent(error.toString()),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAdminContent(BuildContext context, user) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              _buildHeader(user),

              const SizedBox(height: 30),

              // Statistics Cards
              _buildStatisticsSection(),

              const SizedBox(height: 30),

              // Management Options
              _buildManagementSection(),

              const SizedBox(height: 30),

              // System Info
              _buildSystemInfo(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(user) {
    return Transform.translate(
      offset: Offset(0, 50 * _slideAnimation.value),
      child: Opacity(
        opacity: _fadeInAnimation.value,
        child: Column(
          children: [
            // Admin Crown Icon
            Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.amber.withOpacity(0.8),
                      Colors.orange.withOpacity(0.6),
                      Colors.red.withOpacity(0.4),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Welcome Message
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Text(
                    'مرحباً ${user.name}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'لوحة تحكم المسؤول',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Transform.translate(
      offset: Offset(0, 30 * _slideAnimation.value),
      child: Opacity(
        opacity: _fadeInAnimation.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5, bottom: 15),
              child: Text(
                'الإحصائيات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final cardStatsAsync = ref.watch(cardStatisticsProvider);
                return cardStatsAsync.when(
                  data: (stats) => _buildStatsGrid(stats),
                  loading: () => _buildStatsLoading(),
                  error: (error, _) => _buildStatsError(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          title: 'إجمالي الكروت',
          value: stats['total']?.toString() ?? '0',
          icon: Icons.sim_card,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'الكروت المتاحة',
          value: stats['available']?.toString() ?? '0',
          icon: Icons.inventory,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'الكروت المباعة',
          value: stats['sold']?.toString() ?? '0',
          icon: Icons.shopping_cart,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'الشبكات',
          value: (stats['byNetwork'] as Map?)?.length?.toString() ?? '0',
          icon: Icons.network_cell,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatsLoading() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.2,
      children: List.generate(4, (index) => _buildLoadingCard()),
    );
  }

  Widget _buildStatsError() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.2),
            Colors.red.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: const Center(
        child: Text(
          'خطأ في تحميل الإحصائيات',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.2),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 25,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildManagementSection() {
    return Transform.translate(
      offset: Offset(0, 20 * _slideAnimation.value),
      child: Opacity(
        opacity: _fadeInAnimation.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5, bottom: 15),
              child: Text(
                'الإدارة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            _buildManagementItem(
              icon: Icons.sim_card,
              title: 'إدارة الكروت',
              subtitle: 'إضافة وإدارة كروت الشحن',
              color: Colors.blue,
              onTap: () => Navigator.of(context).pushNamed(
                CardsManagementScreen.routeName,
              ),
            ),
            _buildManagementItem(
              icon: Icons.history,
              title: 'إدارة المعاملات',
              subtitle: 'عرض وإدارة جميع المعاملات',
              color: Colors.green,
              onTap: () => Navigator.of(context).pushNamed(
                TransactionsAdminScreen.routeName,
              ),
            ),
            _buildManagementItem(
              icon: Icons.school,
              title: 'إدا��ة المدارس',
              subtitle: 'إضافة وإدارة المدارس',
              color: Colors.orange,
              onTap: () => Navigator.of(context).pushNamed(
                SchoolsManagementScreen.routeName,
              ),
            ),
            _buildManagementItem(
              icon: Icons.people,
              title: 'إدارة المستخدمين',
              subtitle: 'عرض وإدارة حسابات المستخدمين',
              color: Colors.purple,
              onTap: () => _showComingSoon('إدارة المستخدمين'),
            ),
            _buildManagementItem(
              icon: Icons.settings,
              title: 'إعدادات النظام',
              subtitle: 'إعدادات عامة للتطبيق',
              color: Colors.red,
              onTap: () => _showComingSoon('إعدادات النظام'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.3),
                        color.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.6),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSystemInfo() {
    return Transform.translate(
      offset: Offset(0, 10 * _slideAnimation.value),
      child: Opacity(
        opacity: _fadeInAnimation.value,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معلومات النظام',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildInfoRow('إصدار التطبيق', AppConstants.appVersion),
                  _buildInfoRow('اسم التطبيق', AppConstants.appName),
                  _buildInfoRow('حالة الخادم', 'متصل'),
                  _buildInfoRow('آخر تحديث', 'اليوم'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              fontFamily: 'Cairo',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 20),
          Text(
            'جاري التحميل...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 64,
          ),
          const SizedBox(height: 20),
          Text(
            'خطأ في تحميل البيانات',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            error,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthorizedContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.security,
            color: Colors.white,
            size: 64,
          ),
          const SizedBox(height: 20),
          const Text(
            'غير مصرح لك بالوصول لهذه الصفحة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppConstants.primaryColor,
            ),
            child: const Text(
              'العودة',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'قريباً',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'ميزة $feature ستكون متاحة في التحديث القادم',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'موافق',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Admin Background
class AdminBackgroundPainter extends CustomPainter {
  final double rotationValue;
  final double sparkleValue;

  AdminBackgroundPainter({
    required this.rotationValue,
    required this.sparkleValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Base gradient background with admin colors
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF1a1a2e),
        const Color(0xFF16213e),
        const Color(0xFF0f3460),
        const Color(0xFF764ba2),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Admin-specific geometric shapes
    _drawAdminShapes(canvas, size, paint);
    _drawSparkleEffect(canvas, size, paint);
  }

  void _drawAdminShapes(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);

    // Large rotating pentagon (for admin authority)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationValue);

    paint.shader = RadialGradient(
      colors: [
        Colors.amber.withOpacity(0.1),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: 200));

    _drawPentagon(canvas, const Offset(100, 0), 150, paint);
    canvas.restore();

    // Secondary rotating hexagon
    canvas.save();
    canvas.translate(center.dx - 100, center.dy + 100);
    canvas.rotate(-rotationValue * 0.7);

    paint.shader = RadialGradient(
      colors: [
        Colors.orange.withOpacity(0.08),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: 120));

    _drawHexagon(canvas, const Offset(0, 0), 100, paint);
    canvas.restore();
  }

  void _drawPentagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * 2 * math.pi / 6;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSparkleEffect(Canvas canvas, Size size, Paint paint) {
    paint.shader = null;
    paint.color = Colors.amber.withOpacity(0.6 * sparkleValue);

    final sparklePositions = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.7),
      Offset(size.width * 0.1, size.height * 0.8),
      Offset(size.width * 0.6, size.height * 0.1),
      Offset(size.width * 0.3, size.height * 0.9),
    ];

    for (final position in sparklePositions) {
      _drawCrown(canvas, position, paint, 3.0 * sparkleValue);
    }
  }

  void _drawCrown(Canvas canvas, Offset center, Paint paint, double size) {
    final path = Path();
    // Simple crown shape
    path.moveTo(center.dx - size, center.dy + size * 0.5);
    path.lineTo(center.dx - size * 0.5, center.dy - size);
    path.lineTo(center.dx, center.dy);
    path.lineTo(center.dx + size * 0.5, center.dy - size);
    path.lineTo(center.dx + size, center.dy + size * 0.5);
    path.lineTo(center.dx - size, center.dy + size * 0.5);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(AdminBackgroundPainter oldDelegate) {
    return oldDelegate.rotationValue != rotationValue ||
        oldDelegate.sparkleValue != sparkleValue;
  }
}

// Custom Painter for Admin Floating Particles
class AdminParticlesPainter extends CustomPainter {
  final double animationValue;
  final double floatingValue;

  AdminParticlesPainter({
    required this.animationValue,
    required this.floatingValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.amber.withOpacity(0.3 * animationValue);

    // Admin-themed particles (crowns and gears)
    for (int i = 0; i < 10; i++) {
      final x = (size.width / 10) * i + (math.sin(animationValue * 2 * math.pi + i) * 20);
      final y = (size.height / 6) * (i % 6) + floatingValue;
      final radius = 1.0 + (math.sin(animationValue * math.pi + i) * 1.5);

      // Draw small crown particles
      if (i % 2 == 0) {
        _drawMiniCrown(canvas, Offset(x, y), radius, paint);
      } else {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  void _drawMiniCrown(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx - size, center.dy + size * 0.3);
    path.lineTo(center.dx - size * 0.3, center.dy - size * 0.7);
    path.lineTo(center.dx, center.dy - size * 0.3);
    path.lineTo(center.dx + size * 0.3, center.dy - size * 0.7);
    path.lineTo(center.dx + size, center.dy + size * 0.3);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(AdminParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.floatingValue != floatingValue;
  }
}
