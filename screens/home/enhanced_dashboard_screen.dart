import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/localization_provider.dart';
import '../../providers/mock_data_provider.dart';
import '../../widgets/animated_widgets.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../admin/futuristic_admin_dashboard.dart';
import '../profile/futurist_profile_screen.dart';
import '../services/network_recharge_screen.dart';
import '../services/electricity_payment_screen.dart';
import '../services/water_payment_screen.dart';
import '../services/school_payment_screen.dart';
import '../transactions/transactions_screen.dart';
import '../profile/profile_screen.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class EnhancedDashboardScreen extends ConsumerStatefulWidget {
  static const String routeName = '/enhanced-dashboard';

  const EnhancedDashboardScreen({super.key});

  @override
  ConsumerState<EnhancedDashboardScreen> createState() => _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends ConsumerState<EnhancedDashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeOut),
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(enhancedCurrentUserProvider);
    final isRTL = ref.watch(isRTLProvider);
    final localization = AppLocalizations.of(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: [
          _buildDashboardPage(context, ref),
          _buildTransactionsPage(),
          _buildProfilePage(),
        ],
      ),

      // Custom Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        items: [
          BottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: localization.dashboard,
          ),
          BottomNavItem(
            icon: Icons.history_outlined,
            activeIcon: Icons.history,
            label: localization.transactions,
          ),
          BottomNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: localization.profile,
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: FloatingActionButton(
              onPressed: _showQuickActionsSheet,
              backgroundColor: AppTheme.accentColor,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildDashboardPage(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(enhancedCurrentUserProvider);
    final localization = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor,
            AppTheme.backgroundColor,
          ],
          stops: [0.0, 0.3],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              SlideInContainer(
                delay: const Duration(milliseconds: 200),
                child: _buildHeader(context, ref),
              ),

              // Balance Card
              SlideInContainer(
                delay: const Duration(milliseconds: 400),
                child: _buildBalanceCard(context, ref),
              ),

              // Quick Actions
              SlideInContainer(
                delay: const Duration(milliseconds: 600),
                child: _buildQuickActions(context),
              ),

              // Services Grid
              SlideInContainer(
                delay: const Duration(milliseconds: 800),
                child: _buildServicesGrid(context),
              ),

              // Recent Transactions
              SlideInContainer(
                delay: const Duration(milliseconds: 1000),
                child: _buildRecentTransactions(context),
              ),

              const SizedBox(height: 100), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(enhancedCurrentUserProvider);
    final localization = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User Info
          Row(
            children: [
              AnimatedCard(
                padding: const EdgeInsets.all(4),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: currentUser?.photoUrl != null
                      ? ClipOval(
                    child: Image.network(
                      currentUser!.photoUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Icon(
                    Icons.person,
                    color: AppTheme.primaryColor,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.welcome,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    currentUser?.name ?? 'أحمد محمد',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Actions
          Row(
            children: [
              // Language Toggle
              AnimatedButton(
                onPressed: () {
                  ref.read(localeProvider.notifier).toggleLocale();
                },
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.language,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),

              // Notifications
              AnimatedButton(
                onPressed: _showNotifications,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: PulseWidget(
                        child: CircleAvatar(
                          radius: 4,
                          backgroundColor: AppTheme.errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Admin Panel (if admin)
              currentUser?.isAdmin == true
                  ? AnimatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    FuturisticAdminDashboardScreen.routeName,
                  );
                },
                backgroundColor: AppTheme.accentColor,
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 20,
                ),
              )
                  : const SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(enhancedCurrentUserProvider);
    final localization = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedCard(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localization.availableBalance,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${currentUser?.balance?.toStringAsFixed(2) ?? '1,250.00'} ريال',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: AnimatedButton(
                    onPressed: _showTopUpSheet,
                    backgroundColor: AppTheme.successColor,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('شحن المحفظة', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedButton(
                    onPressed: _showTransferSheet,
                    backgroundColor: AppTheme.secondaryColor,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('تحويل', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إجراءات سريعة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          StaggeredContainer(
            direction: Axis.horizontal,
            children: [
              _buildQuickActionItem(
                icon: Icons.qr_code_scanner,
                title: 'مسح QR',
                color: AppTheme.infoColor,
                onTap: _scanQRCode,
              ),
              _buildQuickActionItem(
                icon: Icons.contact_phone,
                title: 'جهات الاتصال',
                color: AppTheme.successColor,
                onTap: _showContacts,
              ),
              _buildQuickActionItem(
                icon: Icons.favorite,
                title: 'المفضلة',
                color: AppTheme.errorColor,
                onTap: _showFavorites,
              ),
              _buildQuickActionItem(
                icon: Icons.history,
                title: 'الأخيرة',
                color: AppTheme.warningColor,
                onTap: _showRecent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: AnimatedCard(
        onTap: onTap,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final services = [
      {
        'title': 'شحن كروت الشبكة',
        'subtitle': 'يمن موبايل، MTN، سبأفون، واي',
        'icon': Icons.sim_card,
        'color': AppTheme.primaryColor,
        'route': NetworkRechargeScreen.routeName,
      },
      {
        'title': 'شحن الكهرباء',
        'subtitle': 'دفع فواتير الكهرباء',
        'icon': Icons.electrical_services,
        'color': AppTheme.warningColor,
        'route': ElectricityPaymentScreen.routeName,
      },
      {
        'title': 'دفع فاتورة المياه',
        'subtitle': 'تسديد فواتير المياه',
        'icon': Icons.water_drop,
        'color': AppTheme.secondaryColor,
        'route': WaterPaymentScreen.routeName,
      },
      {
        'title': 'الرسوم المدرسية',
        'subtitle': 'دفع رسوم المدارس',
        'icon': Icons.school,
        'color': AppTheme.successColor,
        'route': SchoolPaymentScreen.routeName,
      },
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الخدمات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 16),
          StaggeredContainer(
            children: services.map((service) =>
              _buildServiceCard(service)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return AnimatedCard(
      onTap: () => Navigator.of(context).pushNamed(service['route']),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: service['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              service['icon'],
              color: service['color'],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service['subtitle'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: AppTheme.textSecondary,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: AnimatedCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المعاملات الأخيرة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Cairo',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _currentIndex = 1);
                    _pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text(
                    'عرض الكل',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Placeholder for recent transactions
            ...List.generate(3, (index) =>
              _buildTransactionItem(index)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(int index) {
    final types = ['شحن كرت شبكة', 'شحن كهرباء', 'دفع فاتورة مياه'];
    final amounts = ['1000', '500', '250'];
    final colors = [AppTheme.successColor, AppTheme.warningColor, AppTheme.infoColor];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colors[index],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              types[index],
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          Text(
            '${amounts[index]} ريال',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors[index],
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsPage() {
    return const TransactionsScreen();
  }

  Widget _buildProfilePage() {
    return const FuturisticProfileScreen();
  }

  // Action Methods
  void _showQuickActionsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'إجراءات سريعة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            // Add quick actions here
          ],
        ),
      ),
    );
  }

  void _showNotifications() {
    // Show notifications
  }

  void _showTopUpSheet() {
    // Show top-up sheet
  }

  void _showTransferSheet() {
    // Show transfer sheet
  }

  void _scanQRCode() {
    // Implement QR code scanning
  }

  void _showContacts() {
    // Show contacts
  }

  void _showFavorites() {
    // Show favorites
  }

  void _showRecent() {
    // Show recent transactions
  }
}
