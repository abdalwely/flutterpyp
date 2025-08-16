class ValidationService {
  // تحقق من صحة رقم الهاتف اليمني
  static String? validateYemeniPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم الهاتف';
    }

    // إزالة المسافات والأرقام الزائدة
    String cleanedPhone = value.replaceAll(RegExp(r'[^\d]'), '');

    // التحقق من الأرقام اليمنية المقبولة
    if (cleanedPhone.length == 9) {
      // أرقام تبدأ بـ 77, 73, 70, 71, 78
      if (RegExp(r'^(77|73|70|71|78)\d{7}$').hasMatch(cleanedPhone)) {
        return null;
      }
    } else if (cleanedPhone.length == 12) {
      // أرقام تبدأ بـ 967
      if (RegExp(r'^967(77|73|70|71|78)\d{7}$').hasMatch(cleanedPhone)) {
        return null;
      }
    }

    return 'رقم الهاتف غير صحيح. مثال: 77xxxxxxx';
  }

  // تحقق من صحة المبلغ المالي
  static String? validateAmount(String? value, {double? minAmount, double? maxAmount}) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال المبلغ';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'يرجى إدخال رقم صحيح';
    }

    if (amount <= 0) {
      return 'المبلغ يجب أن يكون أكبر من صفر';
    }

    if (minAmount != null && amount < minAmount) {
      return 'الحد الأدنى ${minAmount.toStringAsFixed(0)} ريال';
    }

    if (maxAmount != null && amount > maxAmount) {
      return 'الحد الأقصى ${maxAmount.toStringAsFixed(0)} ريال';
    }

    return null;
  }

  // تحقق من صحة رقم الحساب/العداد
  static String? validateAccountNumber(String? value, {int minLength = 6, int maxLength = 20}) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم الحساب';
    }

    // إزالة المسافات
    String cleanedValue = value.replaceAll(' ', '');

    if (cleanedValue.length < minLength) {
      return 'رقم الحساب يجب أن يكون $minLength أرقام على الأقل';
    }

    if (cleanedValue.length > maxLength) {
      return 'رقم الحساب يجب أن يكون $maxLength رقم على الأكثر';
    }

    // التحقق من أن الرقم يحتوي على أرقام فقط
    if (!RegExp(r'^\d+$').hasMatch(cleanedValue)) {
      return 'رقم الحساب يجب أن يحتوي على أرقام فقط';
    }

    return null;
  }

  // تحقق من صحة رقم الطالب
  static String? validateStudentId(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم الطالب';
    }

    String cleanedValue = value.replaceAll(' ', '');

    if (cleanedValue.length < 4) {
      return 'رقم الطالب يجب أن يكون 4 أرقام على الأقل';
    }

    if (cleanedValue.length > 15) {
      return 'رقم الطالب طويل جداً';
    }

    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(cleanedValue)) {
      return 'رقم الطالب يجب أن يحتوي على أرقام وحروف فقط';
    }

    return null;
  }

  // تحقق من صحة اسم الطالب
  static String? validateStudentName(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال اسم الطالب';
    }

    String trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return 'اسم الطالب قصير جداً';
    }

    if (trimmedValue.length > 50) {
      return 'اسم الطالب طويل جداً';
    }

    // التحقق من أن الاسم يحتوي على حروف فقط (عربي وإنجليزي) ومسافات
    if (!RegExp(r'^[\u0600-\u06FFa-zA-Z\s]+$').hasMatch(trimmedValue)) {
      return 'اسم الطالب يجب أن يحتوي على حروف فقط';
    }

    return null;
  }

  // تحقق من صحة البريد الإلكتروني
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }

    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(pattern).hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  // تحقق من صحة كلمة المرور
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخ��ل كلمة المرور';
    }

    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }

    return null;
  }

  // تحقق من تطابق كلمة المرور
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'يرجى تأكيد كلمة المرور';
    }

    if (value != password) {
      return 'كلمة المرور غير متطابقة';
    }

    return null;
  }

  // تحقق من صحة الاسم الكامل
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال الاسم الكامل';
    }

    String trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return 'الاسم قصير جداً';
    }

    if (trimmedValue.length > 50) {
      return 'الاسم طويل جداً';
    }

    // التحقق من وجود مسافة على الأقل (اسم ولقب)
    if (!trimmedValue.contains(' ')) {
      return 'يرجى إدخال الاسم الكامل (الاسم واللقب)';
    }

    return null;
  }

  // تنسيق رقم الهاتف اليمني
  static String formatYemeniPhone(String phone) {
    String cleanedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanedPhone.length == 9) {
      // إضافة رمز الدولة
      return '+967$cleanedPhone';
    } else if (cleanedPhone.length == 12 && cleanedPhone.startsWith('967')) {
      return '+$cleanedPhone';
    }

    return phone;
  }

  // تنسيق المبلغ المالي
  static String formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  // التحقق من صحة رقم البطاقة الائتمانية (بسيط)
  static String? validateCreditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم البطاقة';
    }

    String cleanedValue = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanedValue.length < 16) {
      return 'رقم البطاقة يجب أن يكون 16 رقم';
    }

    if (cleanedValue.length > 16) {
      return 'رقم البطاقة يجب أن يكون 16 رقم';
    }

    return null;
  }

  // التحقق من صحة CVV
  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال CVV';
    }

    if (value.length != 3) {
      return 'CVV يجب أن يكون 3 أرقام';
    }

    if (!RegExp(r'^\d{3}$').hasMatch(value)) {
      return 'CVV يجب أن يحتوي على أرقام فقط';
    }

    return null;
  }
}
