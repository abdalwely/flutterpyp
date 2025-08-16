import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'PayPoint';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'منصة الدفع الإلكتروني الشاملة';
  
  // API Configuration
  static const String apiKey = 'PP_API_KEY_2024_SECURE';
  static const String apiBaseUrl = 'https://api.paypoint.ye';
  static const int apiTimeout = 30000; // 30 seconds
  static const String apiVersion = 'v1';
  
  // Colors (using AppTheme instead)
  static const Color primaryColor = Color(0xFF1B365D);
  static const Color secondaryColor = Color(0xFF2E7D9A);
  static const Color accentColor = Color(0xFFFF6B35);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String cardsCollection = 'wifi_cards';
  static const String transactionsCollection = 'transactions';
  static const String schoolsCollection = 'schools';
  static const String smsLogsCollection = 'sms_logs';

  // Configuration Keys
  static const String languageKey = 'app_language';
  static const String themeKey = 'app_theme';
  static const String firstLaunchKey = 'first_launch';
  static const String userTokenKey = 'user_token';

  // Payment Limits
  static const double minRechargeAmount = 100.0;
  static const double maxRechargeAmount = 50000.0;
  static const double minPaymentAmount = 50.0;
  static const double maxPaymentAmount = 100000.0;
  static const int maxDailyTransactions = 20;
  static const double maxDailyAmount = 200000.0;

  // Network Providers Configuration
  static const List<Map<String, dynamic>> networkProviders = [
    {
      'id': 'yemenmobile',
      'name': 'يمن موبايل',
      'nameEn': 'Yemen Mobile',
      'color': Color(0xFF00BCD4),
      'isActive': true,
      'supportedAmounts': [500, 1000, 2000, 5000, 10000],
    },
    {
      'id': 'mtn',
      'name': 'إم تي إن',
      'nameEn': 'MTN',
      'color': Color(0xFFFFEB3B),
      'isActive': true,
      'supportedAmounts': [500, 1000, 2000, 5000, 10000],
    },
    {
      'id': 'sabafon',
      'name': 'سبأفون',
      'nameEn': 'Sabafon',
      'color': Color(0xFF4CAF50),
      'isActive': true,
      'supportedAmounts': [500, 1000, 2000, 5000, 10000],
    },
    {
      'id': 'why',
      'name': 'واي',
      'nameEn': 'Y',
      'color': Color(0xFF9C27B0),
      'isActive': true,
      'supportedAmounts': [500, 1000, 2000, 5000],
    },
  ];

  // Card Values
  static const List<int> cardValues = [500, 1000, 2000, 5000, 10000];

  // Network Types - إضافة للتوافق مع الكود القديم
  static const List<Map<String, dynamic>> networkTypes = networkProviders;

  // Supported Services
  static const List<Map<String, dynamic>> supportedServices = [
    {
      'id': 'network_recharge',
      'name': 'شحن كروت الشبكة',
      'nameEn': 'Network Recharge',
      'description': 'شحن كروت الإنترنت لجميع الشبكات',
      'icon': Icons.sim_card,
      'color': Color(0xFF1B365D),
      'isActive': true,
      'route': '/network-recharge',
    },
    {
      'id': 'electricity',
      'name': 'شحن الكهرباء',
      'nameEn': 'Electricity Payment',
      'description': 'دفع فواتير الكهرباء',
      'icon': Icons.electrical_services,
      'color': Color(0xFFFF9800),
      'isActive': true,
      'route': '/electricity-payment',
    },
    {
      'id': 'water',
      'name': 'دفع فاتورة المياه',
      'nameEn': 'Water Payment',
      'description': 'تسديد فواتير المياه',
      'icon': Icons.water_drop,
      'color': Color(0xFF2E7D9A),
      'isActive': true,
      'route': '/water-payment',
    },
    {
      'id': 'school',
      'name': 'الرسوم المدرسية',
      'nameEn': 'School Fees',
      'description': 'دفع رسوم المدارس',
      'icon': Icons.school,
      'color': Color(0xFF4CAF50),
      'isActive': true,
      'route': '/school-payment',
    },
  ];

  // Transaction Status
  static const Map<String, Map<String, dynamic>> transactionStatusConfig = {
    'pending': {
      'name': 'قيد المعالجة',
      'nameEn': 'Pending',
      'color': Color(0xFFFF9800),
      'icon': Icons.hourglass_empty,
    },
    'success': {
      'name': 'مكتملة',
      'nameEn': 'Success',
      'color': Color(0xFF4CAF50),
      'icon': Icons.check_circle,
    },
    'failed': {
      'name': 'فاشلة',
      'nameEn': 'Failed',
      'color': Color(0xFFF44336),
      'icon': Icons.error,
    },
    'cancelled': {
      'name': 'ملغية',
      'nameEn': 'Cancelled',
      'color': Color(0xFF6C757D),
      'icon': Icons.cancel,
    },
  };

  // Notification Types
  static const Map<String, Map<String, dynamic>> notificationTypes = {
    'transaction': {
      'name': 'المعاملات',
      'nameEn': 'Transactions',
      'description': 'إشعارات المعاملات والعمليات',
      'color': Color(0xFF1B365D),
      'icon': Icons.receipt,
    },
    'promotion': {
      'name': 'العروض',
      'nameEn': 'Promotions',
      'description': 'إشعارات العروض والخصومات',
      'color': Color(0xFFFF6B35),
      'icon': Icons.local_offer,
    },
    'system': {
      'name': 'النظام',
      'nameEn': 'System',
      'description': 'إشعارات النظام والتحديثات',
      'color': Color(0xFF2196F3),
      'icon': Icons.settings,
    },
  };

  // Currency
  static const String currencySymbol = 'ر.ي';
  static const String currencyCode = 'YER';
  static const String currencyName = 'الريا�� اليمني';

  // Date & Time Formats
  static const String dateFormat = 'yyyy/MM/dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy/MM/dd HH:mm';

  // File Sizes
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 1);
  static const Duration longCacheDuration = Duration(days: 1);

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Error Messages
  static const Map<String, String> errorMessages = {
    'network_error': 'خطأ في الاتصال بالشبكة',
    'server_error': 'خطأ في الخادم',
    'timeout_error': 'انتهت مهلة الاتصال',
    'unknown_error': 'حدث خطأ غير متوقع',
    'validation_error': 'خطأ في التحقق من البيانات',
    'permission_error': 'لا تملك الصلاحية للقيام بهذا الإجراء',
    'insufficient_balance': 'الرصيد غير كافي',
    'service_unavailable': 'الخدمة غير متاحة حالياً',
  };

  // Success Messages
  static const Map<String, String> successMessages = {
    'transaction_success': 'تمت العملية بنجاح',
    'card_purchased': 'تم شراء الكرت بنجاح',
    'payment_completed': 'تم الدفع بنجاح',
    'profile_updated': 'تم تحديث الملف الشخصي',
    'password_changed': 'تم تغيير كلمة المرور',
    'email_verified': 'تم تأكيد البريد الإلكتروني',
  };

  // SMS Templates
  static const Map<String, String> smsTemplates = {
    'wifi_card': '''🎉 تم شراء كرت {provider} بقيمة {value} ريال بنجاح!

💳 كود الكرت: {code}
🔢 الرقم المسلسل: {serial}

📱 PayPoint - خدمات الدفع الإلكتروني
للاستفسار: 777000000''',
    
    'electricity': '''⚡ تم شحن الكهرباء بنجاح!

🔌 العداد: {meter_number}
💰 المبلغ: {amount} ريال
📅 التاريخ: {date}

�� PayPoint - خدمات الدفع الإلكتروني''',
    
    'water': '''💧 تم دفع فاتورة المياه بنجاح!

🏠 رقم الحساب: {account_number}
💰 المبلغ: {amount} ريال
📅 التاريخ: {date}

📱 PayPoint - خدمات الدفع الإلكتروني''',
  };

  // Contact Information
  static const String supportPhone = '+967777000000';
  static const String supportEmail = 'support@paypoint.ye';
  static const String supportWhatsApp = '+967777000000';
  static const String websiteUrl = 'https://www.paypoint.ye';

  // Social Media
  static const String facebookUrl = 'https://facebook.com/paypoint.ye';
  static const String twitterUrl = 'https://twitter.com/paypoint_ye';
  static const String instagramUrl = 'https://instagram.com/paypoint.ye';

  // Helper Methods
  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} $currencySymbol';
  }

  static String formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  static Color getStatusColor(String status) {
    return transactionStatusConfig[status]?['color'] ?? textSecondary;
  }

  static IconData getStatusIcon(String status) {
    return transactionStatusConfig[status]?['icon'] ?? Icons.help_outline;
  }

  static Map<String, dynamic>? getNetworkProvider(String id) {
    try {
      return networkProviders.firstWhere(
        (provider) => provider['id'] == id,
      );
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic>? getService(String id) {
    try {
      return supportedServices.firstWhere(
        (service) => service['id'] == id,
      );
    } catch (e) {
      return null;
    }
  }

  static List<int> getSupportedAmounts(String providerId) {
    final provider = getNetworkProvider(providerId);
    return provider?['supportedAmounts']?.cast<int>() ?? cardValues;
  }

  static bool isValidAmount(String providerId, int amount) {
    final supportedAmounts = getSupportedAmounts(providerId);
    return supportedAmounts.contains(amount);
  }

  static String getProviderName(String providerId) {
    final provider = getNetworkProvider(providerId);
    return provider?['name'] ?? providerId;
  }

  static Color getProviderColor(String providerId) {
    final provider = getNetworkProvider(providerId);
    return provider?['color'] ?? primaryColor;
  }

  static bool isProviderActive(String providerId) {
    final provider = getNetworkProvider(providerId);
    return provider?['isActive'] ?? false;
  }
}
