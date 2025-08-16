import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../transactions/transaction_result_screen.dart';

class FuturisticNetworkRechargeScreen extends ConsumerStatefulWidget {
  static const String routeName = '/futuristic-network-recharge';

  const FuturisticNetworkRechargeScreen({super.key});

  @override
  ConsumerState<FuturisticNetworkRechargeScreen> createState() => _FuturisticNetworkRechargeScreenState();
}

class _FuturisticNetworkRechargeScreenState extends ConsumerState<FuturisticNetworkRechargeScreen>
    with TickerProviderStateMixin {

  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late AnimationController _scanController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _scanAnimation;

  final TextEditingController _phoneController = TextEditingController();
  String? selectedProvider;
  int? selectedValue;
  bool isLoading = false;

  final List<Map<String, dynamic>> providers = [
    {
      'name': 'يمن موبايل',
      'icon': Icons.sim_card,
      'color': AppTheme.primaryColor,
      'gradient': [AppTheme.primaryColor, AppTheme.primaryLightColor],
    },
    {
      'name': 'سبأفون',
      'icon': Icons.cell_tower,
      'color': AppTheme.successColor,
      'gradient': [AppTheme.successColor, AppTheme.successLightColor],
    },
    {
      'name': 'YOU',
      'icon': Icons.network_cell,
      'color': AppTheme.accentColor,
      'gradient': [AppTheme.accentColor, AppTheme.accentLightColor],
    },
    {
      'name': 'واي',
      'icon': Icons.wifi,
      'color': AppTheme.warningColor,
      'gradient': [AppTheme.warningColor, AppTheme.warningLightColor],
    },
  ];

  final List<int> values = [500, 1000, 2000, 5000, 10000, 20000];

  @override
  void initState() {
    super.initState();
    print('🚀 [FuturisticNetworkRecharge] Initializing animations...');

    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scanController = AnimationController(
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

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    print('✨ [FuturisticNetworkRecharge] Starting animations...');
    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _rippleController.repeat();
    _scanController.repeat();
  }

  @override
  void dispose() {
    print('🔄 [FuturisticNetworkRecharge] Disposing animations...');
    _mainController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    _scanController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;

    print('🎨 [FuturisticNetworkRecharge] Building UI...');

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: AnimatedBuilder(
        animation: _fadeInAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeInAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Stack(
                children: [
                  // Animated background
                  _buildAnimatedBackground(),

                  // Scanning overlay
                  _buildScanningOverlay(),

                  // Main content
                  SafeArea(
                    child: Column(
                      children: [
                        // Custom app bar
                        _buildCustomAppBar(context, isTablet),

                        // Scrollable content
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.all(isTablet ? 32 : 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Phone number input
                                _buildPhoneInput(context, isTablet),

                                const SizedBox(height: 30),

                                // Provider selection
                                _buildProviderSelection(context, isTablet),

                                const SizedBox(height: 30),

                                // Amount selection
                                _buildAmountSelection(context, isTablet),

                                const SizedBox(height: 40),

                                // Recharge button
                                _buildRechargeButton(context, isTablet),
                              ],
                            ),
                          ),
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
        ),
      ),
      child: AnimatedBuilder(
        animation: _rippleAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: NetworkBackgroundPainter(_rippleAnimation.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ScannerPainter(_scanAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildCustomAppBar(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      child: Row(
        children: [
          // Back button with glow effect
          GestureDetector(
            onTap: () {
              print('🔄 [FuturisticNetworkRecharge] Navigating back...');
              Navigator.of(context).pop();
            },
            child: Container(
              width: isTablet ? 50 : 45,
              height: isTablet ? 50 : 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
                boxShadow: AppTheme.cardShadow,
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppTheme.textPrimary,
                size: isTablet ? 24 : 20,
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Title with animation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Text(
                        'شحن الواي فاي',
                        style: TextStyle(
                          fontSize: isTablet ? 28 : 24,
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
                    );
                  },
                ),
                Text(
                  'شحن فوري لجميع الشبكات',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: AppTheme.textSecondary,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),

          // WiFi icon with rotation
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _scanAnimation.value * 2 * math.pi,
                child: Container(
                  width: isTablet ? 50 : 45,
                  height: isTablet ? 50 : 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.wifi,
                    color: AppTheme.primaryColor,
                    size: isTablet ? 25 : 22,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رقم الهاتف',
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textOnPrimary,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.1),
                AppTheme.secondaryColor.withOpacity(0.05),
              ],
            ),
            borderRadius: AppTheme.largeRadius,
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: AppTheme.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: AppTheme.largeRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  color: AppTheme.textOnPrimary,
                  fontFamily: 'Cairo',
                ),
                decoration: InputDecoration(
                  hintText: '77xxxxxxx',
                  hintStyle: TextStyle(
                    color: AppTheme.textHint,
                    fontSize: isTablet ? 18 : 16,
                    fontFamily: 'Cairo',
                  ),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.phone,
                      color: AppTheme.primaryColor,
                      size: isTablet ? 24 : 20,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 20,
                    vertical: isTablet ? 20 : 16,
                  ),
                ),
                onChanged: (value) {
                  print('📱 [FuturisticNetworkRecharge] Phone number entered: $value');
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderSelection(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'اختر الشبكة',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textOnPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            const Spacer(),
            if (selectedProvider != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.successColor),
                ),
                child: Text(
                  'تم الاختيار',
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: providers.length,
          itemBuilder: (context, index) {
            final provider = providers[index];
            final isSelected = selectedProvider == provider['name'];

            return GestureDetector(
              onTap: () {
                print('📡 [FuturisticNetworkRecharge] Provider selected: ${provider['name']}');
                setState(() {
                  selectedProvider = provider['name'];
                });
                _pulseController.forward().then((_) {
                  _pulseController.reverse();
                });
              },
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final scale = isSelected ? _pulseAnimation.value : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? provider['gradient'] as List<Color>
                              : [
                            (provider['color'] as Color).withOpacity(0.2),
                            (provider['color'] as Color).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: AppTheme.largeRadius,
                        border: Border.all(
                          color: provider['color'] as Color,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected ? AppTheme.cardShadow : [],
                      ),
                      child: ClipRRect(
                        borderRadius: AppTheme.largeRadius,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: EdgeInsets.all(isTablet ? 20 : 16),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor.withOpacity(0.05),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: isTablet ? 40 : 35,
                                  height: isTablet ? 40 : 35,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (provider['color'] as Color).withOpacity(0.2),
                                  ),
                                  child: Icon(
                                    provider['icon'] as IconData,
                                    color: provider['color'] as Color,
                                    size: isTablet ? 20 : 18,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  provider['name'] as String,
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AppTheme.textPrimary : AppTheme.textOnPrimary,
                                    fontFamily: 'Cairo',
                                  ),
                                  textAlign: TextAlign.center,
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
            );
          },
        ),
      ],
    );
  }

  Widget _buildAmountSelection(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'المبلغ',
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textOnPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            const Spacer(),
            if (selectedValue != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.successColor),
                ),
                child: Text(
                  '$selectedValue ريال',
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 4 : 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2,
          ),
          itemCount: values.length,
          itemBuilder: (context, index) {
            final value = values[index];
            final isSelected = selectedValue == value;

            return GestureDetector(
              onTap: () {
                print('💰 [FuturisticNetworkRecharge] Amount selected: $value');
                setState(() {
                  selectedValue = value;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected
                        ? [AppTheme.primaryColor, AppTheme.secondaryColor]
                        : [
                      AppTheme.primaryColor.withOpacity(0.2),
                      AppTheme.secondaryColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppTheme.primaryColor,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? AppTheme.cardShadow : [],
                ),
                child: Center(
                  child: Text(
                    '$value',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.textPrimary : AppTheme.textOnPrimary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRechargeButton(BuildContext context, bool isTablet) {
    final isReady = selectedProvider != null &&
        selectedValue != null &&
        _phoneController.text.isNotEmpty;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isReady ? _pulseAnimation.value : 1.0,
          child: Container(
            width: double.infinity,
            height: isTablet ? 70 : 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isReady
                    ? [AppTheme.primaryColor, AppTheme.secondaryColor]
                    : [AppTheme.textHint.withOpacity(0.3), AppTheme.textHint.withOpacity(0.2)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: isReady ? AppTheme.cardShadow : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: isReady && !isLoading ? _handleRecharge : null,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                      width: isTablet ? 30 : 25,
                      height: isTablet ? 30 : 25,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textPrimary),
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flash_on,
                          color: isReady ? AppTheme.textPrimary : AppTheme.textHint,
                          size: isTablet ? 28 : 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'شحن فوري',
                          style: TextStyle(
                            fontSize: isTablet ? 20 : 18,
                            fontWeight: FontWeight.bold,
                            color: isReady ? AppTheme.textPrimary : AppTheme.textHint,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleRecharge() async {
    if (selectedProvider == null || selectedValue == null || _phoneController.text.isEmpty) {
      print('❌ [FuturisticNetworkRecharge] Invalid form data');
      return;
    }

    print('⚡ [FuturisticNetworkRecharge] Starting recharge process...');
    print('📱 Phone: ${_phoneController.text}');
    print('📡 Provider: $selectedProvider');
    print('💰 Amount: $selectedValue');

    setState(() {
      isLoading = true;
    });

    try {
      final currentUserAsync = ref.read(authControllerProvider);
      final currentUser = currentUserAsync.value;
      if (currentUser == null) {
        print('❌ [FuturisticNetworkRecharge] User not authenticated');
        throw Exception('المستخدم غير مسجل الدخول');
      }

      print('👤 [FuturisticNetworkRecharge] User authenticated: ${currentUser.name}');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Create API service instance
      final apiService = ApiService();

      final result = await apiService.rechargeNetwork(
        provider: selectedProvider!,
        value: selectedValue!,
        userId: currentUser.uid,
        userPhone: currentUser.phone ?? '+967777000000',
      );

      print('✅ [FuturisticNetworkRecharge] Recharge completed successfully');
      print('📄 Result: $result');

      if (mounted) {
        if (result['success']) {
          // Navigate to result screen
          Navigator.of(context).pushReplacementNamed(
            TransactionResultScreen.routeName,
            arguments: {
              'success': true,
              'message': 'تم شحن الرصيد بنجاح',
              'amount': selectedValue,
              'provider': selectedProvider,
              'phone': _phoneController.text,
              'transactionId': result['transactionId'],
            },
          );
        } else {
          throw Exception(result['message'] ?? 'فشل في عملية الشحن');
        }
      }
    } catch (e) {
      print('❌ [FuturisticNetworkRecharge] Recharge failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ: ${e.toString()}',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}

// Custom painter for network background
class NetworkBackgroundPainter extends CustomPainter {
  final double animationValue;

  NetworkBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppTheme.primaryColor.withOpacity(0.1);

    // Draw network connection lines
    for (int i = 0; i < 15; i++) {
      final startX = (size.width * i / 15) + (animationValue * 20);
      final startY = size.height * 0.2 + (math.sin(animationValue * 2 * math.pi + i) * 50);
      final endX = (size.width * (i + 1) / 15) + (animationValue * 20);
      final endY = size.height * 0.8 + (math.cos(animationValue * 2 * math.pi + i) * 50);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(NetworkBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// Custom painter for scanner effect
class ScannerPainter extends CustomPainter {
  final double animationValue;

  ScannerPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppTheme.primaryColor.withOpacity(0.6);

    // Draw scanning line
    final y = size.height * animationValue;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      paint,
    );

    // Draw corner brackets
    final bracketSize = 30.0;
    final cornerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = AppTheme.primaryColor.withOpacity(0.8);

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(20, 20 + bracketSize)
        ..lineTo(20, 20)
        ..lineTo(20 + bracketSize, 20),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - 20 - bracketSize, 20)
        ..lineTo(size.width - 20, 20)
        ..lineTo(size.width - 20, 20 + bracketSize),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(20, size.height - 20 - bracketSize)
        ..lineTo(20, size.height - 20)
        ..lineTo(20 + bracketSize, size.height - 20),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - 20 - bracketSize, size.height - 20)
        ..lineTo(size.width - 20, size.height - 20)
        ..lineTo(size.width - 20, size.height - 20 - bracketSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(ScannerPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
