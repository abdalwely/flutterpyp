import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:ui';

import '../../core/theme/app_theme.dart';
import '../../core/theme/AppThemeMode.dart';

class ThemeSettingsScreen extends ConsumerStatefulWidget {
  static const String routeName = '/theme-settings';

  const ThemeSettingsScreen({super.key});

  @override
  ConsumerState<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends ConsumerState<ThemeSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutQuart,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
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
      end: 1.0,
    ).animate(_rotationController);

    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final customColors = ref.watch(customColorsProvider);

    return Scaffold(
      backgroundColor: customColors['background'],
      body: AnimatedBuilder(
        animation: _fadeInAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeInAnimation.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Stack(
                children: [
                  // خلفية متحركة
                  _buildAnimatedBackground(customColors),
                  
                  // جسيمات متحركة
                  _buildFloatingParticles(customColors),

                  // المحتوى الرئيسي
                  SafeArea(
                    child: Column(
                      children: [
                        // Header
                        _buildHeader(customColors),
                        
                        // محتوى الصفحة
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // عنوان الثيمات
                                  _buildSectionTitle('اختر المظهر', customColors),
                                  const SizedBox(height: 20),
                                  
                                  // شبكة الثيمات
                                  _buildThemeGrid(themeState, customColors),
                                  
                                  const SizedBox(height: 40),
                                  
                                  // تخصيص الألوان
                                  _buildSectionTitle('تخصيص الألوان', customColors),
                                  const SizedBox(height: 20),
                                  
                                  // منتقي الألو��ن
                                  _buildColorPickers(themeState, customColors),
                                  
                                  const SizedBox(height: 40),
                                  
                                  // معاينة الثيم
                                  _buildSectionTitle('معاينة الثيم', customColors),
                                  const SizedBox(height: 20),
                                  
                                  // بطاقة المعاينة
                                  _buildPreviewCard(customColors),
                                  
                                  const SizedBox(height: 40),
                                  
                                  // أزرار التحكم
                                  _buildControlButtons(customColors),
                                  
                                  const SizedBox(height: 20),
                                ],
                              ),
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

  Widget _buildAnimatedBackground(Map<String, Color> customColors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            customColors['primary']!.withOpacity(0.1),
            customColors['accent']!.withOpacity(0.08),
            customColors['background']!,
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: ThemeBackgroundPainter(
              _rotationAnimation.value,
              customColors['primary']!,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildFloatingParticles(Map<String, Color> customColors) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ThemeParticlesPainter(
            _pulseAnimation.value,
            customColors['primary']!,
            customColors['accent']!,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildHeader(Map<String, Color> customColors) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [
                    customColors['surface']!.withOpacity(0.3),
                    customColors['surface']!.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: customColors['primary']!.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: customColors['textPrimary'],
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إعدادات المظهر',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: customColors['textPrimary'],
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  'خصص مظهر التطبيق حسب ذوقك',
                  style: TextStyle(
                    fontSize: 16,
                    color: customColors['textSecondary'],
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
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        customColors['primary']!,
                        customColors['accent']!,
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.palette,
                    color: customColors['textPrimary'],
                    size: 25,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Map<String, Color> customColors) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [customColors['primary']!, customColors['accent']!],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: customColors['textPrimary'],
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _buildThemeGrid(ThemeState themeState, Map<String, Color> customColors) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: AppThemeMode.values.length,
      itemBuilder: (context, index) {
        final mode = AppThemeMode.values[index];
        final isSelected = themeState.themeMode == mode;

        return GestureDetector(
          onTap: () {
            ref.read(themeProvider.notifier).setThemeMode(mode);
            _showThemeChangeSuccess(mode.name);
          },
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isSelected ? _pulseAnimation.value : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              customColors['primary']!.withOpacity(0.3),
                              customColors['accent']!.withOpacity(0.2),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              customColors['surface']!.withOpacity(0.15),
                              customColors['surface']!.withOpacity(0.05),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? customColors['primary']!
                          : customColors['primary']!.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: customColors['primary']!.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getThemePreviewColor(mode).withOpacity(0.2),
                                border: Border.all(
                                  color: _getThemePreviewColor(mode),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                mode.icon,
                                color: _getThemePreviewColor(mode),
                                size: 25,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              mode.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? customColors['primary']
                                    : customColors['textPrimary'],
                                fontFamily: 'Cairo',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: customColors['primary']!.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'مطبق',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: customColors['primary'],
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                            ],
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
    );
  }

  Widget _buildColorPickers(ThemeState themeState, Map<String, Color> customColors) {
    return Column(
      children: [
        // Primary Color Picker
        _buildColorPickerRow(
          'اللون الأساسي',
          themeState.primaryColor,
          customColors,
          (color) => ref.read(themeProvider.notifier).setPrimaryColor(color),
        ),
        const SizedBox(height: 20),
        
        // Accent Color Picker
        _buildColorPickerRow(
          'اللون الثانوي',
          themeState.accentColor,
          customColors,
          (color) => ref.read(themeProvider.notifier).setAccentColor(color),
        ),
      ],
    );
  }

  Widget _buildColorPickerRow(
    String title,
    Color currentColor,
    Map<String, Color> customColors,
    Function(Color) onColorSelected,
  ) {
    final predefinedColors = [
      const Color(0xFF7609D0), // البنفسجي
      const Color(0xFF2196F3), // الأزرق
      const Color(0xFF4CAF50), // الأخضر
      const Color(0xFFFF9800), // البرتقالي
      const Color(0xFFF44336), // الأحمر
      const Color(0xFF9C27B0), // البنفسجي الداكن
      const Color(0xFF00BCD4), // السماوي
      const Color(0xFFFFEB3B), // الأصفر
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            customColors['surface']!.withOpacity(0.15),
            customColors['surface']!.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: customColors['primary']!.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: customColors['textPrimary'],
                  fontFamily: 'Cairo',
                ),
              ),
              const Spacer(),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: currentColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: customColors['primary']!.withOpacity(0.3),
                    width: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: predefinedColors.map((color) {
              final isSelected = color.value == currentColor.value;
              return GestureDetector(
                onTap: () => onColorSelected(color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? customColors['textPrimary']!
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: _getContrastColor(color),
                          size: 20,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(Map<String, Color> customColors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            customColors['primary']!.withOpacity(0.1),
            customColors['accent']!.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: customColors['primary']!.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [customColors['primary']!, customColors['accent']!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: customColors['textPrimary'],
                  size: 25,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الرصيد الحالي',
                      style: TextStyle(
                        fontSize: 16,
                        color: customColors['textSecondary'],
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      '1,250.00 ريال',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: customColors['primary'],
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: customColors['primary'],
              foregroundColor: customColors['textPrimary'],
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'زر تجريبي',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(Map<String, Color> customColors) {
    return Column(
      children: [
        // زر الحفظ
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _showSaveConfirmation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: customColors['primary'],
              foregroundColor: customColors['textPrimary'],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save, color: customColors['textPrimary']),
                const SizedBox(width: 12),
                const Text(
                  'حفظ الإعدادات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // زر الإعادة للافتراضي
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              _showResetConfirmation();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: customColors['textSecondary'],
              side: BorderSide(
                color: customColors['primary']!.withOpacity(0.3),
                width: 1,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, color: customColors['textSecondary']),
                const SizedBox(width: 12),
                const Text(
                  'إعادة للإعدادات الافتراضية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getThemePreviewColor(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return AppTheme.primaryColor;
      case AppThemeMode.dark:
        return const Color(0xFF2D3748);
      case AppThemeMode.futuristic:
        return const Color(0xFF00F5FF);
      case AppThemeMode.neon:
        return const Color(0xFFFF0080);
      case AppThemeMode.ocean:
        return const Color(0xFF006994);
      case AppThemeMode.auto:
        return AppTheme.primaryColor;
    }
  }

  Color _getContrastColor(Color color) {
    // حساب اللون المتباين (أبيض أو أسود)
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  void _showThemeChangeSuccess(String themeName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تطبيق مظهر "$themeName" بنجاح',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: ref.read(customColorsProvider)['primary'],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSaveConfirmation() {
    final customColors = ref.read(customColorsProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: customColors['surface']!.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'حفظ الإعدادات',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            color: customColors['textPrimary'],
          ),
        ),
        content: Text(
          'هل تريد حفظ إعدادات المظهر الحالية؟',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: customColors['textPrimary'],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: customColors['textSecondary'],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'تم حفظ الإعدادات بنجاح!',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  backgroundColor: customColors['primary'],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: customColors['primary'],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'حفظ',
              style: TextStyle(
                color: customColors['textPrimary'],
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation() {
    final customColors = ref.read(customColorsProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: customColors['surface']!.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'إعادة تعيين المظهر',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            color: customColors['textPrimary'],
          ),
        ),
        content: Text(
          'هل تريد إعادة تعيين جميع إعدادات المظهر للإعدادات الافتراضية؟',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: customColors['textPrimary'],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: customColors['textSecondary'],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(themeProvider.notifier).resetToDefault();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'تم إعادة تعيين المظهر للإعدادات الافتراضية',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'إعادة تعيين',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// رسام الخلفية المتحركة
class ThemeBackgroundPainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;

  ThemeBackgroundPainter(this.animationValue, this.primaryColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = primaryColor.withOpacity(0.1);

    // رسم الدوائر المتحركة
    for (int i = 0; i < 15; i++) {
      final offset = Offset(
        (size.width * 0.1 * i) + (animationValue * 100),
        (size.height * 0.1 * i) + (animationValue * 60),
      );

      canvas.drawCircle(
        offset,
        30 + (animationValue * 20),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ThemeBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.primaryColor != primaryColor;
  }
}

// رسام الجسيمات
class ThemeParticlesPainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;
  final Color accentColor;

  ThemeParticlesPainter(this.animationValue, this.primaryColor, this.accentColor);

  @override
  void paint(Canvas canvas, Size size) {
    final primaryPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor.withOpacity(0.3);

    final accentPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = accentColor.withOpacity(0.2);

    // رسم الجسيمات المتحركة
    for (int i = 0; i < 30; i++) {
      final x = (size.width * math.Random(i).nextDouble()) +
          (math.sin(animationValue * 2 * math.pi + i) * 30);
      final y = (size.height * math.Random(i + 100).nextDouble()) +
          (math.cos(animationValue * 2 * math.pi + i) * 20);

      final radius = 3 + (math.sin(animationValue * 4 * math.pi + i) * 2);
      final paint = i.isEven ? primaryPaint : accentPaint;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ThemeParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor;
  }
}
