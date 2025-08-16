import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:ui';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/responsive_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/localization_provider.dart';
import '../transactions/transaction_result_screen.dart';

class FuturisticWaterPaymentScreen extends ConsumerStatefulWidget {
  static const String routeName = '/futuristic-water-payment';

  const FuturisticWaterPaymentScreen({super.key});

  @override
  ConsumerState<FuturisticWaterPaymentScreen> createState() =>
      _FuturisticWaterPaymentScreenState();
}

class _FuturisticWaterPaymentScreenState
    extends ConsumerState<FuturisticWaterPaymentScreen>
    with TickerProviderStateMixin {

  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _sparkleController;
  late AnimationController _bubbleController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _bubbleAnimation;

  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  String _selectedRegion = 'sanaa';
  String _selectedAmount = '';

  final List<String> _quickAmounts = [
    '300', '500', '1000', '1500', '2000', '3000'
  ];

  final List<Map<String, dynamic>> _regions = [
    {
      'id': 'sanaa',
      'name': 'صنعاء',
      'company': 'مؤسسة المياه والصرف الصحي',
      'icon': Icons.water_drop,
      'color': AppTheme.infoColor,
    },
    {
      'id': 'aden',
      'name': 'عدن',
      'company': 'مياه عدن',
      'icon': Icons.waves,
      'color': AppTheme.secondaryColor,
    },
    {
      'id': 'taiz',
      'name': 'تعز',
      'company': 'مياه تعز',
      'icon': Icons.water,
      'color': AppTheme.primaryColor,
    },
    {
      'id': 'hodeidah',
      'name': 'الحديدة',
      'company': 'مياه الحديدة',
      'icon': Icons.pool,
      'color': AppTheme.successColor,
    },
  ];

  @override
  void initState() {
    super.initState();
    AppLogger.logScreenEntry('FuturisticWaterPayment');
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

    _waveController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
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

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );

    _bubbleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.linear),
    );

    _startAnimations();
  }

  void _startAnimations() {
    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _waveController.repeat();
    _sparkleController.repeat(reverse: true);
    _bubbleController.repeat();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _sparkleController.dispose();
    _bubbleController.dispose();
    _accountController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleQuickAmount(String amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount;
    });
  }

  void _handlePayment() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('يرجى إدخال مبلغ صحيح');
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      _showError('يرجى تسجيل الدخول أولاً');
      return;
    }

    if (user.balance < amount) {
      _showError('الرصيد غير كافي. رصيدك الحالي: ${user.balance.toStringAsFixed(0)} ريال');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // محاكاة عملية دفع فاتورة المياه
      await Future.delayed(const Duration(seconds: 3));

      // خصم المبلغ من الرصيد
      final success = await ref
          .read(authControllerProvider.notifier)
          .deductFromBalance(amount);

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed(
          TransactionResultScreen.routeName,
          arguments: {
            'success': true,
            'title': 'تم دفع فاتورة المياه بنجاح',
            'amount': amount,
            'type': 'water_payment',
            'details': {
              'account': _accountController.text,
              'region': _getRegionName(_selectedRegion),
              'company': _getRegionCompany(_selectedRegion),
            },
          },
        );
      } else {
        _showError('حدث خطأ في عملية الدفع');
      }
    } catch (e) {
      _showError('حدث خطأ: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getRegionName(String regionId) {
    final region = _regions.firstWhere(
          (r) => r['id'] == regionId,
      orElse: () => {'name': 'غير محدد'},
    );
    return region['name'] as String;
  }

  String _getRegionCompany(String regionId) {
    final region = _regions.firstWhere(
          (r) => r['id'] == regionId,
      orElse: () => {'company': 'غير محدد'},
    );
    return region['company'] as String;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
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
      backgroundColor: AppTheme.backgroundColor,
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
                _buildFloatingBubbles(),
                _buildWaveEffects(),
                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(context, isTablet),
                        _buildCurrentBalance(user, isTablet),
                        _buildPaymentForm(isTablet),
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
            AppTheme.primaryDarkColor,
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
            AppTheme.primaryLightColor,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: AnimatedBuilder(
        animation: _waveAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: WaterBackgroundPainter(_waveAnimation.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildFloatingBubbles() {
    return AnimatedBuilder(
      animation: _bubbleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: BubblesPainter(_bubbleAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildWaveEffects() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: WaveEffectsPainter(_waveAnimation.value),
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
                color: AppTheme.surfaceColor.withOpacity(0.1),
                borderRadius: AppTheme.smallRadius,
                border: Border.all(
                  color: AppTheme.infoColor.withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppTheme.infoColor,
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
                  'دفع فاتورة المياه',
                  style: TextStyle(
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textOnPrimary,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  'دفع فوري وآمن',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: AppTheme.textSecondary,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _bubbleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (math.sin(_bubbleAnimation.value * 2 * math.pi) * 0.1),
                child: Container(
                  width: isTablet ? 50 : 44,
                  height: isTablet ? 50 : 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.infoColor, AppTheme.secondaryColor],
                    ),
                    borderRadius: AppTheme.smallRadius,
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Icon(
                    Icons.water_drop,
                    color: AppTheme.textPrimary,
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
                    AppTheme.infoColor.withOpacity(0.2),
                    AppTheme.secondaryColor.withOpacity(0.1),
                    AppTheme.primaryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: AppTheme.largeRadius,
                border: Border.all(
                  color: AppTheme.infoColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: AppTheme.infoColor,
                        size: isTablet ? 24 : 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'رصيدك المتاح',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          color: AppTheme.textSecondary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${user?.balance?.toStringAsFixed(0) ?? '0'} ريال',
                    style: TextStyle(
                      fontSize: isTablet ? 36 : 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.infoColor,
                      fontFamily: 'Cairo',
                      shadows: [
                        Shadow(
                          color: AppTheme.infoColor.withOpacity(0.5),
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

  Widget _buildPaymentForm(bool isTablet) {
    return Container(
      margin: EdgeInsets.all(isTablet ? 32 : 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Region selection
            Text(
              'اختر المنطقة',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textOnPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 16),
            _buildRegionSelection(isTablet),

            const SizedBox(height: 24),

            // Account number input
            Text(
              'رقم العداد',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: AppTheme.textSecondary,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 12),
            _buildAccountInput(isTablet),

            const SizedBox(height: 24),

            // Amount selection
            Text(
              'المبلغ المطلوب',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textOnPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickAmounts(isTablet),

            const SizedBox(height: 16),
            _buildAmountInput(isTablet),

            const SizedBox(height: 32),

            // Payment button
            _buildPaymentButton(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionSelection(bool isTablet) {
    return Column(
      children: _regions.map((region) {
        final isSelected = _selectedRegion == region['id'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedRegion = region['id'] as String;
            });
          },
          child: AnimatedContainer(
            duration: AppTheme.animationNormal,
            margin: const EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                colors: [
                  (region['color'] as Color).withOpacity(0.2),
                  (region['color'] as Color).withOpacity(0.1),
                ],
              )
                  : null,
              color: isSelected ? null : AppTheme.surfaceColor.withOpacity(0.05),
              borderRadius: AppTheme.mediumRadius,
              border: Border.all(
                color: isSelected
                    ? region['color'] as Color
                    : AppTheme.borderColor,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? AppTheme.cardShadow : null,
            ),
            child: Row(
              children: [
                Container(
                  width: isTablet ? 50 : 44,
                  height: isTablet ? 50 : 44,
                  decoration: BoxDecoration(
                    color: (region['color'] as Color).withOpacity(0.2),
                    borderRadius: AppTheme.smallRadius,
                  ),
                  child: Icon(
                    region['icon'] as IconData,
                    color: region['color'] as Color,
                    size: isTablet ? 28 : 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        region['name'] as String,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textOnPrimary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        region['company'] as String,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: AppTheme.textSecondary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: region['color'] as Color,
                    size: isTablet ? 28 : 24,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccountInput(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppTheme.mediumRadius,
        border: Border.all(
          color: AppTheme.infoColor.withOpacity(0.3),
        ),
        color: AppTheme.surfaceColor.withOpacity(0.1),
      ),
      child: TextFormField(
        controller: _accountController,
        keyboardType: TextInputType.number,
        style: TextStyle(
          color: AppTheme.textOnPrimary,
          fontSize: isTablet ? 18 : 16,
          fontFamily: 'Cairo',
        ),
        decoration: InputDecoration(
          hintText: 'أدخل رقم العداد',
          hintStyle: TextStyle(
            color: AppTheme.textHint,
            fontFamily: 'Cairo',
          ),
          prefixIcon: Icon(
            Icons.speed,
            color: AppTheme.infoColor,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'يرجى إدخال رقم العداد';
          }
          if (value.length < 6) {
            return 'رقم العداد يجب أن يكون 6 أرقام على الأقل';
          }
          return null;
        },
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
            duration: AppTheme.animationNormal,
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20 : 16,
              vertical: isTablet ? 12 : 10,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                colors: [AppTheme.infoColor, AppTheme.secondaryColor],
              )
                  : null,
              color: isSelected ? null : AppTheme.surfaceColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : AppTheme.infoColor.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: isSelected ? AppTheme.cardShadow : null,
            ),
            child: Text(
              '$amount ريال',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: isSelected ? AppTheme.textPrimary : AppTheme.infoColor,
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
        borderRadius: AppTheme.mediumRadius,
        border: Border.all(
          color: AppTheme.infoColor.withOpacity(0.3),
        ),
        color: AppTheme.surfaceColor.withOpacity(0.1),
      ),
      child: TextFormField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        style: TextStyle(
          color: AppTheme.textOnPrimary,
          fontSize: isTablet ? 18 : 16,
          fontFamily: 'Cairo',
        ),
        decoration: InputDecoration(
          hintText: 'أو أدخل مبلغ مخصص',
          hintStyle: TextStyle(
            color: AppTheme.textHint,
            fontFamily: 'Cairo',
          ),
          prefixIcon: Icon(
            Icons.monetization_on,
            color: AppTheme.infoColor,
          ),
          suffixText: 'ريال',
          suffixStyle: TextStyle(
            color: AppTheme.textSecondary,
            fontFamily: 'Cairo',
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'يرجى إدخال المبلغ';
          }
          final amount = double.tryParse(value);
          if (amount == null) {
            return 'يرجى إدخال رقم صحيح';
          }
          if (amount < 50) {
            return 'الحد الأدنى 50 ريال';
          }
          if (amount > 20000) {
            return 'الحد الأقصى 20,000 ريال';
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            _selectedAmount = value.isEmpty ? '' : value;
          });
        },
      ),
    );
  }

  Widget _buildPaymentButton(bool isTablet) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _waveAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (math.sin(_waveAnimation.value * 2 * math.pi) * 0.02),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.infoColor, AppTheme.secondaryColor],
                ),
                borderRadius: AppTheme.mediumRadius,
                boxShadow: AppTheme.cardShadow,
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.mediumRadius,
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                  height: isTablet ? 28 : 24,
                  width: isTablet ? 28 : 24,
                  child: CircularProgressIndicator(
                    color: AppTheme.textPrimary,
                    strokeWidth: 2,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.water_drop,
                      color: AppTheme.textPrimary,
                      size: isTablet ? 24 : 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'دفع الفاتورة',
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
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
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.infoColor),
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
          ],
        ),
      ),
    );
  }
}

// Custom painters for water effects
class WaterBackgroundPainter extends CustomPainter {
  final double animationValue;

  WaterBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppTheme.infoColor.withOpacity(0.1);

    // Draw water wave patterns
    for (int i = 0; i < 20; i++) {
      final path = Path();
      final startY = size.height * 0.1 * i + (animationValue * 50);

      path.moveTo(0, startY);
      for (double x = 0; x <= size.width; x += 20) {
        final y = startY + math.sin((x / 50) + (animationValue * 2 * math.pi)) * 10;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WaterBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class BubblesPainter extends CustomPainter {
  final double animationValue;

  BubblesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppTheme.infoColor.withOpacity(0.3);

    // Draw floating bubbles
    for (int i = 0; i < 30; i++) {
      final x = (size.width * math.Random(i).nextDouble());
      final y = (size.height * math.Random(i + 50).nextDouble()) -
          (animationValue * size.height * 0.5);

      final radius = 2 + math.Random(i + 100).nextDouble() * 8;

      canvas.drawCircle(
        Offset(x, y % size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BubblesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class WaveEffectsPainter extends CustomPainter {
  final double animationValue;

  WaveEffectsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppTheme.secondaryColor.withOpacity(0.2);

    // Draw wave ripples
    for (int i = 0; i < 5; i++) {
      final centerX = size.width * 0.5;
      final centerY = size.height * 0.7;
      final radius = (animationValue * 200) + (i * 40);

      canvas.drawCircle(
        Offset(centerX, centerY),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveEffectsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
