import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../profile/futurist_profile_screen.dart';
import '../services/futuristic_school_payment_screen.dart';
import '../services/network_recharge_screen.dart';
import '../services/electricity_payment_screen.dart';
import '../services/water_payment_screen.dart';
import '../services/school_payment_screen.dart';
import '../transactions/transactions_screen.dart';
import '../profile/profile_screen.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends ConsumerWidget {
  static const String routeName = '/dashboard';
  
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserAsyncProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.primaryColor,
              AppConstants.backgroundColor,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Top Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // User Info
                        currentUserAsync.when(
                          data: (user) => Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white,
                                child: user?.photoUrl != null
                                    ? ClipOval(
                                        child: Image.network(
                                          user!.photoUrl!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        color: AppConstants.primaryColor,
                                        size: 30,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'مرحباً',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                  Text(
                                    user?.name ?? 'مستخدم',
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
                          loading: () => const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                          error: (_, __) => const Icon(
                            Icons.error,
                            color: Colors.white,
                          ),
                        ),
                        
                        // Menu Button
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                          onSelected: (value) async {
                            switch (value) {
                              case 'profile':
                                Navigator.of(context).pushNamed(FuturisticProfileScreen.routeName);
                                break;
                              case 'logout':
                                await ref.read(authControllerProvider.notifier).signOut();
                                if (context.mounted) {
                                  Navigator.of(context).pushReplacementNamed(
                                    LoginScreen.routeName,
                                  );
                                }
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'profile',
                              child: Row(
                                children: [
                                  Icon(Icons.person),
                                  SizedBox(width: 8),
                                  Text('الملف الشخصي', style: TextStyle(fontFamily: 'Cairo')),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Icon(Icons.logout),
                                  SizedBox(width: 8),
                                  Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Balance Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: currentUserAsync.when(
                        data: (user) => Column(
                          children: [
                            const Text(
                              'الرصيد المتاح',
                              style: TextStyle(
                                color: AppConstants.textSecondary,
                                fontSize: 14,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${user?.balance?.toStringAsFixed(2) ?? '0.00'} ريال',
                              style: const TextStyle(
                                color: AppConstants.primaryColor,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text(
                          'خطأ في تحميل البيانات',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Services Grid
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الخدمات',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildServiceCard(
                              context,
                              title: 'شحن كروت الشبكة',
                              subtitle: 'يمن موبايل، MTN، سبأفون، واي',
                              icon: Icons.sim_card,
                              color: AppConstants.primaryColor,
                              onTap: () => Navigator.of(context).pushNamed(
                                NetworkRechargeScreen.routeName,
                              ),
                            ),
                            _buildServiceCard(
                              context,
                              title: 'شحن الكهرباء',
                              subtitle: 'دفع فواتير الكهرباء',
                              icon: Icons.electrical_services,
                              color: AppConstants.warningColor,
                              onTap: () => Navigator.of(context).pushNamed(
                                ElectricityPaymentScreen.routeName,
                              ),
                            ),
                            _buildServiceCard(
                              context,
                              title: 'دفع فاتورة المياه',
                              subtitle: 'تسديد فواتير المياه',
                              icon: Icons.water_drop,
                              color: AppConstants.secondaryColor,
                              onTap: () => Navigator.of(context).pushNamed(
                                WaterPaymentScreen.routeName,
                              ),
                            ),
                            _buildServiceCard(
                              context,
                              title: 'الرسوم المدرسية',
                              subtitle: 'دفع رسوم المدارس',
                              icon: Icons.school,
                              color: AppConstants.successColor,
                              onTap: () => Navigator.of(context).pushNamed(
                                FuturisticSchoolPaymentScreen.routeName,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppConstants.primaryColor,
          unselectedItemColor: AppConstants.textSecondary,
          currentIndex: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                // Already on home
                break;
              case 1:
                Navigator.of(context).pushNamed(TransactionsScreen.routeName);
                break;
              case 2:
                Navigator.of(context).pushNamed(FuturisticProfileScreen.routeName);
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'المعاملات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'الحساب',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppConstants.textSecondary,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
