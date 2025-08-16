import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:ui';

import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/validation/validation_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/localization_provider.dart';
import '../transactions/transaction_result_screen.dart';

class WalletChargeScreen extends ConsumerStatefulWidget {
  static const String routeName = '/wallet-charge';

  const WalletChargeScreen({super.key});

  @override
  ConsumerState<WalletChargeScreen> createState() => _WalletChargeScreenState();
}

class _WalletChargeScreenState extends ConsumerState<WalletChargeScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _sparkleController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _sparkleAnimation;

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  String _selectedMethod = 'card';
  String _selectedAmount = '';

  final List<String> _quickAmounts = [
    '100', '250', '500', '1000', '2000', '5000'
  ];

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'card',
      'title': 'بطاقة ائتمانية',
      'subtitle': 'فيزا أو ماستركارد',
      'icon': Icons.credit_card,
      'color': Color(0xFF00F5FF),
    },
    {
      'id': 'bank',
      'title': 'تحويل بنكي',
      'subtitle': 'من حساب البنك',
      'icon': Icons.account_balance,
      'color': Color(0xFF4ECDC4),
    },
    {
      'id': 'mobile',
      'title': 'محفظة إلكترونية',
      'subtitle': 'يمن موبايل',
      'icon': Icons.phone_android,
      'color': Color(0xFF45B7D1),
    },
    {
      'id': 'voucher',
      'title': 'بطاقة شحن',
      'subtitle': 'رقم سري',
      'icon': Icons.confirmation_number,
      'color': Color(0xFF9B59B6),
    },
  ];

  @override
  void initState() {
    super.initState();
    AppLogger.logScreenEntry('WalletCharge');
    _setupAnimations();
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
    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _sparkleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _sparkleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleQuickAmount(String amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount;
    });
  }

  void _handleCharge() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('يرجى إدخال مبلغ صحيح');
      return;
    }

    if (amount < 10) {
      _showError('الحد الأدنى للشحن 10 ريال');
      return;
    }

    if (amount > 10000) {
      _showError('الحد الأقصى للشحن 10,000 ريال');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // محاكاة عملية الشحن
      await Future.delayed(const Duration(seconds: 2));

      // تحديث الرصيد
      final success = await ref
          .read(authControllerProvider.notifier)
          .addToBalance(amount);

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed(
          TransactionResultScreen.routeName,
          arguments: {
            'success': true,
            'title': 'تم شحن المحفظة بنجاح',
            'amount': amount,
            'type': 'wallet_charge',
            'details': {
              'method': _getPaymentMethodTitle(_selectedMethod),
            },
          },
        );
      } else {
        _showError('حدث خطأ في عملية الشحن');
      }
    } catch (e) {
      _showError('حدث خطأ: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getPaymentMethodTitle(String methodId) {
    final method = _paymentMethods.firstWhere(
          (m) => m['id'] == methodId,
      orElse: () => {'title': 'غير محدد'},
    );
    return method['title'] as String;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(context, isTablet),
                        _buildCurrentBalance(user, isTablet),
                        _buildChargeForm(isTablet),
                        const SizedBox(height: 100),
                      ],
                    ),
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
                color: Colors.lightBlue.withOpacity(0.1),
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
                  'شحن المحفظة',
                  style: TextStyle(
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  'أضف رصيد إلى محفظتك',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.lightBlue,
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
                      colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
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

  Widget _buildCurrentBalance(user, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
      child: AnimatedBuilder(
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
                    const Color(0xFF00F5FF).withOpacity(0.2),
                    const Color(0xFF0080FF).withOpacity(0.1),
                    const Color(0xFF8000FF).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00F5FF).withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F5FF).withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'الرصيد الحالي',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      color: Colors.lightBlue,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${user?.balance?.toStringAsFixed(0) ?? '0'} ريال',
                    style: TextStyle(
                      fontSize: isTablet ? 36 : 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00F5FF),
                      fontFamily: 'Cairo',
                      shadows: [
                        Shadow(
                          color: const Color(0xFF00F5FF).withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChargeForm(bool isTablet) {
    return Container(
      margin: EdgeInsets.all(isTablet ? 32 : 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Quick amount selection
            Text(
              'اختر المبلغ',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickAmounts(isTablet),

            const SizedBox(height: 24),

            // Custom amount input
            Text(
              'أو أدخل مبلغ مخصص',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: Colors.lightBlue,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 12),
            _buildAmountInput(isTablet),

            const SizedBox(height: 32),

            // Payment method selection
            Text(
              'طريقة الدف��',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethods(isTablet),

            const SizedBox(height: 32),

            // Charge button
            _buildChargeButton(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmounts(bool isTablet) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _quickAmounts.map((amount) {
        final isSelected = _selectedAmount == amount;
        return GestureDetector(
          onTap: () => _handleQuickAmount(amount),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
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
              color: isSelected ? null : Colors.lightBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : const Color(0xFF00F5FF).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: const Color(0xFF00F5FF).withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
                  : null,
            ),
            child: Text(
              '$amount ريال',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: isSelected ? Colors.black : const Color(0xFF00F5FF),
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountInput(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00F5FF).withOpacity(0.3),
        ),
        color: Colors.lightBlue.withOpacity(0.1),
      ),
      child: TextFormField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        style: TextStyle(
          color: Colors.lightBlue,
          fontSize: isTablet ? 18 : 16,
          fontFamily: 'Cairo',
        ),
        decoration: InputDecoration(
          hintText: 'مثال: 1000',
          hintStyle: TextStyle(
            color: Colors.lightBlue,
            fontFamily: 'Cairo',
          ),
          prefixIcon: Icon(
            Icons.monetization_on,
            color: const Color(0xFF00F5FF),
          ),
          suffixText: 'ريال',
          suffixStyle: TextStyle(
            color: Colors.lightBlue,
            fontFamily: 'Cairo',
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
        ),
        validator: (value) => ValidationService.validateAmount(
          value,
          minAmount: 10,
          maxAmount: 10000,
        ),
        onChanged: (value) {
          setState(() {
            _selectedAmount = value.isEmpty ? '' : value;
          });
        },
      ),
    );
  }

  Widget _buildPaymentMethods(bool isTablet) {
    return Column(
      children: _paymentMethods.map((method) {
        final isSelected = _selectedMethod == method['id'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMethod = method['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                colors: [
                  (method['color'] as Color).withOpacity(0.2),
                  (method['color'] as Color).withOpacity(0.1),
                ],
              )
                  : null,
              color: isSelected ? null : Colors.lightBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? method['color'] as Color
                    : Colors.lightBlue.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: (method['color'] as Color).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: isTablet ? 50 : 44,
                  height: isTablet ? 50 : 44,
                  decoration: BoxDecoration(
                    color: (method['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    method['icon'] as IconData,
                    color: method['color'] as Color,
                    size: isTablet ? 28 : 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method['title'] as String,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        method['subtitle'] as String,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: Colors.lightBlue,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: method['color'] as Color,
                    size: isTablet ? 28 : 24,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChargeButton(bool isTablet) {
    return SizedBox(
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
                onPressed: _isLoading ? null : _handleCharge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                  height: isTablet ? 28 : 24,
                  width: isTablet ? 28 : 24,
                  child: const CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  'شحن المحفظة',
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
    );
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
                color: Colors.lightBlue,
                fontFamily: 'Cairo',
              ),
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
      ..color = const Color(0xFF00F5FF).withOpacity(0.1);

    for (int i = 0; i < 20; i++) {
      final offset = Offset(
        (size.width * 0.1 * i) + (animationValue * 50),
        (size.height * 0.1 * i) + (animationValue * 30),
      );

      canvas.drawCircle(offset, 20 + (animationValue * 10), paint);
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
      ..color = const Color(0xFF00F5FF).withOpacity(0.3);

    for (int i = 0; i < 50; i++) {
      final x = (size.width * math.Random(i).nextDouble()) +
          (math.sin(animationValue * 2 * math.pi + i) * 20);
      final y = (size.height * math.Random(i + 100).nextDouble()) +
          (math.cos(animationValue * 2 * math.pi + i) * 15);

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
