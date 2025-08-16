import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:ui';

import '../../core/constants/app_constants.dart';
import '../../core/validation/validation_service.dart';
import '../../core/error/error_handler.dart';
import '../../providers/auth_provider.dart';
import '../home/futuristic_dashboard_screen.dart';
import 'futuristic_login_screen.dart';

class FuturisticRegisterScreen extends ConsumerStatefulWidget {
  static const String routeName = '/futuristic-register';

  const FuturisticRegisterScreen({super.key});

  @override
  ConsumerState<FuturisticRegisterScreen> createState() => _FuturisticRegisterScreenState();
}

class _FuturisticRegisterScreenState extends ConsumerState<FuturisticRegisterScreen>
    with TickerProviderStateMixin {

  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _sparkleController;
  late AnimationController _progressController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _progressAnimation;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptTerms = false;

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
      duration: const Duration(seconds: 12),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2500),
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

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() {
    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _sparkleController.repeat(reverse: true);
    _progressController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _sparkleController.dispose();
    _progressController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ErrorHandler.showError('يرجى الموافقة على الشروط والأحكام');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(authControllerProvider.notifier)
          .signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
        _phoneController.text.trim(),
      );

      if (success && mounted) {
        ErrorHandler.showSuccess('تم إنشاء حسابك بنجاح! مرحباً بك في PayPoint');

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
      ErrorHandler.handleError('إنشاء الحساب', e, type: ErrorType.auth);
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
                  _buildProgressEffect(),
                  SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 32 : 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildHeader(isTablet),
                            const SizedBox(height: 40),
                            _buildRegisterForm(isTablet),
                            const SizedBox(height: 40),
                          ],
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
            const Color(0xFF1A2E1A),
            const Color(0xFF2E4E2E),
            const Color(0xFF1A5A1A),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: RegisterBackgroundPainter(_rotationAnimation.value),
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
          painter: RegisterParticlesPainter(_sparkleAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildProgressEffect() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ProgressEffectPainter(_progressAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: isTablet ? 50 : 44,
            height: isTablet ? 50 : 44,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF28A745).withOpacity(0.3),
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: const Color(0xFF28A745),
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
                'إنشاء حساب جديد',
                style: TextStyle(
                  fontSize: isTablet ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                'انضم إلى مستقبل الدفع الإلكتروني',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: Colors.green,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _progressAnimation.value * 2 * math.pi,
              child: Container(
                width: isTablet ? 50 : 44,
                height: isTablet ? 50 : 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF28A745), Color(0xFF20C997)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF28A745).withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_add,
                  color: Colors.black,
                  size: isTablet ? 28 : 24,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRegisterForm(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF28A745).withOpacity(0.1),
            const Color(0xFF20C997).withOpacity(0.05),
            const Color(0xFF17A2B8).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF28A745).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF28A745).withOpacity(0.2),
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
            // Name Field
            _buildInputField(
              controller: _nameController,
              label: 'الاسم الكامل',
              hint: 'أدخل اسمك الكامل',
              icon: Icons.person,
              validator: ValidationService.validateFullName,
              isTablet: isTablet,
            ),

            const SizedBox(height: 20),

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

            // Phone Field
            _buildInputField(
              controller: _phoneController,
              label: 'رقم الهاتف',
              hint: '77xxxxxxx',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: ValidationService.validateYemeniPhone,
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
              obscureText: _obscurePassword,
              onToggleVisibility: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              validator: ValidationService.validatePassword,
              isTablet: isTablet,
            ),

            const SizedBox(height: 20),

            // Confirm Password Field
            _buildInputField(
              controller: _confirmPasswordController,
              label: 'تأكيد كلمة المرور',
              hint: 'أعد إدخال كلمة المرور',
              icon: Icons.lock_outline,
              isPassword: true,
              obscureText: _obscureConfirmPassword,
              onToggleVisibility: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              validator: (value) => ValidationService.validatePasswordConfirmation(
                value,
                _passwordController.text,
              ),
              isTablet: isTablet,
            ),

            const SizedBox(height: 24),

            // Terms and Conditions
            GestureDetector(
              onTap: () {
                setState(() {
                  _acceptTerms = !_acceptTerms;
                });
              },
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _acceptTerms
                          ? const Color(0xFF28A745)
                          : Colors.transparent,
                      border: Border.all(
                        color: const Color(0xFF28A745),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _acceptTerms
                        ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.black,
                    )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'أوافق على الشروط والأحكام وسياسة الخصوصية',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.green,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Register Button
            _buildRegisterButton(isTablet),

            const SizedBox(height: 24),

            // Login Link
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(
                    FuturisticLoginScreen.routeName,
                  );
                },
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontFamily: 'Cairo',
                    ),
                    children: [
                      TextSpan(
                        text: 'لديك حساب بالفعل؟ ',
                        style: TextStyle(color: Colors.green),
                      ),
                      TextSpan(
                        text: 'تسجيل الدخول',
                        style: TextStyle(
                          color: const Color(0xFF28A745),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    bool? obscureText,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            color: Colors.green,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF28A745).withOpacity(0.3),
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isPassword ? (obscureText ?? false) : false,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.green,
              fontFamily: 'Cairo',
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.green,
                fontFamily: 'Cairo',
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF28A745),
                size: isTablet ? 24 : 20,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  (obscureText ?? false)
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: const Color(0xFF28A745),
                  size: isTablet ? 24 : 20,
                ),
                onPressed: onToggleVisibility,
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

  Widget _buildRegisterButton(bool isTablet) {
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
                colors: [Color(0xFF28A745), Color(0xFF20C997)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF28A745).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _isLoading ? null : _handleRegister,
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
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add,
                        color: Colors.black,
                        size: isTablet ? 24 : 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'إنشاء الحساب',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom painters for register screen effects
class RegisterBackgroundPainter extends CustomPainter {
  final double animationValue;

  RegisterBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF28A745).withOpacity(0.1);

    // Draw register progress patterns
    for (int i = 0; i < 20; i++) {
      final progress = (animationValue + i * 0.1) % 1.0;
      final x = size.width * progress;
      final y = size.height * 0.5 + math.sin(progress * 4 * math.pi) * 50;

      canvas.drawCircle(
        Offset(x, y),
        3 + math.sin(progress * 6 * math.pi) * 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(RegisterBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class RegisterParticlesPainter extends CustomPainter {
  final double animationValue;

  RegisterParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF28A745).withOpacity(0.4);

    // Draw register success particles
    for (int i = 0; i < 40; i++) {
      final x = (size.width * math.Random(i).nextDouble()) +
          (math.sin(animationValue * 2 * math.pi + i) * 20);
      final y = (size.height * math.Random(i + 70).nextDouble()) +
          (math.cos(animationValue * 2 * math.pi + i) * 15);

      canvas.drawCircle(
        Offset(x, y),
        1 + (math.sin(animationValue * 4 * math.pi + i) * 1.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(RegisterParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class ProgressEffectPainter extends CustomPainter {
  final double animationValue;

  ProgressEffectPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFF28A745).withOpacity(0.3);

    // Draw progress waves
    for (int i = 0; i < 5; i++) {
      final waveOffset = (animationValue + i * 0.2) % 1.0;
      final radius = size.width * 0.3 * waveOffset;

      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.3),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ProgressEffectPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
