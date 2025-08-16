import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:ui';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/responsive_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/localization_provider.dart';
import '../../models/transaction_model.dart';

class FuturisticTransactionsScreen extends ConsumerStatefulWidget {
  static const String routeName = '/futuristic-transactions';

  const FuturisticTransactionsScreen({super.key});

  @override
  ConsumerState<FuturisticTransactionsScreen> createState() => _FuturisticTransactionsScreenState();
}

class _FuturisticTransactionsScreenState extends ConsumerState<FuturisticTransactionsScreen>
    with TickerProviderStateMixin {

  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _sparkleController;
  late AnimationController _listController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _listAnimation;

  String _selectedFilter = 'all';
  final List<String> _filters = [
    'all',
    'network_recharge',
    'electricity_payment',
    'water_payment',
    'school_payment',
    'wallet_charge',
  ];

  // Mock data for demonstration
  List<Map<String, dynamic>> _mockTransactions = [];

  @override
  void initState() {
    super.initState();
    AppLogger.logScreenEntry('FuturisticTransactions');
    _setupAnimations();
    _generateMockTransactions();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _listController = AnimationController(
      duration: const Duration(milliseconds: 1800),
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

    _listAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _listController, curve: Curves.easeOutBack),
    );

    _startAnimations();
  }

  void _startAnimations() {
    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _sparkleController.repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 500), () {
      _listController.forward();
    });
  }

  void _generateMockTransactions() {
    final now = DateTime.now();
    _mockTransactions = [
      {
        'id': 'tx_001',
        'type': 'network_recharge',
        'title': 'شحن واي فاي - يمن موبايل',
        'amount': 1000.0,
        'date': now.subtract(const Duration(hours: 2)),
        'status': 'success',
        'icon': Icons.wifi,
        'color': const Color(0xFF00F5FF),
      },
      {
        'id': 'tx_002',
        'type': 'electricity_payment',
        'title': 'دفع فاتورة الكهرباء',
        'amount': 2500.0,
        'date': now.subtract(const Duration(days: 1)),
        'status': 'success',
        'icon': Icons.electrical_services,
        'color': const Color(0xFFFF6B35),
      },
      {
        'id': 'tx_003',
        'type': 'wallet_charge',
        'title': 'شحن المحفظة',
        'amount': 5000.0,
        'date': now.subtract(const Duration(days: 2)),
        'status': 'success',
        'icon': Icons.account_balance_wallet,
        'color': const Color(0xFF28A745),
      },
      {
        'id': 'tx_004',
        'type': 'water_payment',
        'title': 'دفع فاتورة المياه',
        'amount': 800.0,
        'date': now.subtract(const Duration(days: 3)),
        'status': 'success',
        'icon': Icons.water_drop,
        'color': const Color(0xFF4ECDC4),
      },
      {
        'id': 'tx_005',
        'type': 'school_payment',
        'title': 'رسوم مدرسية - مدرسة الأندلس',
        'amount': 15000.0,
        'date': now.subtract(const Duration(days: 5)),
        'status': 'success',
        'icon': Icons.school,
        'color': const Color(0xFF9B59B6),
      },
      {
        'id': 'tx_006',
        'type': 'network_recharge',
        'title': 'شحن واي فاي - سبأفون',
        'amount': 500.0,
        'date': now.subtract(const Duration(days: 7)),
        'status': 'failed',
        'icon': Icons.wifi,
        'color': const Color(0xFFDC3545),
      },
    ];
  }

  @override
  void dispose() {
    AppLogger.logScreenExit('FuturisticTransactions');
    _mainController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _sparkleController.dispose();
    _listController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedFilter == 'all') {
      return _mockTransactions;
    }
    return _mockTransactions.where((tx) => tx['type'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserAsyncProvider);
    final isRTL = ref.watch(isRTLProvider);
    final isTablet = ResponsiveUtils.isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: currentUserAsync.when(
        data: (user) => _buildMainContent(context, user, isRTL, isTablet),
        loading: () => _buildLoadingScreen(),
        error: (error, _) => _buildErrorScreen(error.toString()),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, user, bool isRTL, bool isTablet) {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Stack(
              children: [
                _buildAnimatedBackground(),
                _buildFloatingParticles(),
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(context, isTablet),
                      _buildStatsCards(isTablet),
                      _buildFilters(isTablet),
                      Expanded(
                        child: _buildTransactionsList(isTablet),
                      ),
                    ],
                  ),
                ),
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
            const Color(0xFF0A0A0A),
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
            const Color(0xFF0F3460),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: TransactionBackgroundPainter(_rotationAnimation.value),
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
          painter: TransactionParticlesPainter(_sparkleAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: isTablet ? 50 : 44,
              height: isTablet ? 50 : 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00F5FF).withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: const Color(0xFF00F5FF),
                size: isTablet ? 24 : 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سجل المعا��لات',
                  style: TextStyle(
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  'تتبع جميع عملياتك المالية',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.white70,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 2 * math.pi,
                child: Container(
                  width: isTablet ? 50 : 44,
                  height: isTablet ? 50 : 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00F5FF), Color(0xFF9B59B6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F5FF).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.history,
                    color: Colors.black,
                    size: isTablet ? 28 : 24,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(bool isTablet) {
    final totalAmount = _mockTransactions.where((tx) => tx['status'] == 'success')
        .fold(0.0, (sum, tx) => sum + (tx['amount'] as double));

    final successCount = _mockTransactions.where((tx) => tx['status'] == 'success').length;
    final failedCount = _mockTransactions.where((tx) => tx['status'] == 'failed').length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'إجمالي المبلغ',
              value: '${totalAmount.toStringAsFixed(0)} ريال',
              icon: Icons.monetization_on,
              color: const Color(0xFF28A745),
              isTablet: isTablet,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'ناجحة',
              value: '$successCount',
              icon: Icons.check_circle,
              color: const Color(0xFF00F5FF),
              isTablet: isTablet,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'فاشلة',
              value: '$failedCount',
              icon: Icons.error,
              color: const Color(0xFFDC3545),
              isTablet: isTablet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isTablet,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: isTablet ? 28 : 24,
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    color: Colors.white70,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilters(bool isTablet) {
    final filterNames = {
      'all': 'الكل',
      'network_recharge': 'شحن واي فاي',
      'electricity_payment': 'كهرباء',
      'water_payment': 'مياه',
      'school_payment': 'مدارس',
      'wallet_charge': 'شحن محفظة',
    };

    return Container(
      margin: EdgeInsets.all(isTablet ? 32 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تصفية النتائج',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 20 : 16,
                      vertical: isTablet ? 12 : 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                        colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
                      )
                          : null,
                      color: isSelected ? null : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : const Color(0xFF00F5FF).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      filterNames[filter] ?? filter,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: isSelected ? Colors.black : const Color(0xFF00F5FF),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(bool isTablet) {
    final transactions = _filteredTransactions;

    if (transactions.isEmpty) {
      return _buildEmptyState(isTablet);
    }

    return AnimatedBuilder(
      animation: _listAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _listAnimation.value) * 50),
          child: Opacity(
            opacity: _listAnimation.value,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _buildTransactionCard(transaction, isTablet, index);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction, bool isTablet, int index) {
    final isSuccess = transaction['status'] == 'success';
    final amount = transaction['amount'] as double;
    final date = transaction['date'] as DateTime;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (transaction['color'] as Color).withOpacity(0.2),
            (transaction['color'] as Color).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (transaction['color'] as Color).withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showTransactionDetails(transaction);
          },
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Row(
              children: [
                Container(
                  width: isTablet ? 50 : 44,
                  height: isTablet ? 50 : 44,
                  decoration: BoxDecoration(
                    color: (transaction['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    transaction['icon'] as IconData,
                    color: transaction['color'] as Color,
                    size: isTablet ? 28 : 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction['title'] as String,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(date),
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          color: Colors.white70,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${amount.toStringAsFixed(0)} ريال',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        color: isSuccess ? const Color(0xFF28A745) : const Color(0xFFDC3545),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSuccess
                            ? const Color(0xFF28A745).withOpacity(0.2)
                            : const Color(0xFFDC3545).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isSuccess ? 'ناجحة' : 'فاشلة',
                        style: TextStyle(
                          fontSize: isTablet ? 10 : 8,
                          color: isSuccess ? const Color(0xFF28A745) : const Color(0xFFDC3545),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
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

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _sparkleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_sparkleAnimation.value * 0.1),
                child: Icon(
                  Icons.history,
                  size: isTablet ? 80 : 64,
                  color: Colors.white30,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد معاملات',
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ أول عملية دفع لترى سجل المعاملات هنا',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.white54,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A2E).withOpacity(0.95),
              const Color(0xFF16213E).withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (transaction['color'] as Color).withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تفاصيل المعاملة',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('العملية', transaction['title'] as String),
            _buildDetailRow('المبلغ', '${(transaction['amount'] as double).toStringAsFixed(0)} ريال'),
            _buildDetailRow('التاريخ', _formatDate(transaction['date'] as DateTime)),
            _buildDetailRow('الحالة', transaction['status'] == 'success' ? 'ناجحة' : 'فاشلة'),
            _buildDetailRow('رقم المعاملة', transaction['id'] as String),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontFamily: 'Cairo',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'من�� ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
            Color(0xFF0F3460),
          ],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00F5FF)),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF1A1A2E),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'خطأ في تحميل البيانات',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painters for transaction screen effects
class TransactionBackgroundPainter extends CustomPainter {
  final double animationValue;

  TransactionBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF00F5FF).withOpacity(0.1);

    // Draw transaction flow patterns
    for (int i = 0; i < 15; i++) {
      final progress = (animationValue + i * 0.1) % 1.0;
      final startX = size.width * 0.1;
      final endX = size.width * 0.9;
      final x = startX + (endX - startX) * progress;
      final y = size.height * 0.3 + math.sin(progress * 4 * math.pi) * 30;

      canvas.drawCircle(
        Offset(x, y),
        2 + math.sin(progress * 6 * math.pi) * 1,
        paint,
      );

      // Draw connecting lines
      if (progress > 0.1) {
        final prevX = startX + (endX - startX) * (progress - 0.1);
        final prevY = size.height * 0.3 + math.sin((progress - 0.1) * 4 * math.pi) * 30;
        canvas.drawLine(
          Offset(prevX, prevY),
          Offset(x, y),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(TransactionBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class TransactionParticlesPainter extends CustomPainter {
  final double animationValue;

  TransactionParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF9B59B6).withOpacity(0.4);

    // Draw transaction data particles
    for (int i = 0; i < 25; i++) {
      final x = (size.width * math.Random(i).nextDouble()) +
          (math.sin(animationValue * 2 * math.pi + i) * 10);
      final y = (size.height * math.Random(i + 30).nextDouble()) +
          (math.cos(animationValue * 2 * math.pi + i) * 8);

      canvas.drawCircle(
        Offset(x, y),
        1 + (math.sin(animationValue * 3 * math.pi + i) * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(TransactionParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
