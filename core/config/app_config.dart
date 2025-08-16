import 'package:flutter/foundation.dart';

class AppConfig {
  // Admin Default Credentials
  static const String defaultAdminEmail = 'admin@paypoint.ye';
  static const String defaultAdminPassword = 'PayPoint@2024!';
  static const String defaultAdminName = 'مسؤول النظام';
  static const String defaultAdminPhone = '+967777000000';

  // API Configuration
  static const String apiKey = 'PP_API_KEY_2024_SECURE';
  static const String apiVersion = '1.0.0';
  static const int apiTimeout = 30000; // 30 seconds
  
  // Firebase Configuration
  static const String firebaseProjectId = 'paypoint-yemen';
  static const String firebaseApiKey = 'AIzaSyC8X9Y7Z6A5B4C3D2E1F0G9H8I7J6K5L4M3';
  static const String firebaseAppId = '1:123456789:android:abcdef123456789';
  static const String firebaseMessagingSenderId = '123456789';
  
  // App Configuration
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const bool enableDebugMode = kDebugMode;
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = !kDebugMode;
  
  // Payment Configuration
  static const double minimumRechargeAmount = 100.0;
  static const double maximumRechargeAmount = 50000.0;
  static const double minimumPaymentAmount = 50.0;
  static const double maximumPaymentAmount = 100000.0;
  static const int maxDailyTransactions = 20;
  static const double maxDailyAmount = 200000.0;
  
  // Network Configuration
  static const List<Map<String, dynamic>> supportedNetworks = [
    {
      'id': 'yemenmobile',
      'name': 'يمن موبايل',
      'nameEn': 'Yemen Mobile',
      'color': 0xFF00BCD4,
      'icon': 'assets/icons/yemenmobile.svg',
      'isActive': true,
      'apiEndpoint': 'https://api.yemenmobile.ye',
      'supportedAmounts': [500, 1000, 2000, 5000, 10000],
    },
    {
      'id': 'mtn',
      'name': 'إم تي إن',
      'nameEn': 'MTN',
      'color': 0xFFFFEB3B,
      'icon': 'assets/icons/mtn.svg',
      'isActive': true,
      'apiEndpoint': 'https://api.mtn.ye',
      'supportedAmounts': [500, 1000, 2000, 5000, 10000],
    },
    {
      'id': 'sabafon',
      'name': 'سبأفون',
      'nameEn': 'Sabafon',
      'color': 0xFF4CAF50,
      'icon': 'assets/icons/sabafon.svg',
      'isActive': true,
      'apiEndpoint': 'https://api.sabafon.ye',
      'supportedAmounts': [500, 1000, 2000, 5000, 10000],
    },
    {
      'id': 'why',
      'name': 'واي',
      'nameEn': 'Y',
      'color': 0xFF9C27B0,
      'icon': 'assets/icons/why.svg',
      'isActive': true,
      'apiEndpoint': 'https://api.y.ye',
      'supportedAmounts': [500, 1000, 2000, 5000],
    },
  ];
  
  // Theme Configuration
  static const Map<String, dynamic> themeConfig = {
    'primaryColor': 0xFF1B365D,
    'secondaryColor': 0xFF2E7D9A,
    'accentColor': 0xFFFF6B35,
    'successColor': 0xFF4CAF50,
    'warningColor': 0xFFFF9800,
    'errorColor': 0xFFF44336,
    'backgroundColor': 0xFFF8F9FA,
    'cardColor': 0xFFFFFFFF,
    'textPrimary': 0xFF212529,
    'textSecondary': 0xFF6C757D,
    'fontFamily': 'Cairo',
    'enableDarkMode': true,
    'enableCustomThemes': true,
  };
  
  // Localization Configuration
  static const Map<String, dynamic> localizationConfig = {
    'defaultLocale': 'ar_SA',
    'supportedLocales': ['ar_SA', 'en_US'],
    'enableRTL': true,
    'enableLTR': true,
    'dateFormat': 'yyyy/MM/dd',
    'timeFormat': 'HH:mm',
    'currencyFormat': 'YER',
    'currencySymbol': 'ر.ي',
    'currencyDecimalDigits': 2,
  };
  
  // Security Configuration
  static const Map<String, dynamic> securityConfig = {
    'enableBiometric': true,
    'enablePinCode': true,
    'sessionTimeout': 1800000, // 30 minutes
    'maxLoginAttempts': 5,
    'passwordMinLength': 8,
    'passwordRequireSpecialChar': true,
    'passwordRequireNumber': true,
    'passwordRequireUppercase': true,
    'enableTwoFactor': false,
    'encryptLocalData': true,
  };
  
  // Notification Configuration
  static const Map<String, dynamic> notificationConfig = {
    'enablePushNotifications': true,
    'enableSMSNotifications': true,
    'enableEmailNotifications': true,
    'enableInAppNotifications': true,
    'defaultSoundEnabled': true,
    'defaultVibrationEnabled': true,
    'notificationChannels': [
      {
        'id': 'transactions',
        'name': 'المعاملات',
        'nameEn': 'Transactions',
        'description': 'إشعارات المعاملات والعمليات',
        'importance': 'high',
      },
      {
        'id': 'promotions',
        'name': 'العروض',
        'nameEn': 'Promotions',
        'description': 'إشعارات العروض والخصومات',
        'importance': 'normal',
      },
      {
        'id': 'system',
        'name': 'النظام',
        'nameEn': 'System',
        'description': 'إشعارات النظام والتحديثات',
        'importance': 'high',
      },
    ],
  };
  
  // Features Configuration (Toggle features on/off)
  static const Map<String, bool> featuresConfig = {
    'enableNetworkRecharge': true,
    'enableElectricityPayment': true,
    'enableWaterPayment': true,
    'enableSchoolPayment': true,
    'enableWalletTopup': false,
    'enableBillInquiry': true,
    'enableBalanceInquiry': true,
    'enableTransactionHistory': true,
    'enableQRCodePayment': false,
    'enableNFCPayment': false,
    'enableBankTransfer': false,
    'enableCreditCard': false,
    'enablePayPal': false,
    'enableReferralProgram': false,
    'enableLoyaltyPoints': false,
    'enableCoupons': false,
    'enableGiftCards': false,
    'enableSubscriptions': false,
  };
  
  // Analytics Configuration
  static const Map<String, dynamic> analyticsConfig = {
    'enableFirebaseAnalytics': true,
    'enableCustomAnalytics': true,
    'enableCrashReporting': true,
    'enablePerformanceMonitoring': true,
    'enableUserEngagement': true,
    'analyticsRetentionDays': 90,
    'enableRealTimeAnalytics': true,
  };
  
  // Cache Configuration
  static const Map<String, dynamic> cacheConfig = {
    'enableImageCache': true,
    'enableDataCache': true,
    'imageCacheMaxSize': 104857600, // 100 MB
    'dataCacheMaxSize': 52428800,   // 50 MB
    'cacheExpirationDays': 7,
    'enableOfflineMode': true,
    'syncWhenOnline': true,
  };
  
  // Development Configuration
  static const Map<String, dynamic> developmentConfig = {
    'enableMockApi': kDebugMode,
    'enableTestMode': kDebugMode,
    'enableDebugLogs': kDebugMode,
    'enablePerformanceLogs': kDebugMode,
    'enableNetworkLogs': kDebugMode,
    'mockTransactionDelay': 2000, // 2 seconds
    'enableSimulatedErrors': false,
    'errorSimulationRate': 0.1, // 10%
  };
  
  // Environment-specific configurations
  static Map<String, dynamic> get environment {
    if (kDebugMode) {
      return {
        'name': 'Development',
        'baseUrl': 'https://dev-api.paypoint.ye',
        'enableLogging': true,
        'enableMocking': true,
      };
    } else if (kProfileMode) {
      return {
        'name': 'Staging',
        'baseUrl': 'https://staging-api.paypoint.ye',
        'enableLogging': false,
        'enableMocking': false,
      };
    } else {
      return {
        'name': 'Production',
        'baseUrl': 'https://api.paypoint.ye',
        'enableLogging': false,
        'enableMocking': false,
      };
    }
  }
  
  // Get configuration value by key
  static T getConfig<T>(String key, T defaultValue) {
    try {
      // In a real app, this would read from shared preferences or remote config
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }
  
  // Update configuration value
  static Future<void> setConfig<T>(String key, T value) async {
    try {
      // In a real app, this would save to shared preferences or send to server
    } catch (e) {
      // Handle error
    }
  }
  
  // Validate configuration
  static bool validateConfig() {
    // Add validation logic here
    return true;
  }
  
  // Reset to default configuration
  static Future<void> resetToDefaults() async {
    // Reset all configurations to default values
  }

  // Get supported amounts for a network provider
  static List<int> getSupportedAmounts(String providerId) {
    try {
      final provider = supportedNetworks.firstWhere(
        (network) => network['id'] == providerId,
        orElse: () => <String, dynamic>{},
      );

      if (provider.isNotEmpty && provider['supportedAmounts'] != null) {
        return List<int>.from(provider['supportedAmounts']);
      }

      // Default amounts if provider not found
      return [500, 1000, 2000, 5000, 10000];
    } catch (e) {
      return [500, 1000, 2000, 5000, 10000];
    }
  }

  // Get network provider by ID
  static Map<String, dynamic> getNetworkProvider(String providerId) {
    try {
      return supportedNetworks.firstWhere(
        (network) => network['id'] == providerId,
        orElse: () => <String, dynamic>{},
      );
    } catch (e) {
      return <String, dynamic>{};
    }
  }

  // Check if amount is valid for provider
  static bool isValidAmount(String providerId, int amount) {
    final supportedAmounts = getSupportedAmounts(providerId);
    return supportedAmounts.contains(amount);
  }
}
