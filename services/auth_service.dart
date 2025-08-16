import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/config/app_config.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // الحصول على المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  // Stream للمصادقة
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<UserCredential> signInWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // تحديث آخر دخول
      if (credential.user != null) {
        await _updateLastLogin(credential.user!.uid);
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  // إنشاء حساب جديد
  Future<UserCredential> createUserWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  // إرسال رسالة إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('حدث خطأ في إرسال البريد الإلكتروني');
    }
  }

  // إرسال رسالة تأكيد الب��يد الإلكتروني
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('خطأ في إرسال رسالة التأكيد');
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('خطأ في تسجيل الخروج');
    }
  }

  // حذف الحساب
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // حذف بيانات المستخدم من Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // حذف الحساب من Firebase Auth
        await user.delete();
      }
    } catch (e) {
      throw Exception('خطأ في حذف الحساب');
    }
  }

  // تحديث كلمة المرور
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('خطأ في تحديث كلمة المرور');
    }
  }

  // تحديث البريد الإلكتروني
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateEmail(newEmail);
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('خطأ في تحديث البريد الإلكتروني');
    }
  }

  // إعادة المصادقة
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('خطأ في إعادة المصادقة');
    }
  }

  // إنشاء مستخدم مدير افتراضي
  Future<void> createDefaultAdmin() async {
    try {
      // التحقق من وجود مدير افتراضي
      final adminQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: AppConfig.defaultAdminEmail)
          .where('isAdmin', isEqualTo: true)
          .get();

      if (adminQuery.docs.isEmpty) {
        // إنشاء حساب المدير
        final adminCredential = await createUserWithEmailAndPassword(
          AppConfig.defaultAdminEmail,
          AppConfig.defaultAdminPassword,
        );

        if (adminCredential.user != null) {
          // تحديث الملف الشخصي
          await adminCredential.user!.updateDisplayName(AppConfig.defaultAdminName);

          // إنشاء سجل المدير في Firestore
          final adminUser = UserModel(
            uid: adminCredential.user!.uid,
            name: AppConfig.defaultAdminName,
            email: AppConfig.defaultAdminEmail,
            phone: AppConfig.defaultAdminPhone,
            balance: 0.0,
            isAdmin: true,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );

          await _firestore
              .collection('users')
              .doc(adminCredential.user!.uid)
              .set(adminUser.toFirestore());

          print('✅ تم إنشاء حساب المدير الافتراضي');
        }
      } else {
        print('✅ ح��اب المدير موجود بالفعل');
      }
    } catch (e) {
      print('⚠️ خطأ في إنشاء حساب المدير: $e');
    }
  }

  // الحصول على بيانات المستخدم من Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('خطأ في جلب بيانات المستخدم');
    }
  }

  // إنشاء أو تحديث بيانات المستخدم في Firestore
  Future<void> createOrUpdateUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('خطأ في حفظ بيانات المستخدم');
    }
  }

  // تحديث آخر دخول
  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      // تجاهل الخطأ إذا لم يتم العثور على المستخدم
      print('تحذير: لم يتم تحديث آخر دخول للمستخدم $uid');
    }
  }

  // معالجة أخطاء Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لا يوجد مستخدم بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات المسموح، حاول لاحقاً';
      case 'operation-not-allowed':
        return 'هذه العملية غير مسموحة';
      case 'invalid-credential':
        return 'بيانات الدخول غير صحيحة';
      case 'requires-recent-login':
        return 'يتطلب تسجيل دخول حديث';
      case 'credential-already-in-use':
        return 'هذه البيانات مستخدمة بالفعل';
      case 'invalid-verification-code':
        return 'كود التحقق غير صحيح';
      case 'invalid-verification-id':
        return 'معرف التحقق غير صحيح';
      case 'network-request-failed':
        return 'خطأ في الاتصال بالإنترنت';
      case 'timeout':
        return 'انتهت مهلة الطلب';
      default:
        return 'حدث خطأ غير متوقع: ${e.message}';
    }
  }

  // التحقق من حالة الاتصال
  Future<bool> checkConnection() async {
    try {
      await _auth.fetchSignInMethodsForEmail('test@example.com');
      return true;
    } catch (e) {
      return false;
    }
  }

  // تسجيل الدخول التلقائي (للتطوير فقط)
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      throw Exception('خطأ في تسجيل الدخول التلقائي');
    }
  }

  // إعادة تحميل بيانات المستخدم
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      // تجاهل الخطأ
    }
  }

  // التحقق من تأكيد البريد الإلكتروني
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // التحقق من تسجيل الدخول
  bool get isSignedIn => _auth.currentUser != null;
}
