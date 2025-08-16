import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/responsive_utils.dart';
import '../home/futuristic_dashboard_screen.dart';

class TransactionResultScreen extends StatefulWidget {
  static const String routeName = '/transaction-result';

  const TransactionResultScreen({super.key});

  @override
  State<TransactionResultScreen> createState() => _TransactionResultScreenState();
}

class _TransactionResultScreenState extends State<TransactionResultScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _sparkleController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _sparkleAnimation;

  bool _isSuccess = true;
  String _title = '';
  double _amount = 0.0;
  String _type = '';
  Map<String, dynamic>? _details;

  @override
  void initState() {
    super.initState();
    AppLogger.logScreenEntry('TransactionResult');
    _setupAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _isSuccess = args['success'] ?? true;
      _title = args['title'] ?? '';
      _amount = args['amount'] ?? 0.0;
      _type = args['type'] ?? '';
      _details = args['details'];
    }
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 1.0, curve: Curves.bounceOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
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
    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _sparkleController.repeat(reverse: true);
    
    // Add haptic feedback for success
    if (_isSuccess) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          if (_isSuccess) _buildSuccessParticles(),
          SafeArea(
            child: AnimatedBuilder(
              animation: _fadeInAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeInAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: _buildContent(context, isTablet),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    final colors = _isSuccess
        ? [
            const Color(0xFF0A0A0A),
            const Color(0xFF1A3E1A),
            const Color(0xFF2E4E2E),
            const Color(0xFF1A5A1A),
          ]
        : [
            const Color(0xFF0A0A0A),
            const Color(0xFF3E1A1A),
            const Color(0xFF4E2E2E),
            const Color(0xFF5A1A1A),
          ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: ResultBackgroundPainter(
              _rotationAnimation.value,
              _isSuccess,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildSuccessParticles() {
    return AnimatedBuilder(
      animation: _sparkleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: SuccessParticlesPainter(_sparkleAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, bool isTablet) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildResultIcon(isTablet),
            const SizedBox(height: 32),
            _buildResultTitle(isTablet),
            const SizedBox(height: 16),
            _buildAmountDisplay(isTablet),
            const SizedBox(height: 32),
            _buildDetailsCard(isTablet),
            const SizedBox(height: 40),
            _buildActionButtons(context, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildResultIcon(bool isTablet) {
    final color = _isSuccess ? const Color(0xFF28A745) : const Color(0xFFDC3545);
    final icon = _isSuccess ? Icons.check_circle : Icons.error;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: isTablet ? 120 : 100,
                  height: isTablet ? 120 : 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withOpacity(0.8),
                        color.withOpacity(0.4),
                        color.withOpacity(0.1),
                      ],
                      stops: const [0.0, 0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: isTablet ? 60 : 50,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildResultTitle(bool isTablet) {
    return Text(
      _title.isNotEmpty ? _title : (_isSuccess ? 'تمت العملية بنجا��' : 'فشلت العملية'),
      style: TextStyle(
        fontSize: isTablet ? 28 : 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: 'Cairo',
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAmountDisplay(bool isTablet) {
    if (_amount <= 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 20,
        vertical: isTablet ? 16 : 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isSuccess
              ? [
                  const Color(0xFF28A745).withOpacity(0.2),
                  const Color(0xFF20C997).withOpacity(0.1),
                ]
              : [
                  const Color(0xFFDC3545).withOpacity(0.2),
                  const Color(0xFFFF6B6B).withOpacity(0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isSuccess 
              ? const Color(0xFF28A745).withOpacity(0.3)
              : const Color(0xFFDC3545).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.monetization_on,
            color: _isSuccess ? const Color(0xFF28A745) : const Color(0xFFDC3545),
            size: isTablet ? 24 : 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${_amount.toStringAsFixed(0)} ريال',
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: _isSuccess ? const Color(0xFF28A745) : const Color(0xFFDC3545),
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(bool isTablet) {
    if (_details == null || _details!.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل العملية',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          ..._buildDetailItems(isTablet),
        ],
      ),
    );
  }

  List<Widget> _buildDetailItems(bool isTablet) {
    final items = <Widget>[];
    
    _details!.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        final label = _getDetailLabel(key);
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.white70,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Cairo',
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });

    // Add transaction type
    items.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'نوع العملية',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: Colors.white70,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                _getTransactionTypeName(_type),
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );

    // Add timestamp
    items.add(
      Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'وقت العملية',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.white70,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _formatCurrentTime(),
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );

    return items;
  }

  String _getDetailLabel(String key) {
    switch (key) {
      case 'account':
        return 'رقم الحساب';
      case 'student_id':
        return 'رقم الطالب';
      case 'student_name':
        return 'اسم الطالب';
      case 'region':
        return 'المنطقة';
      case 'company':
        return 'الشركة';
      case 'school':
        return 'المدرسة';
      case 'payment_type':
        return 'نوع الرسوم';
      case 'method':
        return 'طريقة الدفع';
      default:
        return key;
    }
  }

  String _getTransactionTypeName(String type) {
    switch (type) {
      case 'wallet_charge':
        return 'شحن المحفظة';
      case 'electricity_payment':
        return 'دفع فاتورة الكهرباء';
      case 'water_payment':
        return 'دفع فاتورة المياه';
      case 'school_payment':
        return 'دفع رسوم المدرسة';
      case 'network_recharge':
        return 'شحن كروت الشبكة';
      default:
        return 'عملية أخرى';
    }
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} - ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildActionButtons(BuildContext context, bool isTablet) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F5FF).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        FuturisticDashboardScreen.routeName,
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'العودة للرئيسية',
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        if (_isSuccess) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Share or download receipt functionality
                _showShareOptions(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                ),
                padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.share,
                    size: isTablet ? 24 : 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'مشاركة الإيصال',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A2E).withOpacity(0.9),
              const Color(0xFF16213E).withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00F5FF).withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'مشاركة الإيصال',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  Icons.file_download,
                  'تحميل PDF',
                  () {
                    Navigator.pop(context);
                    // Implement PDF download
                  },
                ),
                _buildShareOption(
                  Icons.share,
                  'مشاركة',
                  () {
                    Navigator.pop(context);
                    // Implement share functionality
                  },
                ),
                _buildShareOption(
                  Icons.print,
                  'طباعة',
                  () {
                    Navigator.pop(context);
                    // Implement print functionality
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00F5FF).withOpacity(0.2),
              border: Border.all(
                color: const Color(0xFF00F5FF),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF00F5FF),
              size: 25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painters for result screen effects
class ResultBackgroundPainter extends CustomPainter {
  final double animationValue;
  final bool isSuccess;

  ResultBackgroundPainter(this.animationValue, this.isSuccess);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = (isSuccess ? const Color(0xFF28A745) : const Color(0xFFDC3545))
          .withOpacity(0.1);

    // Draw result pattern
    for (int i = 0; i < 15; i++) {
      final offset = Offset(
        (size.width * 0.1 * i) + (animationValue * 30),
        (size.height * 0.1 * i) + (animationValue * 20),
      );

      if (isSuccess) {
        // Draw success checkmark patterns
        canvas.drawPath(
          Path()
            ..moveTo(offset.dx, offset.dy)
            ..lineTo(offset.dx + 10, offset.dy + 10)
            ..lineTo(offset.dx + 20, offset.dy - 5),
          paint,
        );
      } else {
        // Draw error X patterns
        canvas.drawLine(
          offset,
          Offset(offset.dx + 15, offset.dy + 15),
          paint,
        );
        canvas.drawLine(
          Offset(offset.dx + 15, offset.dy),
          Offset(offset.dx, offset.dy + 15),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ResultBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class SuccessParticlesPainter extends CustomPainter {
  final double animationValue;

  SuccessParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF28A745).withOpacity(0.6);

    // Draw success confetti
    for (int i = 0; i < 50; i++) {
      final x = (size.width * math.Random(i).nextDouble()) + 
               (math.sin(animationValue * 2 * math.pi + i) * 20);
      final y = (size.height * math.Random(i + 100).nextDouble()) + 
               (math.cos(animationValue * 2 * math.pi + i) * 15);

      canvas.drawCircle(
        Offset(x, y),
        1 + (math.sin(animationValue * 4 * math.pi + i) * 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SuccessParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
