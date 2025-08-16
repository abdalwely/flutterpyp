import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../core/config/app_config.dart';
import 'auth_service.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create default admin account
  Future<void> createDefaultAdmin() async {
    try {
      // Check if admin already exists
      final adminQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: AppConfig.defaultAdminEmail)
          .limit(1)
          .get();

      if (adminQuery.docs.isNotEmpty) {
        // Admin already exists, just make sure they have admin privileges
        final adminDoc = adminQuery.docs.first;
        if (!adminDoc.data()['isAdmin']) {
          await _firestore
              .collection('users')
              .doc(adminDoc.id)
              .update({'isAdmin': true});
        }
        return;
      }

      // Create admin user with Firebase Auth
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: AppConfig.defaultAdminEmail,
        password: AppConfig.defaultAdminPassword,
      );

      if (result.user != null) {
        // Create admin user document
        final adminUser = UserModel(
          uid: result.user!.uid,
          name: AppConfig.defaultAdminName,
          email: AppConfig.defaultAdminEmail,
          phone: AppConfig.defaultAdminPhone,
          isAdmin: true,
          balance: 0.0,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(adminUser.toFirestore());

        // Update display name
        await result.user!.updateDisplayName(AppConfig.defaultAdminName);

        // Create initial system data
        await _createInitialSystemData();
        
        print('✅ Default admin account created successfully');
        print('📧 Email: ${AppConfig.defaultAdminEmail}');
        print('🔑 Password: ${AppConfig.defaultAdminPassword}');
      }
    } catch (e) {
      print('❌ Error creating default admin: $e');
      // If admin creation fails due to existing account, try to sign in
      await _trySignInAdmin();
    }
  }

  // Try to sign in with admin credentials and verify admin status
  Future<void> _trySignInAdmin() async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: AppConfig.defaultAdminEmail,
        password: AppConfig.defaultAdminPassword,
      );

      if (result.user != null) {
        // Check if user has admin privileges
        final userDoc = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          if (!userData['isAdmin']) {
            // Grant admin privileges
            await _firestore
                .collection('users')
                .doc(result.user!.uid)
                .update({'isAdmin': true});
          }
        } else {
          // Create admin document if it doesn't exist
          final adminUser = UserModel(
            uid: result.user!.uid,
            name: AppConfig.defaultAdminName,
            email: AppConfig.defaultAdminEmail,
            phone: AppConfig.defaultAdminPhone,
            isAdmin: true,
            balance: 0.0,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );

          await _firestore
              .collection('users')
              .doc(result.user!.uid)
              .set(adminUser.toFirestore());
        }

        await _createInitialSystemData();
        print('✅ Admin account verified and updated');
      }
    } catch (e) {
      print('❌ Error verifying admin account: $e');
    }
  }

  // Create initial system data
  Future<void> _createInitialSystemData() async {
    try {
      // Create system settings
      await _createSystemSettings();
      
      // Create sample schools
      await _createSampleSchools();
      
      // Create sample cards (for demonstration)
      await _createSampleCards();
      
      // Create analytics collection
      await _createAnalyticsData();
      
      print('✅ Initial system data created');
    } catch (e) {
      print('❌ Error creating initial system data: $e');
    }
  }

  // Create system settings
  Future<void> _createSystemSettings() async {
    final settingsRef = _firestore.collection('settings').doc('app_config');
    final settingsSnapshot = await settingsRef.get();
    
    if (!settingsSnapshot.exists) {
      await settingsRef.set({
        'app_name': 'PayPoint',
        'app_version': '1.0.0',
        'maintenance_mode': false,
        'min_app_version': '1.0.0',
        'force_update': false,
        'enable_registrations': true,
        'enable_network_recharge': true,
        'enable_electricity_payment': true,
        'enable_water_payment': true,
        'enable_school_payment': true,
        'supported_networks': AppConfig.supportedNetworks,
        'payment_limits': {
          'min_recharge': 100,
          'max_recharge': 50000,
          'min_payment': 50,
          'max_payment': 100000,
          'daily_transaction_limit': 20,
          'daily_amount_limit': 200000,
        },
        'notification_settings': {
          'enable_push': true,
          'enable_sms': true,
          'enable_email': true,
        },
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
  }

  // Create sample schools
  Future<void> _createSampleSchools() async {
    final schoolsCollection = _firestore.collection('schools');
    final existingSchools = await schoolsCollection.limit(1).get();
    
    if (existingSchools.docs.isEmpty) {
      final schools = [
        {
          'name': 'مدرسة الأمل الأساسية',
          'code': 'SCH001',
          'address': 'شارع الستين - صنعاء',
          'phone': '+967-1-234567',
          'email': 'alamal@schools.ye',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'مدرسة النهضة الثانوية',
          'code': 'SCH002',
          'address': 'شارع الزراعة - صنعاء',
          'phone': '+967-1-234568',
          'email': 'alnahda@schools.ye',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'مدرسة المستقبل النموذجية',
          'code': 'SCH003',
          'address': 'شارع الحرية - عدن',
          'phone': '+967-2-234567',
          'email': 'almostaqbal@schools.ye',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      final batch = _firestore.batch();
      for (final school in schools) {
        final docRef = schoolsCollection.doc();
        batch.set(docRef, school);
      }
      await batch.commit();
    }
  }

  // Create sample cards for demonstration
  Future<void> _createSampleCards() async {
    final cardsCollection = _firestore.collection('cards');
    final existingCards = await cardsCollection.limit(1).get();
    
    if (existingCards.docs.isEmpty) {
      final networks = ['yemenmobile', 'mtn', 'sabafon', 'why'];
      final values = [500, 1000, 2000, 5000];
      
      final batch = _firestore.batch();
      int cardCounter = 1000;
      
      for (final network in networks) {
        for (final value in values) {
          // Create 5 cards for each network-value combination
          for (int i = 0; i < 5; i++) {
            final docRef = cardsCollection.doc();
            batch.set(docRef, {
              'network': network,
              'value': value,
              'code': '${network.toUpperCase()}${cardCounter + i}',
              'serial': 'SN${DateTime.now().millisecondsSinceEpoch}${i}',
              'status': 'available',
              'createdAt': FieldValue.serverTimestamp(),
              'soldAt': null,
              'soldToUserId': null,
            });
          }
          cardCounter += 10;
        }
      }
      
      await batch.commit();
    }
  }

  // Create analytics data structure
  Future<void> _createAnalyticsData() async {
    final analyticsRef = _firestore.collection('analytics').doc('overview');
    final analyticsSnapshot = await analyticsRef.get();
    
    if (!analyticsSnapshot.exists) {
      await analyticsRef.set({
        'total_users': 0,
        'total_transactions': 0,
        'total_revenue': 0.0,
        'total_cards_sold': 0,
        'active_users_today': 0,
        'transactions_today': 0,
        'revenue_today': 0.0,
        'last_updated': FieldValue.serverTimestamp(),
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }

  // Update analytics data
  Future<void> updateAnalytics({
    int? newUsers,
    int? newTransactions,
    double? newRevenue,
    int? newCardsSold,
  }) async {
    final analyticsRef = _firestore.collection('analytics').doc('overview');
    
    final updateData = <String, dynamic>{
      'last_updated': FieldValue.serverTimestamp(),
    };
    
    if (newUsers != null) {
      updateData['total_users'] = FieldValue.increment(newUsers);
    }
    
    if (newTransactions != null) {
      updateData['total_transactions'] = FieldValue.increment(newTransactions);
      updateData['transactions_today'] = FieldValue.increment(newTransactions);
    }
    
    if (newRevenue != null) {
      updateData['total_revenue'] = FieldValue.increment(newRevenue);
      updateData['revenue_today'] = FieldValue.increment(newRevenue);
    }
    
    if (newCardsSold != null) {
      updateData['total_cards_sold'] = FieldValue.increment(newCardsSold);
    }
    
    await analyticsRef.update(updateData);
  }

  // Get system statistics
  Future<Map<String, dynamic>> getSystemStatistics() async {
    try {
      final List<AggregateQuerySnapshot> snapshots = await Future.wait<AggregateQuerySnapshot>([
        _firestore.collection('users').count().get(),
        _firestore.collection('transactions').count().get(),
        _firestore.collection('cards').where('status', isEqualTo: 'sold').count().get(),
        _firestore.collection('schools').where('isActive', isEqualTo: true).count().get(),
      ]);

      final Map<String, dynamic> analyticsData = await _getAnalyticsData();

      return {
        'total_users': snapshots[0].count,
        'total_transactions': snapshots[1].count,
        'total_cards_sold': snapshots[2].count,
        'active_schools': snapshots[3].count,
        'analytics': analyticsData,
      };
    } catch (e) {
      print('Error getting system statistics: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> _getAnalyticsData() async {
    final analyticsDoc = await _firestore
        .collection('analytics')
        .doc('overview')
        .get();
    
    return analyticsDoc.exists ? analyticsDoc.data()! : {};
  }

  // Reset daily analytics (should be called daily via scheduled function)
  Future<void> resetDailyAnalytics() async {
    await _firestore.collection('analytics').doc('overview').update({
      'active_users_today': 0,
      'transactions_today': 0,
      'revenue_today': 0.0,
      'last_daily_reset': FieldValue.serverTimestamp(),
    });
  }

  // Backup system data
  Future<void> backupSystemData() async {
    final backupRef = _firestore.collection('backups').doc();
    final timestamp = DateTime.now();
    
    final statistics = await getSystemStatistics();
    
    await backupRef.set({
      'backup_date': Timestamp.fromDate(timestamp),
      'statistics': statistics,
      'created_by': _auth.currentUser?.uid,
      'backup_type': 'scheduled',
    });
  }

  // Check system health
  Future<Map<String, dynamic>> checkSystemHealth() async {
    try {
      final futures = await Future.wait([
        _checkFirestoreConnection(),
        _checkAuthConnection(),
        _checkAnalyticsData(),
      ]);

      return {
        'firestore_status': futures[0],
        'auth_status': futures[1],
        'analytics_status': futures[2],
        'overall_health': futures.every((status) => status == 'healthy') 
            ? 'healthy' 
            : 'degraded',
        'last_check': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'overall_health': 'unhealthy',
        'error': e.toString(),
        'last_check': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<String> _checkFirestoreConnection() async {
    try {
      await _firestore.collection('health_check').doc('test').set({
        'timestamp': FieldValue.serverTimestamp(),
      });
      return 'healthy';
    } catch (e) {
      return 'unhealthy';
    }
  }

  Future<String> _checkAuthConnection() async {
    try {
      await _auth.fetchSignInMethodsForEmail('test@example.com');
      return 'healthy';
    } catch (e) {
      return 'unhealthy';
    }
  }

  Future<String> _checkAnalyticsData() async {
    try {
      final analyticsDoc = await _firestore
          .collection('analytics')
          .doc('overview')
          .get();
      return analyticsDoc.exists ? 'healthy' : 'degraded';
    } catch (e) {
      return 'unhealthy';
    }
  }
}

// Admin Service Provider
final adminServiceProvider = Provider<AdminService>((ref) => AdminService());

// System Statistics Provider
final systemStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final adminService = ref.watch(adminServiceProvider);
  return await adminService.getSystemStatistics();
});

// System Health Provider
final systemHealthProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final adminService = ref.watch(adminServiceProvider);
  return await adminService.checkSystemHealth();
});
