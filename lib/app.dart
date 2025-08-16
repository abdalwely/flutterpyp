import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypoint/screens/admin/futuristic_admin_dashboard.dart';
import 'package:paypoint/screens/profile/futurist_profile_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'providers/localization_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/futuristic_login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/futuristic_register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/enhanced_dashboard_screen.dart';
import 'screens/home/futuristic_dashboard_screen.dart';
import 'screens/services/network_recharge_screen.dart';
import 'screens/services/futuristic_network_recharge_screen.dart';
import 'screens/services/electricity_payment_screen.dart';
import 'screens/services/futuristic_electricity_payment_screen.dart';
import 'screens/services/water_payment_screen.dart';
import 'screens/services/futuristic_water_payment_screen.dart';
import 'screens/services/school_payment_screen.dart';
import 'screens/services/futuristic_school_payment_screen.dart';
import 'screens/wallet/wallet_charge_screen.dart';
import 'screens/transactions/transactions_screen.dart';
import 'screens/transactions/futuristic_transactions_screen.dart';
import 'screens/transactions/transaction_result_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/cards_management_screen.dart';
import 'screens/admin/transactions_admin_screen.dart';
import 'screens/admin/schools_management_screen.dart';
import 'widgets/animated_widgets.dart';

class PayPointApp extends ConsumerWidget {
  const PayPointApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final textDirection = ref.watch(textDirectionProvider);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.surfaceColor,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    return MaterialApp(
      title: 'PayPoint',
      debugShowCheckedModeBanner: false,

      // Localization
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Theme
      theme: AppTheme.lightTheme,

      // Builder with direction support
      builder: (context, child) {
        return Directionality(
          textDirection: textDirection,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0, // Prevent font scaling
            ),
            child: child!,
          ),
        );
      },

      // Navigation
      initialRoute: SplashScreen.routeName,
      onGenerateRoute: _generateRoute,

      // Handle unknown routes
      onUnknownRoute: (settings) {
        return CustomPageRoute(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('صفحة غير موجودة'),
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'الصفحة المطلوبة غير موجودة',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ),
          transitionType: PageTransitionType.fade,
        );
      },
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    Widget page;
    PageTransitionType transitionType = PageTransitionType.slideFromRight;

    switch (settings.name) {
    // Splash & Auth
      case SplashScreen.routeName:
        page = const SplashScreen();
        transitionType = PageTransitionType.fade;
        break;

      case LoginScreen.routeName:
        page = const FuturisticLoginScreen();
        transitionType = PageTransitionType.slideFromBottom;
        break;

      case FuturisticLoginScreen.routeName:
        page = const FuturisticLoginScreen();
        transitionType = PageTransitionType.slideFromBottom;
        break;

      case RegisterScreen.routeName:
        page = const FuturisticRegisterScreen();
        transitionType = PageTransitionType.slideFromRight;
        break;

      case FuturisticRegisterScreen.routeName:
        page = const FuturisticRegisterScreen();
        transitionType = PageTransitionType.slideFromRight;
        break;

      case ForgotPasswordScreen.routeName:
        page = const ForgotPasswordScreen();
        transitionType = PageTransitionType.slideFromRight;
        break;

    // Main App
      case EnhancedDashboardScreen.routeName:
        page = const EnhancedDashboardScreen();
        transitionType = PageTransitionType.fade;
        break;

      case FuturisticDashboardScreen.routeName:
        page = const FuturisticDashboardScreen();
        transitionType = PageTransitionType.fade;
        break;

    // Services
      case NetworkRechargeScreen.routeName:
        page = const NetworkRechargeScreen();
        break;

      case FuturisticNetworkRechargeScreen.routeName:
        page = const FuturisticNetworkRechargeScreen();
        break;

      case ElectricityPaymentScreen.routeName:
        page = const ElectricityPaymentScreen();
        break;

      case WaterPaymentScreen.routeName:
        page = const WaterPaymentScreen();
        break;

      case SchoolPaymentScreen.routeName:
        page = const SchoolPaymentScreen();
        break;

    // Futuristic Services
      case '/futuristic-electricity-payment':
        page = const FuturisticElectricityPaymentScreen();
        break;

      case '/futuristic-water-payment':
        page = const FuturisticWaterPaymentScreen();
        break;

      case '/futuristic-school-payment':
        page = const FuturisticSchoolPaymentScreen();
        break;

    // Wallet
      case WalletChargeScreen.routeName:
      case '/wallet-charge':
        page = const WalletChargeScreen();
        break;

    // Transactions
      case TransactionsScreen.routeName:
        page = const FuturisticTransactionsScreen();
        break;

      case FuturisticTransactionsScreen.routeName:
        page = const FuturisticTransactionsScreen();
        break;

      case TransactionResultScreen.routeName:
        page = const TransactionResultScreen();
        transitionType = PageTransitionType.scale;
        break;

    // Profile
      case FuturisticProfileScreen.routeName:
        page = const FuturisticProfileScreen();
        break;

    // Admin
      case FuturisticAdminDashboardScreen.routeName:
        page = const FuturisticAdminDashboardScreen();
        transitionType = PageTransitionType.slideFromTop;
        break;

      case CardsManagementScreen.routeName:
        page = const CardsManagementScreen();
        break;

      case TransactionsAdminScreen.routeName:
        page = const TransactionsAdminScreen();
        break;

      case SchoolsManagementScreen.routeName:
        page = const SchoolsManagementScreen();
        break;

      default:
        return null;
    }

    return CustomPageRoute(
      child: page,
      transitionType: transitionType,
      duration: const Duration(milliseconds: 300),
    );
  }
}

// Route names class for better organization
class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main routes
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Service routes
  static const String networkRecharge = '/services/network-recharge';
  static const String electricityPayment = '/services/electricity-payment';
  static const String waterPayment = '/services/water-payment';
  static const String schoolPayment = '/services/school-payment';

  // Transaction routes
  static const String transactions = '/transactions';
  static const String transactionResult = '/transaction-result';

  // Admin routes
  static const String adminDashboard = '/admin';
  static const String cardsManagement = '/admin/cards';
  static const String transactionsAdmin = '/admin/transactions';
  static const String schoolsManagement = '/admin/schools';
  static const String usersManagement = '/admin/users';
  static const String systemSettings = '/admin/settings';

  // Helper method to navigate with custom transition
  static void navigateTo(
      BuildContext context,
      String routeName, {
        Map<String, dynamic>? arguments,
        PageTransitionType? transitionType,
        bool replace = false,
      }) {
    final route = CustomPageRoute(
      child: _getPageForRoute(routeName, arguments),
      transitionType: transitionType ?? PageTransitionType.slideFromRight,
    );

    if (replace) {
      Navigator.of(context).pushReplacement(route);
    } else {
      Navigator.of(context).push(route);
    }
  }

  static Widget _getPageForRoute(String routeName, Map<String, dynamic>? args) {
    switch (routeName) {
      case splash:
        return const SplashScreen();
      case login:
        return const LoginScreen();
      case register:
        return const RegisterScreen();
      case forgotPassword:
        return const ForgotPasswordScreen();
      case dashboard:
        return const EnhancedDashboardScreen();
      case networkRecharge:
        return const NetworkRechargeScreen();
      case electricityPayment:
        return const ElectricityPaymentScreen();
      case waterPayment:
        return const WaterPaymentScreen();
      case schoolPayment:
        return const SchoolPaymentScreen();
      case transactions:
        return const TransactionsScreen();
      case transactionResult:
        return const TransactionResultScreen();
      case profile:
        return const FuturisticProfileScreen();
      case adminDashboard:
        return const FuturisticAdminDashboardScreen();
      case cardsManagement:
        return const CardsManagementScreen();
      case transactionsAdmin:
        return const TransactionsAdminScreen();
      case schoolsManagement:
        return const SchoolsManagementScreen();
      default:
        return const Scaffold(
          body: Center(
            child: Text('Page not found'),
          ),
        );
    }
  }
}
