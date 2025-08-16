import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:ui';

import '../../core/constants/app_constants.dart';
import '../../core/validation/validation_service.dart';
import '../../core/error/error_handler.dart';
import '../../providers/auth_provider.dart';
import '../home/futuristic_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import 'futuristic_register_screen.dart';
import 'forgot_password_screen.dart';

class FuturisticLoginScreen extends ConsumerStatefulWidget {
  static const String routeName = '/futuristic-login';

  const FuturisticLoginScreen({super.key});

  @override
  ConsumerState<FuturisticLoginScreen> createState() => _FuturisticLoginScreenState();
}

class _FuturisticLoginScreenState extends ConsumerState<FuturisticLoginScreen>
    with TickerProviderStateMixin {

  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _sparkleController;
  late AnimationController _typingController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _typingAnimation;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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

    _typingController = AnimationController(
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

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );

    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() {
    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _sparkleController.repeat(reverse: true);
    _typingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _sparkleController.dispose();
    _typingController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(authControllerProvider.notifier)
          .signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        ErrorHandler.showSuccess('مرحباً بك في PayPoint!');

        // انتظار قصير ثم العودة للصفحة الرئيسية للسماح لـ splash بالتوجيه
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/', // splash screen
                (route) => false,
          );
        }
      }
    } catch (e) {
      ErrorHandler.handleError('تسجيل الدخول', e, type: ErrorType.auth);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: AnimatedBuilder(
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
                  _buildTypingEffect(),
                  SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: screenSize.height - 100),
                        child: Padding(
                          padding: EdgeInsets.all(isTablet ? 32 : 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLogo(isTablet),
                              const SizedBox(height: 60),
                              _buildLoginForm(isTablet),
                              const SizedBox(height: 40),
                              _buildQuickActions(isTablet),
                            ],
                          ),
                        ),
                      ),
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
            painter: LoginBackgroundPainter(_rotationAnimation.value),
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
          painter: LoginParticlesPainter(_sparkleAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildTypingEffect() {
    return AnimatedBuilder(
      animation: _typingAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: TypingEffectPainter(_typingAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildLogo(bool isTablet) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Column(
            children: [
              Container(
                width: isTablet ? 120 : 100,
                height: isTablet ? 120 : 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF00F5FF),
                      Color(0xFF0080FF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F5FF).withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 2 * math.pi,
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: isTablet ? 60 : 50,
                        color: Colors.black,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'PayPoint',
                style: TextStyle(
                  fontSize: isTablet ? 48 : 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlueAccent,
                  fontFamily: 'Cairo',
                  shadows: [
                    Shadow(
                      color: const Color(0xFF00F5FF).withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'مرحباً بك في المستقبل',
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  color: Colors.lightBlueAccent,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoginForm(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00F5FF).withOpacity(0.1),
            const Color(0xFF0080FF).withOpacity(0.05),
            const Color(0xFF8000FF).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00F5FF).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F5FF).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تسجيل الدخول',
              style: TextStyle(
                fontSize: isTablet ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أدخل بياناتك للوصول إلى حسابك',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: Colors.lightBlueAccent,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 32),

            // Email Field
            _buildInputField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              hint: 'أدخل بريدك الإلكتروني',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: ValidationService.validateEmail,
              isTablet: isTablet,
            ),

            const SizedBox(height: 20),

            // Password Field
            _buildInputField(
              controller: _passwordController,
              label: 'كلمة المرور',
              hint: 'أدخل كلمة المرور',
              icon: Icons.lock,
              isPassword: true,
              validator: ValidationService.validatePassword,
              isTablet: isTablet,
            ),

            const SizedBox(height: 20),

            // Remember Me & Forgot Password
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _rememberMe = !_rememberMe;
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _rememberMe
                              ? const Color(0xFF00F5FF)
                              : Colors.transparent,
                          border: Border.all(
                            color: const Color(0xFF00F5FF),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _rememberMe
                            ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.black,
                        )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'تذكرني',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: Colors.lightBlueAccent,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      ForgotPasswordScreen.routeName,
                    );
                  },
                  child: Text(
                    'نسيت كلمة المرور؟',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: const Color(0xFF00F5FF),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Login Button
            _buildLoginButton(isTablet),

            const SizedBox(height: 24),

            // Divider
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.lightBlueAccent.withOpacity(0.3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'أو',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.lightBlueAccent,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.lightBlueAccent.withOpacity(0.3),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Register Button
            _buildRegisterButton(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isTablet,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            color: Colors.lightBlueAccent,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.lightBlueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF00F5FF).withOpacity(0.3),
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isPassword ? _obscurePassword : false,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.lightBlueAccent,
              fontFamily: 'Cairo',
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.lightBlueAccent,
                fontFamily: 'Cairo',
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF00F5FF),
                size: isTablet ? 24 : 20,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: const Color(0xFF00F5FF),
                  size: isTablet ? 24 : 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 16,
                vertical: isTablet ? 16 : 14,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(bool isTablet) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: double.infinity,
            height: isTablet ? 60 : 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00F5FF), Color(0xFF0080FF)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00F5FF).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _isLoading ? null : _handleLogin,
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                    width: isTablet ? 24 : 20,
                    height: isTablet ? 24 : 20,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                      : Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Cairo',
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

  Widget _buildRegisterButton(bool isTablet) {
    return Container(
      width: double.infinity,
      height: isTablet ? 60 : 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF00F5FF).withOpacity(0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.lightBlueAccent.withOpacity(0.05),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).pushNamed(
              FuturisticRegisterScreen.routeName,
            );
          },
          child: Center(
            child: Text(
              'إنشاء حساب جديد',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00F5FF),
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isTablet) {
    return Column(
      children: [
        // Quick Admin Login (للتطوير)
        if (const bool.fromEnvironment('dart.vm.product') == false)
          GestureDetector(
            onTap: () {
              _emailController.text = 'admin@paypoint.ye';
              _passwordController.text = 'PayPoint@2024!';
              _handleLogin();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.lightBlueAccent.withOpacity(0.3),
                ),
              ),
              child: Text(
                'دخول سريع للمدير (للتطوير)',
                style: TextStyle(
                  fontSize: isTablet ? 12 : 10,
                  color: Colors.lightBlueAccent,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Custom painters for login screen effects
class LoginBackgroundPainter extends CustomPainter {
  final double animationValue;

  LoginBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF00F5FF).withOpacity(0.1);

    // Draw login circuit patterns
    for (int i = 0; i < 15; i++) {
      final offset = Offset(
        (size.width * 0.1 * i) + (animationValue * 30),
        (size.height * 0.1 * i) + (animationValue * 20),
      );

      canvas.drawCircle(offset, 15 + (animationValue * 5), paint);

      // Draw connecting lines
      if (i > 0) {
        final prevOffset = Offset(
          (size.width * 0.1 * (i - 1)) + (animationValue * 30),
          (size.height * 0.1 * (i - 1)) + (animationValue * 20),
        );
        canvas.drawLine(prevOffset, offset, paint);
      }
    }
  }

  @override
  bool shouldRepaint(LoginBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class LoginParticlesPainter extends CustomPainter {
  final double animationValue;

  LoginParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF00F5FF).withOpacity(0.4);

    // Draw floating login particles
    for (int i = 0; i < 30; i++) {
      final x = (size.width * math.Random(i).nextDouble()) +
          (math.sin(animationValue * 2 * math.pi + i) * 15);
      final y = (size.height * math.Random(i + 50).nextDouble()) +
          (math.cos(animationValue * 2 * math.pi + i) * 10);

      canvas.drawCircle(
        Offset(x, y),
        1.5 + (math.sin(animationValue * 3 * math.pi + i) * 1),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(LoginParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class TypingEffectPainter extends CustomPainter {
  final double animationValue;

  TypingEffectPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF00F5FF).withOpacity(0.3);

    // Draw typing cursor effect
    if (animationValue > 0.5) {
      final cursorX = size.width * 0.7;
      final cursorY = size.height * 0.6;

      canvas.drawLine(
        Offset(cursorX, cursorY - 10),
        Offset(cursorX, cursorY + 10),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(TypingEffectPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
