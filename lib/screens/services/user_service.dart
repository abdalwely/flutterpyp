import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';


class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // تحديث بيانات المستخدم
  static Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      // إعداد البيانات للتحديث
      final Map<String, dynamic> updateData = {};

      if (name != null && name.isNotEmpty) {
        updateData['name'] = name;
      }

      if (phone != null && phone.isNotEmpty) {
        updateData['phone'] = phone;
      }

      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }

      // إضافة وقت آخر تحديث
      updateData['lastUpdatedAt'] = Timestamp.fromDate(DateTime.now());

      // تحديث البيانات في Firestore
      await userRef.update(updateData);

      // تحديث بيانات Firebase Auth إذا تم تحديث الاسم أو الصورة
      final user = _auth.currentUser;
      if (user != null) {
        if (name != null && name.isNotEmpty) {
          await user.updateDisplayName(name);
        }
        if (photoUrl != null) {
          await user.updatePhotoURL(photoUrl);
        }
      }

      // جلب البيانات المحدثة
      final updatedDoc = await userRef.get();
      return UserModel.fromFirestore(updatedDoc);

    } catch (e) {
      throw Exception('خطأ في تحديث بيانات المستخدم: ${e.toString()}');
    }
  }

  // تحديث صورة الملف الشخصي
  static Future<UserModel> updateProfileImage({
    required String userId,
    required String imageUrl,
  }) async {
    try {
      return await updateUserProfile(
        userId: userId,
        photoUrl: imageUrl,
      );
    } catch (e) {
      throw Exception('خطأ في تحديث صورة الملف الشخصي: ${e.toString()}');
    }
  }

  // تحديث اسم المستخدم
  static Future<UserModel> updateUserName({
    required String userId,
    required String name,
  }) async {
    try {
      if (name.trim().isEmpty) {
        throw Exception('اسم المستخدم لا يمكن أن يكون فارغاً');
      }

      return await updateUserProfile(
        userId: userId,
        name: name.trim(),
      );
    } catch (e) {
      throw Exception('خطأ في تحديث اسم المستخدم: ${e.toString()}');
    }
  }

  // تحديث رقم الهاتف
  static Future<UserModel> updatePhoneNumber({
    required String userId,
    required String phone,
  }) async {
    try {
      // التحقق من صحة رقم الهاتف
      if (!isValidPhoneNumber(phone)) {
        throw Exception('رقم الهاتف غير صحيح');
      }

      return await updateUserProfile(
        userId: userId,
        phone: phone.trim(),
      );
    } catch (e) {
      throw Exception('خطأ في تحديث رقم الهاتف: ${e.toString()}');
    }
  }

  // تحديث كلمة المرور
  static Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('المستخدم غير مسجل الدخول');
      }

      // التحقق من كلمة المرور الحالية
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // تحديث كلمة المرور
      await user.updatePassword(newPassword);

    } catch (e) {
      if (e.toString().contains('wrong-password')) {
        throw Exception('كلمة المرور الحالية غير صحيحة');
      } else if (e.toString().contains('weak-password')) {
        throw Exception('كلمة المرور الجديدة ضعيفة');
      }
      throw Exception('خطأ في تحديث كلمة المرور: ${e.toString()}');
    }
  }

  // حذف صورة الملف الشخصي
  static Future<UserModel> removeProfileImage(String userId) async {
    try {
      return await updateUserProfile(
        userId: userId,
        photoUrl: null,
      );
    } catch (e) {
      throw Exception('خطأ في حذف صورة الملف الشخصي: ${e.toString()}');
    }
  }

  // جلب بيانات المستخدم
  static Future<UserModel?> getUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }
      return null;

    } catch (e) {
      throw Exception('خطأ في جلب بيانات المستخدم: ${e.toString()}');
    }
  }

  // التحقق من صحة رقم الهاتف اليمني
  static bool isValidPhoneNumber(String phone) {
    // إزالة المسافات والرموز
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // الأنماط المقبولة لأرقام الهاتف اليمنية
    final yemenPatterns = [
      RegExp(r'^(\+967|967|00967)?[137][0-9]{7}$'), // أرقام الجوال
      RegExp(r'^(\+967|967|00967)?[1-7][0-9]{6}$'), // أرقام الثابت
    ];

    return yemenPatterns.any((pattern) => pattern.hasMatch(cleanPhone));
  }

  // التحقق من صحة الاسم
  static bool isValidName(String name) {
    if (name.trim().isEmpty) return false;
    if (name.trim().length < 2) return false;
    if (name.trim().length > 50) return false;

    // التحقق من وجود أحرف عربية أو إنجليزية فقط
    final namePattern = RegExp(r'^[\u0600-\u06FFa-zA-Z\s]+$');
    return namePattern.hasMatch(name.trim());
  }

  // تحديث وقت آخر دخول
  static Future<void> updateLastLoginTime(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      // يمكن تجاهل هذا الخطأ لأنه ليس حرجاً
      print('تحذير: لم يتم تحديث وقت آخر دخول: $e');
    }
  }

  // تحديث الرصيد (للإدارة فقط)
  static Future<UserModel> updateUserBalance({
    required String userId,
    required double newBalance,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await userRef.update({
        'balance': newBalance,
        'lastUpdatedAt': Timestamp.fromDate(DateTime.now()),
      });

      final updatedDoc = await userRef.get();
      return UserModel.fromFirestore(updatedDoc);

    } catch (e) {
      throw Exception('خطأ في تحديث الرصيد: ${e.toString()}');
    }
  }

  // إضافة مبلغ للرصيد
  static Future<UserModel> addToBalance({
    required String userId,
    required double amount,
  }) async {
    try {
      if (amount <= 0) {
        throw Exception('المبلغ يجب أن يكون أكبر من صفر');
      }

      return await _firestore.runTransaction<UserModel>((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('المستخدم غير موجود');
        }

        final currentUser = UserModel.fromFirestore(userDoc);
        final newBalance = currentUser.balance + amount;

        transaction.update(userRef, {
          'balance': newBalance,
          'lastUpdatedAt': Timestamp.fromDate(DateTime.now()),
        });

        return currentUser.copyWith(balance: newBalance);
      });

    } catch (e) {
      throw Exception('خطأ في إضافة مبلغ للرصيد: ${e.toString()}');
    }
  }

  // خصم مبلغ من الرصيد
  static Future<UserModel> deductFromBalance({
    required String userId,
    required double amount,
  }) async {
    try {
      if (amount <= 0) {
        throw Exception('المبلغ يجب أن يكون أكبر من صفر');
      }

      return await _firestore.runTransaction<UserModel>((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('المستخدم غير موجود');
        }

        final currentUser = UserModel.fromFirestore(userDoc);

        if (currentUser.balance < amount) {
          throw Exception('الرصيد غير كافي');
        }

        final newBalance = currentUser.balance - amount;

        transaction.update(userRef, {
          'balance': newBalance,
          'lastUpdatedAt': Timestamp.fromDate(DateTime.now()),
        });

        return currentUser.copyWith(balance: newBalance);
      });

    } catch (e) {
      throw Exception('خطأ في خصم مبلغ من الرصيد: ${e.toString()}');
    }
  }

  // حذف حساب المستخدم
  static Future<void> deleteUserAccount(String userId) async {
    try {
      // حذف المستخدم من Firestore
      await _firestore.collection('users').doc(userId).delete();

      // حذف حساب Firebase Auth
      final user = _auth.currentUser;
      if (user != null && user.uid == userId) {
        await user.delete();
      }

    } catch (e) {
      throw Exception('خطأ في حذف الحساب: ${e.toString()}');
    }
  }
}
