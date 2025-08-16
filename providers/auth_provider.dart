import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Firebase Auth Stream Provider
final firebaseAuthProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Current User Provider
final authProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// User Model Provider - تحويل إلى FutureProvider للحصول على .future
final userModelProvider = FutureProvider<UserModel?>((ref) async {
  final auth = ref.watch(authProvider);

  return auth.when(
    data: (user) async {
      if (user == null) return null;

      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          return UserModel.fromFirestore(userDoc);
        } else {
          // إنشاء مستخدم جديد إذا لم يكن موجوداً
          final isAdminEmail = user.email == 'admin@paypoint.ye' ||
              user.email == 'admin@admin.com';

          final newUser = UserModel(
            uid: user.uid,
            name: user.displayName ?? (isAdminEmail ? 'مسؤول النظام' : 'مستخدم جديد'),
            email: user.email ?? '',
            phone: user.phoneNumber ?? '',
            photoUrl: user.photoURL,
            balance: isAdminEmail ? 50000.0 : 1250.0,
            isAdmin: isAdminEmail,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(newUser.toFirestore());

          return newUser;
        }
      } catch (e) {
        print('خطأ في جلب بيانات المستخدم: $e');
        return null;
      }
    },
    loading: () => null,
    error: (error, stackTrace) => null,
  );
});

// Auth Controller
class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  AuthController(this._authService) : super(const AsyncValue.loading()) {
    _init();
  }

  final AuthService _authService;

  void _init() async {
    try {
      // Set initial loading state
      state = const AsyncValue.loading();

      // Check if user is already signed in
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userModel = await _getUserModel(currentUser);
        state = AsyncValue.data(userModel);
      } else {
        state = const AsyncValue.data(null);
      }

      // Listen to auth state changes
      FirebaseAuth.instance.authStateChanges().listen((user) async {
        if (user != null) {
          final userModel = await _getUserModel(user);
          state = AsyncValue.data(userModel);
        } else {
          state = const AsyncValue.data(null);
        }
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<UserModel?> _getUserModel(User user) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        // إنشاء مستخدم جديد
        final isAdminEmail = user.email == 'admin@paypoint.ye' ||
            user.email == 'admin@admin.com';

        final newUser = UserModel(
          uid: user.uid,
          name: user.displayName ?? (isAdminEmail ? 'مسؤول النظام' : 'مستخدم جديد'),
          email: user.email ?? '',
          phone: user.phoneNumber ?? '',
          photoUrl: user.photoURL,
          balance: isAdminEmail ? 50000.0 : 1250.0,
          isAdmin: isAdminEmail,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(newUser.toFirestore());

        return newUser;
      }
    } catch (e) {
      print('خطأ في جلب بيانات الم����خدم: $e');
      return null;
    }
  }

  // تسجيل الدخول بالبريد الإلكتروني
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      await _authService.signInWithEmailAndPassword(email, password);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  // إنشاء حساب جديد
  Future<bool> signUpWithEmail(
      String email,
      String password,
      String name,
      String phone,
      ) async {
    try {
      state = const AsyncValue.loading();
      final userCredential = await _authService.createUserWithEmailAndPassword(
        email,
        password,
      );

      if (userCredential.user != null) {
        // تحديث الملف الشخصي
        await userCredential.user!.updateDisplayName(name);

        // إنشاء سجل المستخدم في Firestore
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          name: name,
          email: email,
          phone: phone,
          balance: 0.0,
          isAdmin: false,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userModel.toFirestore());
      }

      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  // إعادة تعيين كلمة المرور
  Future<bool> resetPassword(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      return false;
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // تحديث بيانات المستخدم
  Future<bool> updateUserProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      if (updates.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update(updates);

        // تحديث Firebase Auth profile
        if (name != null) {
          await currentUser.updateDisplayName(name);
        }
        if (photoUrl != null) {
          await currentUser.updatePhotoURL(photoUrl);
        }

        // إعادة تحميل بيانات المستخدم
        final updatedUser = await _getUserModel(currentUser);
        state = AsyncValue.data(updatedUser);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // إعادة تحميل بيانات المستخدم
  Future<void> refreshUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userModel = await _getUserModel(currentUser);
        state = AsyncValue.data(userModel);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // تحديث الرصيد
  Future<bool> updateBalance(double newBalance) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'balance': newBalance});

      // تحديث الحالة المحلية
      final currentState = state.value;
      if (currentState != null) {
        final updatedUser = currentState.copyWith(balance: newBalance);
        state = AsyncValue.data(updatedUser);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // إضافة إلى الرصيد
  Future<bool> addToBalance(double amount) async {
    try {
      final currentState = state.value;
      if (currentState == null) return false;

      final newBalance = currentState.balance + amount;
      return await updateBalance(newBalance);
    } catch (e) {
      return false;
    }
  }

  // خصم من الرصيد
  Future<bool> deductFromBalance(double amount) async {
    try {
      final currentState = state.value;
      if (currentState == null) return false;

      if (currentState.balance < amount) {
        print('⚠️ خطأ: الرصيد غير كافي. المطلوب: $amount، المتاح: ${currentState.balance}');
        return false;
      }

      final newBalance = currentState.balance - amount;
      return await updateBalance(newBalance);
    } catch (e) {
      print('❌ خطأ في خصم الرصيد: $e');
      return false;
    }
  }

  // التحقق من كفاية ال��صيد
  bool hasEnoughBalance(double amount) {
    final currentState = state.value;
    if (currentState == null) return false;
    return currentState.balance >= amount;
  }

  // الحصول على الرصيد الحالي
  double getCurrentBalance() {
    final currentState = state.value;
    return currentState?.balance ?? 0.0;
  }
}

// Auth Controller Provider
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
});

// Current User State Provider (for immediate access)
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authControllerProvider).value;
});

// Current User Async Provider (for .future access)
final currentUserAsyncProvider = Provider<AsyncValue<UserModel?>>((ref) {
  return ref.watch(authControllerProvider);
});

// Is Admin Provider
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAdmin ?? false;
});

// Is Authenticated Provider - إصلاح مشكلة .when على null
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

// User Balance Provider
final userBalanceProvider = Provider<double>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.balance ?? 0.0;
});
