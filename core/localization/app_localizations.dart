import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ar', 'SA'), // Arabic
    Locale('en', 'US'), // English
  ];

  // Common
  String get appName => _getText('app_name');
  String get loading => _getText('loading');
  String get error => _getText('error');
  String get success => _getText('success');
  String get cancel => _getText('cancel');
  String get confirm => _getText('confirm');
  String get save => _getText('save');
  String get edit => _getText('edit');
  String get delete => _getText('delete');
  String get search => _getText('search');
  String get filter => _getText('filter');
  String get refresh => _getText('refresh');
  String get retry => _getText('retry');

  // Authentication
  String get login => _getText('login');
  String get register => _getText('register');
  String get logout => _getText('logout');
  String get email => _getText('email');
  String get password => _getText('password');
  String get confirmPassword => _getText('confirm_password');
  String get forgotPassword => _getText('forgot_password');
  String get resetPassword => _getText('reset_password');
  String get fullName => _getText('full_name');
  String get phoneNumber => _getText('phone_number');
  String get welcome => _getText('welcome');
  String get welcomeBack => _getText('welcome_back');
  String get createAccount => _getText('create_account');
  String get alreadyHaveAccount => _getText('already_have_account');
  String get dontHaveAccount => _getText('dont_have_account');

  // Services
  String get services => _getText('services');
  String get networkRecharge => _getText('network_recharge');
  String get electricityPayment => _getText('electricity_payment');
  String get waterPayment => _getText('water_payment');
  String get schoolPayment => _getText('school_payment');
  String get selectNetwork => _getText('select_network');
  String get selectAmount => _getText('select_amount');
  String get cardCode => _getText('card_code');
  String get serialNumber => _getText('serial_number');
  String get meterNumber => _getText('meter_number');
  String get accountNumber => _getText('account_number');
  String get customerName => _getText('customer_name');
  String get studentName => _getText('student_name');
  String get studentId => _getText('student_id');
  String get school => _getText('school');
  String get amount => _getText('amount');
  String get total => _getText('total');
  String get balance => _getText('balance');
  String get availableBalance => _getText('available_balance');

  // Transactions
  String get transactions => _getText('transactions');
  String get transactionHistory => _getText('transaction_history');
  String get transactionDetails => _getText('transaction_details');
  String get transactionId => _getText('transaction_id');
  String get transactionType => _getText('transaction_type');
  String get transactionStatus => _getText('transaction_status');
  String get transactionDate => _getText('transaction_date');
  String get referenceNumber => _getText('reference_number');
  String get pending => _getText('pending');
  String get completed => _getText('completed');
  String get failed => _getText('failed');
  String get cancelled => _getText('cancelled');

  // Dashboard
  String get dashboard => _getText('dashboard');
  String get home => _getText('home');
  String get profile => _getText('profile');
  String get settings => _getText('settings');
  String get statistics => _getText('statistics');
  String get reports => _getText('reports');

  // Admin
  String get adminPanel => _getText('admin_panel');
  String get userManagement => _getText('user_management');
  String get cardManagement => _getText('card_management');
  String get transactionManagement => _getText('transaction_management');
  String get schoolManagement => _getText('school_management');
  String get systemSettings => _getText('system_settings');
  String get addCards => _getText('add_cards');
  String get viewCards => _getText('view_cards');
  String get addSchool => _getText('add_school');
  String get schoolsList => _getText('schools_list');

  // Messages
  String get successfulTransaction => _getText('successful_transaction');
  String get failedTransaction => _getText('failed_transaction');
  String get insufficientBalance => _getText('insufficient_balance');
  String get invalidCredentials => _getText('invalid_credentials');
  String get networkError => _getText('network_error');
  String get serverError => _getText('server_error');
  String get validationError => _getText('validation_error');
  String get cardNotAvailable => _getText('card_not_available');
  String get transactionCompleted => _getText('transaction_completed');
  String get emailSent => _getText('email_sent');
  String get passwordUpdated => _getText('password_updated');
  String get profileUpdated => _getText('profile_updated');

  // Validation
  String get requiredField => _getText('required_field');
  String get invalidEmail => _getText('invalid_email');
  String get invalidPhone => _getText('invalid_phone');
  String get passwordTooShort => _getText('password_too_short');
  String get passwordMismatch => _getText('password_mismatch');
  String get invalidAmount => _getText('invalid_amount');
  String get minimumAmount => _getText('minimum_amount');

  // UI Elements
  String get next => _getText('next');
  String get previous => _getText('previous');
  String get finish => _getText('finish');
  String get submit => _getText('submit');
  String get purchase => _getText('purchase');
  String get pay => _getText('pay');
  String get send => _getText('send');
  String get receive => _getText('receive');
  String get copy => _getText('copy');
  String get copied => _getText('copied');
  String get share => _getText('share');
  String get download => _getText('download');
  String get print => _getText('print');

  // Settings
  String get language => _getText('language');
  String get arabic => _getText('arabic');
  String get english => _getText('english');
  String get notifications => _getText('notifications');
  String get privacy => _getText('privacy');
  String get terms => _getText('terms');
  String get about => _getText('about');
  String get version => _getText('version');
  String get contactSupport => _getText('contact_support');
  String get helpCenter => _getText('help_center');

  String _getText(String key) {
    return _localizedStrings[locale.languageCode]?[key] ?? key;
  }

  static const Map<String, Map<String, String>> _localizedStrings = {
    'ar': {
      // Common
      'app_name': 'باي بوينت',
      'loading': 'جاري ��لتحميل...',
      'error': 'خطأ',
      'success': 'نجح',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'save': 'حفظ',
      'edit': 'تعديل',
      'delete': 'حذف',
      'search': 'البحث',
      'filter': 'تصفية',
      'refresh': 'تحديث',
      'retry': 'إعادة المحاولة',

      // Authentication
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'logout': 'تسجيل الخروج',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirm_password': 'تأكيد كلمة المرور',
      'forgot_password': 'نسيت كلمة المرور؟',
      'reset_password': 'إعادة تعيين كلمة المرور',
      'full_name': 'الاسم الكامل',
      'phone_number': 'رقم الهاتف',
      'welcome': 'مرحباً',
      'welcome_back': 'مرحباً بعودتك',
      'create_account': 'إنشاء حساب جديد',
      'already_have_account': 'لديك حساب بالفعل؟',
      'dont_have_account': 'ليس لديك حساب؟',

      // Services
      'services': 'الخدمات',
      'network_recharge': 'شحن كروت الشبكة',
      'electricity_payment': 'شحن الكهرباء',
      'water_payment': 'دفع فاتورة المياه',
      'school_payment': 'دفع الرسوم المدرسية',
      'select_network': 'اختر الشبكة',
      'select_amount': 'اختر المبلغ',
      'card_code': 'رقم الكرت',
      'serial_number': 'الرقم التسلسلي',
      'meter_number': 'رقم العداد',
      'account_number': 'رقم الحساب',
      'customer_name': 'اسم العميل',
      'student_name': 'اسم الطالب',
      'student_id': 'رقم الطالب',
      'school': 'المدرسة',
      'amount': 'المبلغ',
      'total': 'المجموع',
      'balance': 'الرصيد',
      'available_balance': 'الرصيد المتاح',

      // Transactions
      'transactions': 'المعاملات',
      'transaction_history': 'سجل المعاملات',
      'transaction_details': 'تفاصيل المعاملة',
      'transaction_id': 'رقم المعاملة',
      'transaction_type': 'نوع المعاملة',
      'transaction_status': 'حالة المعاملة',
      'transaction_date': 'تاريخ المعاملة',
      'reference_number': 'رقم المرجع',
      'pending': 'قيد المعالجة',
      'completed': 'مكتملة',
      'failed': 'فاشلة',
      'cancelled': 'ملغية',

      // Dashboard
      'dashboard': 'الرئيسية',
      'home': 'الرئيسية',
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'statistics': 'الإحصائيات',
      'reports': 'التقارير',

      // Admin
      'admin_panel': 'لوحة تحكم المسؤول',
      'user_management': 'إدارة المستخدمين',
      'card_management': 'إدارة الكروت',
      'transaction_management': 'إدارة المعاملات',
      'school_management': 'إدارة المدارس',
      'system_settings': 'إعدادات النظام',
      'add_cards': 'إضافة كروت',
      'view_cards': 'عرض الكروت',
      'add_school': 'إضافة مدرسة',
      'schools_list': 'قائمة المدارس',

      // Messages
      'successful_transaction': 'تمت العملية بنجاح',
      'failed_transaction': 'فشلت العملية',
      'insufficient_balance': 'رصيد غير كافي',
      'invalid_credentials': 'بيانات دخول خاطئة',
      'network_error': 'خطأ في الشبكة',
      'server_error': 'خطأ في الخادم',
      'validation_error': 'خطأ في التحقق',
      'card_not_available': 'لا توجد كروت متاحة',
      'transaction_completed': 'تمت المعاملة بنجاح',
      'email_sent': 'تم إرسال البريد الإلكتروني',
      'password_updated': 'تم تحديث كلمة المرور',
      'profile_updated': 'تم تحديث الملف الشخصي',

      // Validation
      'required_field': 'هذا الحقل مطلوب',
      'invalid_email': 'بريد إلكتروني غير صحيح',
      'invalid_phone': 'رقم هاتف غير صحيح',
      'password_too_short': 'كلمة المرور قصيرة جداً',
      'password_mismatch': 'كلمة المرور غير متطابقة',
      'invalid_amount': 'مبلغ غير صحيح',
      'minimum_amount': 'الحد الأدنى للمبلغ',

      // UI Elements
      'next': 'التالي',
      'previous': 'السابق',
      'finish': 'إنهاء',
      'submit': 'إرسال',
      'purchase': 'شراء',
      'pay': 'دفع',
      'send': 'إرسال',
      'receive': 'استقبال',
      'copy': 'نسخ',
      'copied': 'تم النسخ',
      'share': 'مشاركة',
      'download': 'تحميل',
      'print': 'طباعة',

      // Settings
      'language': 'اللغة',
      'arabic': 'العربية',
      'english': 'الإنجليزية',
      'notifications': 'الإشعارات',
      'privacy': 'الخصوصية',
      'terms': 'الشروط والأحكام',
      'about': 'حول التطبيق',
      'version': 'الإصدار',
      'contact_support': 'اتصل بالدعم',
      'help_center': 'مركز المساعدة',
    },
    'en': {
      // Common
      'app_name': 'PayPoint',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'edit': 'Edit',
      'delete': 'Delete',
      'search': 'Search',
      'filter': 'Filter',
      'refresh': 'Refresh',
      'retry': 'Retry',

      // Authentication
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'forgot_password': 'Forgot Password?',
      'reset_password': 'Reset Password',
      'full_name': 'Full Name',
      'phone_number': 'Phone Number',
      'welcome': 'Welcome',
      'welcome_back': 'Welcome Back',
      'create_account': 'Create Account',
      'already_have_account': 'Already have an account?',
      'dont_have_account': 'Don\'t have an account?',

      // Services
      'services': 'Services',
      'network_recharge': 'Network Recharge',
      'electricity_payment': 'Electricity Payment',
      'water_payment': 'Water Payment',
      'school_payment': 'School Payment',
      'select_network': 'Select Network',
      'select_amount': 'Select Amount',
      'card_code': 'Card Code',
      'serial_number': 'Serial Number',
      'meter_number': 'Meter Number',
      'account_number': 'Account Number',
      'customer_name': 'Customer Name',
      'student_name': 'Student Name',
      'student_id': 'Student ID',
      'school': 'School',
      'amount': 'Amount',
      'total': 'Total',
      'balance': 'Balance',
      'available_balance': 'Available Balance',

      // Transactions
      'transactions': 'Transactions',
      'transaction_history': 'Transaction History',
      'transaction_details': 'Transaction Details',
      'transaction_id': 'Transaction ID',
      'transaction_type': 'Transaction Type',
      'transaction_status': 'Transaction Status',
      'transaction_date': 'Transaction Date',
      'reference_number': 'Reference Number',
      'pending': 'Pending',
      'completed': 'Completed',
      'failed': 'Failed',
      'cancelled': 'Cancelled',

      // Dashboard
      'dashboard': 'Dashboard',
      'home': 'Home',
      'profile': 'Profile',
      'settings': 'Settings',
      'statistics': 'Statistics',
      'reports': 'Reports',

      // Admin
      'admin_panel': 'Admin Panel',
      'user_management': 'User Management',
      'card_management': 'Card Management',
      'transaction_management': 'Transaction Management',
      'school_management': 'School Management',
      'system_settings': 'System Settings',
      'add_cards': 'Add Cards',
      'view_cards': 'View Cards',
      'add_school': 'Add School',
      'schools_list': 'Schools List',

      // Messages
      'successful_transaction': 'Transaction Successful',
      'failed_transaction': 'Transaction Failed',
      'insufficient_balance': 'Insufficient Balance',
      'invalid_credentials': 'Invalid Credentials',
      'network_error': 'Network Error',
      'server_error': 'Server Error',
      'validation_error': 'Validation Error',
      'card_not_available': 'No Cards Available',
      'transaction_completed': 'Transaction Completed Successfully',
      'email_sent': 'Email Sent',
      'password_updated': 'Password Updated',
      'profile_updated': 'Profile Updated',

      // Validation
      'required_field': 'This field is required',
      'invalid_email': 'Invalid email address',
      'invalid_phone': 'Invalid phone number',
      'password_too_short': 'Password is too short',
      'password_mismatch': 'Passwords do not match',
      'invalid_amount': 'Invalid amount',
      'minimum_amount': 'Minimum amount',

      // UI Elements
      'next': 'Next',
      'previous': 'Previous',
      'finish': 'Finish',
      'submit': 'Submit',
      'purchase': 'Purchase',
      'pay': 'Pay',
      'send': 'Send',
      'receive': 'Receive',
      'copy': 'Copy',
      'copied': 'Copied',
      'share': 'Share',
      'download': 'Download',
      'print': 'Print',

      // Settings
      'language': 'Language',
      'arabic': 'Arabic',
      'english': 'English',
      'notifications': 'Notifications',
      'privacy': 'Privacy',
      'terms': 'Terms & Conditions',
      'about': 'About',
      'version': 'Version',
      'contact_support': 'Contact Support',
      'help_center': 'Help Center',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
