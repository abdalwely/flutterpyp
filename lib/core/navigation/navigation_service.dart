import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  // التنقل البسيط
  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(routeName, arguments: arguments);
  }

  // التنقل مع استبدال الصفحة الحالية
  static Future<T?> pushReplacementNamed<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments) as Future<T?>;
  }


  // التنقل مع حذف جميع الصفحات السابقة
  static Future<T?> pushNamedAndRemoveUntil<T>(
      String routeName,
      bool Function(Route<dynamic>) predicate, {
        Object? arguments,
      }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  // العودة للخلف
  static void pop<T>([T? result]) {
    return navigatorKey.currentState!.pop<T>(result);
  }

  // التحقق من إمكانية العودة
  static bool canPop() {
    return navigatorKey.currentState!.canPop();
  }

  // التنقل للرئيسية وحذف جميع الصفحات
  static Future<void> goToHome() {
    return pushNamedAndRemoveUntil(
      '/futuristic-dashboard',
          (route) => false,
    );
  }

  // التنقل لصفحة تسجيل الدخول وحذف جميع الصفحات
  static Future<void> goToLogin() {
    return pushNamedAndRemoveUntil(
      '/login',
          (route) => false,
    );
  }

  // عرض رسالة خطأ
  static void showErrorSnackBar(String message) {
    final context = NavigationService.context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
    }
  }

  // عرض رسالة نجاح
  static void showSuccessSnackBar(String message) {
    final context = NavigationService.context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      );
    }
  }

  // عرض حوار التأكيد
  static Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
  }) {
    final context = NavigationService.context;
    if (context == null) return Future.value(false);

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          content: Text(
            content,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                cancelText,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                confirmText,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        );
      },
    );
  }

  // عرض حوار التحميل
  static void showLoadingDialog({String message = 'جاري التحميل...'}) {
    final context = NavigationService.context;
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  // إخفاء حوار التحميل
  static void hideLoadingDialog() {
    final context = NavigationService.context;
    if (context != null && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
