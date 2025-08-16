import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../navigation/navigation_service.dart';

class ErrorHandler {
  // معالجة أخطاء Firebase Auth
  static String handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لا يوجد مستخدم بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم مسبقاً';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'user-disabled':
        return 'هذا الحساب معطل';
      case 'too-many-requests':
        return 'محاولات كثيرة جداً، يرجى المحاولة لاحقاً';
      case 'operation-not-allowed':
        return 'هذه العملية غير مسموحة';
      case 'invalid-credential':
        return 'بيانات الاعتماد غير صحيحة';
      case 'account-exists-with-different-credential':
        return 'يوجد حساب بهذا البريد الإلكتروني مع طريقة تسجيل دخول مختلفة';
      case 'requires-recent-login':
        return 'يرجى تسجيل الدخول مرة أخرى لتنفيذ هذه العملية';
      case 'provider-already-linked':
        return 'هذا المزود مربوط بالحساب مسبقاً';
      case 'no-such-provider':
        return 'هذا المزود غير مربوط بالحساب';
      case 'invalid-user-token':
        return 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى';
      case 'network-request-failed':
        return 'خطأ في الاتصال بالإنترنت';
      case 'internal-error':
        return 'خطأ داخلي، يرجى المحاولة لاحقاً';
      default:
        return 'حدث خطأ غير متوقع: ${e.message}';
    }
  }

  // معالجة الأخطاء العامة
  static String handleGeneralError(dynamic error) {
    if (error is FirebaseAuthException) {
      return handleFirebaseAuthError(error);
    }

    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }

    return 'حدث خطأ غير متوقع';
  }

  // عرض رسالة خطأ
  static void showError(String message) {
    NavigationService.showErrorSnackBar(message);
  }

  // عرض رسالة نجاح
  static void showSuccess(String message) {
    NavigationService.showSuccessSnackBar(message);
  }

  // معالجة أخطاء الشبكة
  static String handleNetworkError(dynamic error) {
    final errorMessage = error.toString().toLowerCase();

    if (errorMessage.contains('socket') ||
        errorMessage.contains('network') ||
        errorMessage.contains('connection')) {
      return 'خطأ في الاتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى';
    }

    if (errorMessage.contains('timeout')) {
      return 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
    }

    if (errorMessage.contains('404')) {
      return 'الخدمة غير متوفرة حالياً';
    }

    if (errorMessage.contains('500')) {
      return 'خطأ في الخادم. يرجى المحاولة لاحقاً';
    }

    return 'حدث خطأ في الشبكة';
  }

  // معالجة أخطاء الدفع
  static String handlePaymentError(dynamic error) {
    final errorMessage = error.toString().toLowerCase();

    if (errorMessage.contains('insufficient')) {
      return 'الرصيد غير كافي لإتمام العملية';
    }

    if (errorMessage.contains('invalid amount')) {
      return 'المبلغ المدخل غير صحيح';
    }

    if (errorMessage.contains('payment failed')) {
      return 'فشلت عملية الدفع. يرجى المحاولة مرة أخرى';
    }

    if (errorMessage.contains('card')) {
      return 'خطأ في بيانات البطاقة';
    }

    return 'حدث خطأ في عملية الدفع';
  }

  // معالجة أخطاء التحقق
  static String handleValidationError(dynamic error) {
    final errorMessage = error.toString().toLowerCase();

    if (errorMessage.contains('phone')) {
      return 'رقم الهاتف غير صحيح';
    }

    if (errorMessage.contains('email')) {
      return 'البريد الإلكتروني غير صحيح';
    }

    if (errorMessage.contains('amount')) {
      return 'المبلغ المدخل غير صحيح';
    }

    if (errorMessage.contains('required')) {
      return 'يرجى ملء جميع الحقول المطلوبة';
    }

    return 'بيانات غير صحيحة';
  }

  // تسجيل الأخطاء (للمطورين)
  static void logError(String operation, dynamic error, [StackTrace? stackTrace]) {
    print('❌ [ErrorHandler] Operation: $operation');
    print('❌ [ErrorHandler] Error: $error');
    if (stackTrace != null) {
      print('❌ [ErrorHandler] StackTrace: $stackTrace');
    }

    // هنا يمكن إضافة تسجيل الأخطاء في خدمة خارجية مثل Crashlytics
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  // معالجة شاملة للأخطاء مع تصنيف
  static void handleError(
      String operation,
      dynamic error, {
        bool showToUser = true,
        ErrorType? type,
      }) {
    logError(operation, error);

    String userMessage;

    switch (type) {
      case ErrorType.auth:
        userMessage = handleFirebaseAuthError(error as FirebaseAuthException);
        break;
      case ErrorType.network:
        userMessage = handleNetworkError(error);
        break;
      case ErrorType.payment:
        userMessage = handlePaymentError(error);
        break;
      case ErrorType.validation:
        userMessage = handleValidationError(error);
        break;
      case ErrorType.general:
      default:
        userMessage = handleGeneralError(error);
        break;
    }

    if (showToUser) {
      showError(userMessage);
    }
  }
}

enum ErrorType {
  auth,
  network,
  payment,
  validation,
  general,
}

// Extension للاستخدام السهل
extension ErrorHandlerExtension on dynamic {
  void handleAsError(String operation, {ErrorType? type}) {
    ErrorHandler.handleError(operation, this, type: type);
  }
}
