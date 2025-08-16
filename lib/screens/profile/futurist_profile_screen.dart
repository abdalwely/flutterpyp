import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

import '../auth/futuristic_login_screen.dart';

import '../services/image_upload_service.dart';
import '../services/user_service.dart';

class FuturisticProfileScreen extends ConsumerStatefulWidget {
  static const String routeName = '/futuristic-profile';

  const FuturisticProfileScreen({super.key});

  @override
  ConsumerState<FuturisticProfileScreen> createState() => _FuturisticProfileScreenState();
}

class _FuturisticProfileScreenState extends ConsumerState<FuturisticProfileScreen>
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

  bool _isLoading = false;
  bool _isUploadingImage = false;

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
                painter: ProfileBackgroundPainter(
                  rotationValue: _rotationAnimation.value,
                  sparkleValue: _sparkleAnimation.value,
                ),
                size: Size.infinite,
              ),

              // Floating Particles
              CustomPaint(
                painter: ProfileParticlesPainter(
                  animationValue: _sparkleAnimation.value,
                  floatingValue: _floatingAnimation.value,
                ),
                size: Size.infinite,
              ),

              // Main Content
              currentUserAsync.when(
                data: (user) {
                  if (user == null) {
                    return _buildErrorContent();
                  }
                  return _buildProfileContent(context, user);
                },
                loading: () => _buildLoadingContent(),
                error: (error, _) => _buildErrorContent(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, user) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header with back button
              _buildHeader(),

              const SizedBox(height: 30),

              // Profile Avatar and Info
              _buildProfileHeader(user),

              const SizedBox(height: 40),

              // Stats Cards
              _buildStatsCards(user),

              const SizedBox(height: 30),

              // Profile Options
              _buildProfileOptions(user),

              const SizedBox(height: 30),

              // Settings Section
              _buildSettingsSection(),

              const SizedBox(height: 40),

              // Logout Button
              _buildLogoutButton(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Transform.translate(
      offset: Offset(0, 50 * _slideAnimation.value),
      child: Opacity(
        opacity: _fadeInAnimation.value,
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
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

            const Expanded(
              child: Center(
                child: Text(
                  'الملف الشخصي',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Transform.translate(
      offset: Offset(0, 30 * _slideAnimation.value),
      child: Opacity(
        opacity: _fadeInAnimation.value,
        child: Column(
          children: [
            // Profile Picture with Animation and Upload
            Transform.scale(
              scale: _pulseAnimation.value,
              child: Stack(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppConstants.primaryColor.withOpacity(0.8),
                          AppConstants.accentColor.withOpacity(0.6),
                          Colors.purple.withOpacity(0.4),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.primaryColor.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: _isUploadingImage
                            ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppConstants.primaryColor,
                            ),
                          ),
                        )
                            : user.photoUrl != null && user.photoUrl!.isNotEmpty
                            ? Image.network(
                          user.photoUrl!,
                          width: 134,
                          height: 134,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 80,
                              color: AppConstants.primaryColor,
                            );
                          },
                        )
                            : const Icon(
                          Icons.person,
                          size: 80,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  // زر تحديث الصورة
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () => _updateProfileImage(),
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // User Name
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
                    user.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // User Email
            Text(
              user.email,
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

  Widget _buildStatsCards(user) {
    return Transform.translate(
      offset: Offset(0, 20 * _slideAnimation.value),
      child: Opacity(
        opacity: _fadeInAnimation.value,
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'الرصيد',
                '${user.balance.toStringAsFixed(2)} ريال',
                Icons.account_balance_wallet,
                Colors.green,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                'المعاملات',
                '12',
                Icons.receipt_long,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                'النقاط',
                '350',
                Icons.stars,
                Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
          child: Column(
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                title,
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

  Widget _buildProfileOptions(user) {
    return Transform.translate(
      offset: Offset(0, 10 * _slideAnimation.value),
      child: Opacity(
        opacity: _fadeInAnimation.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5, bottom: 15),
              child: Text(
                'المعلوما�� الشخصية',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            _buildOptionItem(
              icon: Icons.edit_outlined,
              title: 'تعديل الاسم',
              subtitle: 'تحديث اسم المستخدم',
              onTap: () => _editUserName(user.uid, user.name),
            ),
            _buildOptionItem(
              icon: Icons.phone_outlined,
              title: 'رقم الهاتف',
              subtitle: 'تحديث رقم الهاتف',
              onTap: () => _editPhoneNumber(user.uid, user.phone),
            ),
            _buildOptionItem(
              icon: Icons.camera_alt_outlined,
              title: 'تغيير الصورة الشخصية',
              subtitle: 'رفع صورة جديدة',
              onTap: () => _updateProfileImage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Transform.translate(
      offset: Offset(0, 10 * _slideAnimation.value),
      child: Opacity(
        opacity: _fadeInAnimation.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5, bottom: 15),
              child: Text(
                'الإعدادات',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            _buildOptionItem(
              icon: Icons.security_outlined,
              title: 'تغيير كلمة المرور',
              subtitle: 'تحديث كلمة المرور',
              onTap: () => _changePassword(),
            ),
            _buildOptionItem(
              icon: Icons.notifications_outlined,
              title: 'الإشعارات',
              subtitle: 'إعدادات التنبيهات',
              onTap: () => _showNotificationsSettings(),
            ),
            _buildOptionItem(
              icon: Icons.language_outlined,
              title: 'اللغة',
              subtitle: 'العربية',
              onTap: () => _showLanguageSettings(),
            ),
            _buildOptionItem(
              icon: Icons.help_outline,
              title: 'الم��اعدة والدعم',
              subtitle: 'الأسئلة الشائعة',
              onTap: () => _showHelpAndSupport(),
            ),
            _buildOptionItem(
              icon: Icons.info_outline,
              title: 'حول التطبيق',
              subtitle: 'معلومات التطبيق والإصدار',
              onTap: () => _showAboutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
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
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        AppConstants.primaryColor.withOpacity(0.3),
                        AppConstants.accentColor.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
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

  Widget _buildLogoutButton() {
    return Transform.translate(
      offset: Offset(0, 10 * _slideAnimation.value),
      child: Opacity(
        opacity: _fadeInAnimation.value,
        child: GestureDetector(
          onTap: () => _handleLogout(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF6B6B),
                  Color(0xFFEE5A52),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ),
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

  Widget _buildErrorContent() {
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
          const Text(
            'خطأ في تحميل البيانات',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'العودة',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'تسجيل ال��روج',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'هل أنت متأكد من تسجيل الخروج؟',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'تسجيل الخروج',
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

    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).signOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          FuturisticLoginScreen.routeName,
              (route) => false,
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryColor,
              AppConstants.accentColor,
            ],
          ),
        ),
        child: const Icon(
          Icons.payment,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const Text(
          'تطبيق PayPoint هو منصة شاملة لل��فع الإلكتروني وشحن الخدمات المختلفة في اليمن.',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
      ],
    );
  }

  // تحديث صورة الملف الشخصي
  Future<void> _updateProfileImage() async {
    if (_isUploadingImage) return;

    try {
      // الحصول على بيانات المستخدم الحالي
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        _showErrorMessage('خطأ: بيانات المستخدم غير متوفرة');
        return;
      }

      final ImageSource? source = await ImageUploadService.showImageSourceDialog(context);
      if (source == null) return;

      setState(() {
        _isUploadingImage = true;
      });

      // رفع الصورة الجديدة
      final String? imageUrl = await ImageUploadService.uploadProfileImage(
        userId: currentUser.uid,
        source: source,
      );

      if (imageUrl != null) {
        // تحديث بيانات المستخدم
        await UserService.updateProfileImage(
          userId: currentUser.uid,
          imageUrl: imageUrl,
        );

        // إعادة تحميل بيانات المستخدم
        await ref.read(authControllerProvider.notifier).refreshUser();

        _showSuccessMessage('تم تحديث الصورة الشخصية بنجاح');
      }
    } catch (e) {
      _showErrorMessage('خطأ في ت��ديث الصورة: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  // تعديل اسم المستخدم
  void _editUserName(String userId, String currentName) {
    final TextEditingController nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'تعديل الاسم',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(fontFamily: 'Cairo'),
          decoration: const InputDecoration(
            labelText: 'الاسم الجديد',
            labelStyle: TextStyle(fontFamily: 'Cairo'),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && UserService.isValidName(newName)) {
                Navigator.pop(context);
                await _updateUserName(userId, newName);
              } else {
                _showErrorMessage('يرجى إدخال اسم صحيح');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'حفظ',
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

  // تحديث اسم المستخدم
  Future<void> _updateUserName(String userId, String newName) async {
    if (_isLoading) return;

    try {
      setState(() {
        _isLoading = true;
      });

      await UserService.updateUserName(
        userId: userId,
        name: newName,
      );

      await ref.read(authControllerProvider.notifier).refreshUser();
      _showSuccessMessage('تم تحديث الاسم بنجاح');
    } catch (e) {
      _showErrorMessage('خطأ في تحديث الاس��: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // تعديل رقم الهاتف
  void _editPhoneNumber(String userId, String currentPhone) {
    final TextEditingController phoneController = TextEditingController(text: currentPhone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'تعديل رقم الهاتف',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: phoneController,
          style: const TextStyle(fontFamily: 'Cairo'),
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'رقم الهاتف',
            labelStyle: TextStyle(fontFamily: 'Cairo'),
            border: OutlineInputBorder(),
            hintText: '967xxxxxxxxx',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newPhone = phoneController.text.trim();
              if (newPhone.isNotEmpty && UserService.isValidPhoneNumber(newPhone)) {
                Navigator.pop(context);
                await _updatePhoneNumber(userId, newPhone);
              } else {
                _showErrorMessage('يرجى إدخال رقم هاتف صحيح');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'حفظ',
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

  // تحديث رقم الهاتف
  Future<void> _updatePhoneNumber(String userId, String newPhone) async {
    if (_isLoading) return;

    try {
      setState(() {
        _isLoading = true;
      });

      await UserService.updatePhoneNumber(
        userId: userId,
        phone: newPhone,
      );

      await ref.read(authControllerProvider.notifier).refreshUser();
      _showSuccessMessage('تم تحديث رقم الهاتف بنجاح');
    } catch (e) {
      _showErrorMessage('خطأ في تحديث رقم الهاتف: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // تغيير كلمة المرور
  void _changePassword() {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'تغيير كلمة المرور',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              style: const TextStyle(fontFamily: 'Cairo'),
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الحالية',
                labelStyle: TextStyle(fontFamily: 'Cairo'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: const TextStyle(fontFamily: 'Cairo'),
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                labelStyle: TextStyle(fontFamily: 'Cairo'),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              style: const TextStyle(fontFamily: 'Cairo'),
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                labelStyle: TextStyle(fontFamily: 'Cairo'),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final currentPassword = currentPasswordController.text;
              final newPassword = newPasswordController.text;
              final confirmPassword = confirmPasswordController.text;

              if (currentPassword.isEmpty || newPassword.isEmpty) {
                _showErrorMessage('يرجى ملء جميع الحقول');
                return;
              }

              if (newPassword != confirmPassword) {
                _showErrorMessage('كلمة المرور الجديدة غير متطابقة');
                return;
              }

              if (newPassword.length < 6) {
                _showErrorMessage('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
                return;
              }

              Navigator.pop(context);
              await _updatePassword(currentPassword, newPassword);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'تحديث',
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

  // تحديث كلمة المرور
  Future<void> _updatePassword(String currentPassword, String newPassword) async {
    if (_isLoading) return;

    try {
      setState(() {
        _isLoading = true;
      });

      await UserService.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _showSuccessMessage('تم تحديث كلمة المرور بنجاح');
    } catch (e) {
      _showErrorMessage('خطأ في تحديث كلمة المرور: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // إعدادات الإشعارات
  void _showNotificationsSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'إعدادات الإشعا��ات',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ستتوفر إعدادات الإشعارات في الإصدارات القادمة',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ],
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

  // إعدادات اللغة
  void _showLanguageSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'إعدادات اللغة',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'حالياً التطبيق يدعم اللغة العربية فقط\nسيتم إضافة المزيد من اللغات قريباً',
              style: TextStyle(fontFamily: 'Cairo'),
              textAlign: TextAlign.center,
            ),
          ],
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

  // المساعدة والدعم
  void _showHelpAndSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'المساعدة والدعم',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'للحصول على المساعدة والدعم:',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '📧 البريد الإلكتروني: support@paypoint.ye',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            SizedBox(height: 5),
            Text(
              '📞 الهاتف: 967-1-123-456',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            SizedBox(height: 5),
            Text(
              '⏰ أوقات العمل: من السبت إلى الخميس، 8 صباحاً - 8 مساءً',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ],
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

  // عرض رسالة نجاح
  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: const Color(0xFF28a745),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // عرض رسالة خطأ
  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: const Color(0xFFdc3545),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// Custom Painter for Profile Background
class ProfileBackgroundPainter extends CustomPainter {
  final double rotationValue;
  final double sparkleValue;

  ProfileBackgroundPainter({
    required this.rotationValue,
    required this.sparkleValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Base gradient background
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF1a1a2e),
        const Color(0xFF16213e),
        const Color(0xFF0f3460),
        const Color(0xFF533483),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Animated geometric shapes
    _drawRotatingShapes(canvas, size, paint);
    _drawSparkleEffect(canvas, size, paint);
  }

  void _drawRotatingShapes(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);

    // Large rotating circle
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationValue);

    paint.shader = RadialGradient(
      colors: [
        AppConstants.primaryColor.withOpacity(0.1),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: 200));

    canvas.drawCircle(const Offset(100, 0), 150, paint);
    canvas.restore();

    // Secondary rotating shape
    canvas.save();
    canvas.translate(center.dx - 100, center.dy + 100);
    canvas.rotate(-rotationValue * 0.7);

    paint.shader = RadialGradient(
      colors: [
        AppConstants.accentColor.withOpacity(0.08),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: 120));

    canvas.drawCircle(const Offset(0, 0), 100, paint);
    canvas.restore();
  }

  void _drawSparkleEffect(Canvas canvas, Size size, Paint paint) {
    paint.shader = null;
    paint.color = Colors.white.withOpacity(0.6 * sparkleValue);

    final sparklePositions = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.7),
      Offset(size.width * 0.1, size.height * 0.8),
      Offset(size.width * 0.6, size.height * 0.1),
    ];

    for (final position in sparklePositions) {
      _drawSparkle(canvas, position, paint, 2.0 * sparkleValue);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, Paint paint, double size) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size * 0.3, center.dy - size * 0.3);
    path.lineTo(center.dx + size, center.dy);
    path.lineTo(center.dx + size * 0.3, center.dy + size * 0.3);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size * 0.3, center.dy + size * 0.3);
    path.lineTo(center.dx - size, center.dy);
    path.lineTo(center.dx - size * 0.3, center.dy - size * 0.3);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ProfileBackgroundPainter oldDelegate) {
    return oldDelegate.rotationValue != rotationValue ||
        oldDelegate.sparkleValue != sparkleValue;
  }
}

// Custom Painter for Floating Particles
class ProfileParticlesPainter extends CustomPainter {
  final double animationValue;
  final double floatingValue;

  ProfileParticlesPainter({
    required this.animationValue,
    required this.floatingValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.3 * animationValue);

    // Floating particles
    for (int i = 0; i < 15; i++) {
      final x = (size.width / 15) * i + (math.sin(animationValue * 2 * math.pi + i) * 20);
      final y = (size.height / 8) * (i % 8) + floatingValue;
      final radius = 1.0 + (math.sin(animationValue * math.pi + i) * 1.5);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ProfileParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.floatingValue != floatingValue;
  }
}
