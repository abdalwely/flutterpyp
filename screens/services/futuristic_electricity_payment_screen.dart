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

class FuturisticElectricityPaymentScreen extends ConsumerStatefulWidget {
  static const String routeName = '/futuristic-electricity-payment';

  const FuturisticElectricityPaymentScreen({super.key});

  @override
  ConsumerState<FuturisticElectricityPaymentScreen> createState() =>
      _FuturisticElectricityPaymentScreenState();
}

class _FuturisticElectricityPaymentScreenState
    extends ConsumerState<FuturisticElectricityPaymentScreen>
    with TickerProviderStateMixin {

  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _sparkleController;
  late AnimationController _lightningController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _lightningAnimation;

  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  String _selectedRegion = 'sanaa';
  String _selectedAmount = '';

  final List<String> _quickAmounts = [
    '500', '1000', '2000', '3000', '5000', '10000'
  ];

  final List<Map<String, dynamic>> _regions = [
    {
      'id': 'sanaa',
      'name': 'صنعاء',
      'company': 'الشركة العامة للكهرباء',
      'icon': Icons.location_city,
      'color': AppTheme.accentColor,
    },
    {
      'id': 'aden',
      'name': 'عدن',
      'company': 'كهرباء عدن',
      'icon': Icons.apartment,
      'color': AppTheme.infoColor,
    },
    {
      'id': 'taiz',
      'name': 'تعز',
      'company': 'كهرباء تعز',
      'icon': Icons.business,
      'color': AppTheme.successColor,
    },
    {
      'id': 'hodeidah',
      'name': 'الحديدة',
      'company': 'كهرباء الحديدة',
      'icon': Icons.factory,
      'color': AppTheme.warningColor,
    },
  ];

  @override
  void initState() {
    super.initState();
    AppLogger.logScreenEntry('FuturisticElectricityPayment');
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

    _lightningController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    _lightningAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lightningController, curve: Curves.elasticOut),
    );

    _startAnimations();
  }

  void _startAnimations() {
    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _sparkleController.repeat(reverse: true);
    _lightningController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _sparkleController.dispose();
    _lightningController.dispose();
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
      // محاكاة عملية دفع الكهرباء
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
            'title': 'تم دفع فاتورة الكهرباء بنجاح',
            'amount': amount,
            'type': 'electricity_payment',
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
                _buildFloatingParticles(),
                _buildLightningEffects(),
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
        animation: _rotationAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: ElectricBackgroundPainter(_rotationAnimation.value),
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
          painter: ElectricParticlesPainter(_sparkleAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildLightningEffects() {
    return AnimatedBuilder(
      animation: _lightningAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: LightningEffectsPainter(_lightningAnimation.value),
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
                  color: AppTheme.accentColor.withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppTheme.accentColor,
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
                  'دفع فاتورة الكهرباء',
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
            animation: _lightningAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_lightningAnimation.value * 0.2),
                child: Container(
                  width: isTablet ? 50 : 44,
                  height: isTablet ? 50 : 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.accentColor, AppTheme.warningColor],
                    ),
                    borderRadius: AppTheme.smallRadius,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentColor.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.bolt,
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
                    AppTheme.accentColor.withOpacity(0.2),
                    AppTheme.warningColor.withOpacity(0.1),
                    AppTheme.errorColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: AppTheme.largeRadius,
                border: Border.all(
                  color: AppTheme.accentColor.withOpacity(0.3),
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
                        color: AppTheme.accentColor,
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
                      color: AppTheme.accentColor,
                      fontFamily: 'Cairo',
                      shadows: [
                        Shadow(
                          color: AppTheme.accentColor.withOpacity(0.5),
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
              'رقم الحساب',
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
          color: AppTheme.accentColor.withOpacity(0.3),
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
          hintText: 'أدخل رقم الحساب',
          hintStyle: TextStyle(
            color: AppTheme.textHint,
            fontFamily: 'Cairo',
          ),
          prefixIcon: Icon(
            Icons.electric_meter,
            color: AppTheme.accentColor,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'يرجى إدخال رقم الحساب';
          }
          if (value.length < 6) {
            return 'رقم الحساب يجب أن يكون 6 أرقام على الأقل';
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
                colors: [AppTheme.accentColor, AppTheme.warningColor],
              )
                  : null,
              color: isSelected ? null : AppTheme.surfaceColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : AppTheme.accentColor.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: isSelected ? AppTheme.cardShadow : null,
            ),
            child: Text(
              '$amount ريال',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: isSelected ? AppTheme.textPrimary : AppTheme.accentColor,
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
          color: AppTheme.accentColor.withOpacity(0.3),
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
            color: AppTheme.accentColor,
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
          if (amount < 100) {
            return 'الحد الأدنى 100 ريال';
          }
          if (amount > 50000) {
            return 'الحد الأقصى 50,000 ريال';
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
        animation: _lightningAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_lightningAnimation.value * 0.05),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.accentColor, AppTheme.warningColor],
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
                      Icons.bolt,
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
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
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

// Custom painters for electric effects
class ElectricBackgroundPainter extends CustomPainter {
  final double animationValue;

  ElectricBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppTheme.accentColor.withOpacity(0.1);

    // Draw electric circuit patterns
    for (int i = 0; i < 15; i++) {
      final startX = (size.width * 0.1 * i) + (animationValue * 30);
      final startY = (size.height * 0.1 * i) + (animationValue * 20);

      // Draw lightning-like patterns
      final path = Path();
      path.moveTo(startX, startY);
      path.lineTo(startX + 50, startY + 25);
      path.lineTo(startX + 30, startY + 50);
      path.lineTo(startX + 80, startY + 75);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(ElectricBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class ElectricParticlesPainter extends CustomPainter {
  final double animationValue;

  ElectricParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppTheme.warningColor.withOpacity(0.4);

    // Draw electric sparks
    for (int i = 0; i < 30; i++) {
      final x = (size.width * math.Random(i).nextDouble()) +
          (math.sin(animationValue * 3 * math.pi + i) * 25);
      final y = (size.height * math.Random(i + 50).nextDouble()) +
          (math.cos(animationValue * 3 * math.pi + i) * 20);

      canvas.drawCircle(
        Offset(x, y),
        1.5 + (math.sin(animationValue * 6 * math.pi + i) * 1),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ElectricParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class LightningEffectsPainter extends CustomPainter {
  final double animationValue;

  LightningEffectsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppTheme.accentColor.withOpacity(0.3 * animationValue);

    // Draw occasional lightning bolts
    if (animationValue > 0.7) {
      final path = Path();
      path.moveTo(size.width * 0.2, size.height * 0.1);
      path.lineTo(size.width * 0.3, size.height * 0.3);
      path.lineTo(size.width * 0.1, size.height * 0.4);
      path.lineTo(size.width * 0.25, size.height * 0.6);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(LightningEffectsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
