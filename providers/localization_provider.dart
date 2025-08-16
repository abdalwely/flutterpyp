import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Locale Provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'selected_locale';
  
  LocaleNotifier() : super(const Locale('ar', 'SA')) {
    _loadLocale();
  }

  // Load saved locale from preferences
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);
      
      if (localeCode != null) {
        final parts = localeCode.split('_');
        if (parts.length == 2) {
          state = Locale(parts[0], parts[1]);
        }
      }
    } catch (e) {
      // Use default locale if loading fails
      state = const Locale('ar', 'SA');
    }
  }

  // Change locale and save to preferences
  Future<void> changeLocale(Locale newLocale) async {
    try {
      state = newLocale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, '${newLocale.languageCode}_${newLocale.countryCode}');
    } catch (e) {
      // Handle error
    }
  }

  // Toggle between Arabic and English
  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'ar' 
        ? const Locale('en', 'US')
        : const Locale('ar', 'SA');
    await changeLocale(newLocale);
  }

  // Check if current locale is RTL
  bool get isRTL => state.languageCode == 'ar';
  
  // Check if current locale is Arabic
  bool get isArabic => state.languageCode == 'ar';
  
  // Get text direction for current locale
  TextDirection get textDirection => isRTL ? TextDirection.rtl : TextDirection.ltr;
}

// Text Direction Provider
final textDirectionProvider = Provider<TextDirection>((ref) {
  final locale = ref.watch(localeProvider);
  return locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
});

// Is RTL Provider
final isRTLProvider = Provider<bool>((ref) {
  final locale = ref.watch(localeProvider);
  return locale.languageCode == 'ar';
});

// Language Name Provider
final languageNameProvider = Provider<String>((ref) {
  final locale = ref.watch(localeProvider);
  return locale.languageCode == 'ar' ? 'العربية' : 'English';
});

// Available Locales Provider
final availableLocalesProvider = Provider<List<LocaleOption>>((ref) {
  return [
    LocaleOption(
      locale: const Locale('ar', 'SA'),
      name: 'العربية',
      nativeName: 'العربية',
      flag: '🇸🇦',
    ),
    LocaleOption(
      locale: const Locale('en', 'US'),
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
    ),
  ];
});

class LocaleOption {
  final Locale locale;
  final String name;
  final String nativeName;
  final String flag;

  LocaleOption({
    required this.locale,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

// Extension for easy access to localization context
extension LocalizationContext on BuildContext {
  Locale get locale => Localizations.localeOf(this);
  bool get isRTL => locale.languageCode == 'ar';
  bool get isArabic => locale.languageCode == 'ar';
  TextDirection get textDirection => isRTL ? TextDirection.rtl : TextDirection.ltr;
}

// Localized text helper
class L10n {
  static const Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'app_name': 'باي بوينت',
      'welcome': 'مرحباً',
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'services': 'الخدمات',
      'network_recharge': 'شحن كروت الشبكة',
      'electricity_payment': 'شحن الكهرباء',
      'water_payment': 'دفع فاتورة المياه',
      'school_payment': 'دفع الرسوم المدرسية',
      'transactions': 'المعاملات',
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'language': 'اللغة',
      'amount': 'المبلغ',
      'balance': 'الرصيد',
      'success': 'نجح',
      'failed': 'فشل',
      'pending': 'قيد المعالجة',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'retry': 'إعادة المحاولة',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'save': 'حفظ',
      'edit': 'تعديل',
      'delete': 'حذف',
      'search': 'البحث',
      'filter': 'تصفية',
      'refresh': 'تحديث',
      'logout': 'تسجيل الخروج',
      'admin_panel': 'لوحة تحكم المسؤول',
      'dashboard': 'الرئيسية',
      'statistics': 'الإحصائيات',
      'reports': 'التقارير',
      'notifications': 'الإشعارات',
      'help': 'المساعدة',
      'about': 'حول التطبيق',
      'version': 'الإصدار',
      'contact_support': 'اتصل بالدعم',
    },
    'en': {
      'app_name': 'PayPoint',
      'welcome': 'Welcome',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'services': 'Services',
      'network_recharge': 'Network Recharge',
      'electricity_payment': 'Electricity Payment',
      'water_payment': 'Water Payment',
      'school_payment': 'School Payment',
      'transactions': 'Transactions',
      'profile': 'Profile',
      'settings': 'Settings',
      'language': 'Language',
      'amount': 'Amount',
      'balance': 'Balance',
      'success': 'Success',
      'failed': 'Failed',
      'pending': 'Pending',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'edit': 'Edit',
      'delete': 'Delete',
      'search': 'Search',
      'filter': 'Filter',
      'refresh': 'Refresh',
      'logout': 'Logout',
      'admin_panel': 'Admin Panel',
      'dashboard': 'Dashboard',
      'statistics': 'Statistics',
      'reports': 'Reports',
      'notifications': 'Notifications',
      'help': 'Help',
      'about': 'About',
      'version': 'Version',
      'contact_support': 'Contact Support',
    },
  };

  static String getString(BuildContext context, String key) {
    final locale = Localizations.localeOf(context);
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  static String getStringByLocale(String languageCode, String key) {
    return _localizedValues[languageCode]?[key] ?? key;
  }
}

// Quick localization access
String tr(BuildContext context, String key) {
  return L10n.getString(context, key);
}
