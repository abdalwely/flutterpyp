import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/card_model.dart';
import '../models/transaction_model.dart';
import '../models/school_model.dart';
import '../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== CARDS MANAGEMENT =====
  
  // Get available cards by network and value
  Future<List<CardModel>> getAvailableCards({
    required String network,
    required int value,
    int limit = 10,
  }) async {
    try {
      final QuerySnapshot query = await _firestore
          .collection(AppConstants.cardsCollection)
          .where('network', isEqualTo: network)
          .where('value', isEqualTo: value)
          .where('status', isEqualTo: 'available')
          .limit(limit)
          .get();

      return query.docs.map((doc) => CardModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('خطأ في جلب الكروت: ${e.toString()}');
    }
  }

  // Purchase a card
  Future<CardModel?> purchaseCard({
    required String network,
    required int value,
    required String userId,
  }) async {
    try {
      // Use transaction to ensure consistency
      return await _firestore.runTransaction<CardModel?>((transaction) async {
        // Get an available card
        final cardQuery = await _firestore
            .collection(AppConstants.cardsCollection)
            .where('network', isEqualTo: network)
            .where('value', isEqualTo: value)
            .where('status', isEqualTo: 'available')
            .limit(1)
            .get();

        if (cardQuery.docs.isEmpty) {
          throw Exception('لا توجد كروت متاحة من هذه الفئة');
        }

        final cardDoc = cardQuery.docs.first;
        final card = CardModel.fromFirestore(cardDoc);

        // Update card status
        final updatedCard = card.copyWith(
          status: CardStatus.sold,
          soldAt: DateTime.now(),
          soldToUserId: userId,
        );

        transaction.update(cardDoc.reference, updatedCard.toFirestore());

        return updatedCard;
      });
    } catch (e) {
      throw Exception('خطأ في شراء الكرت: ${e.toString()}');
    }
  }

  // Add new cards (Admin only)
  Future<void> addCards(List<CardModel> cards) async {
    try {
      final batch = _firestore.batch();

      for (final card in cards) {
        final docRef = _firestore
            .collection(AppConstants.cardsCollection)
            .doc();
        batch.set(docRef, card.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('خطأ في إضافة الكروت: ${e.toString()}');
    }
  }

  // Get card statistics
  Future<Map<String, dynamic>> getCardStatistics() async {
    try {
      final QuerySnapshot allCards = await _firestore
          .collection(AppConstants.cardsCollection)
          .get();

      final Map<String, dynamic> stats = {
        'total': allCards.size,
        'available': 0,
        'sold': 0,
        'byNetwork': <String, int>{},
        'byValue': <int, int>{},
      };

      for (final doc in allCards.docs) {
        final card = CardModel.fromFirestore(doc);
        
        if (card.status == CardStatus.available) {
          stats['available']++;
        } else if (card.status == CardStatus.sold) {
          stats['sold']++;
        }

        stats['byNetwork'][card.network] = 
            (stats['byNetwork'][card.network] ?? 0) + 1;
        stats['byValue'][card.value] = 
            (stats['byValue'][card.value] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('خطأ في جلب إحصائيات الكروت: ${e.toString()}');
    }
  }

  // ===== TRANSACTIONS MANAGEMENT =====

  // Create a transaction
  Future<String> createTransaction(TransactionModel transaction) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.transactionsCollection)
          .add(transaction.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('خطأ في إنشاء المعاملة: ${e.toString()}');
    }
  }

  // Update transaction status
  Future<void> updateTransactionStatus({
    required String transactionId,
    required TransactionStatus status,
    String? failureReason,
    String? referenceNumber,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.toString().split('.').last,
        'completedAt': status == TransactionStatus.success || 
                      status == TransactionStatus.failed
            ? Timestamp.fromDate(DateTime.now())
            : null,
      };

      if (failureReason != null) {
        updateData['failureReason'] = failureReason;
      }
      if (referenceNumber != null) {
        updateData['referenceNumber'] = referenceNumber;
      }

      await _firestore
          .collection(AppConstants.transactionsCollection)
          .doc(transactionId)
          .update(updateData);
    } catch (e) {
      throw Exception('خطأ في تحديث حالة المعاملة: ${e.toString()}');
    }
  }

  // Get user transactions
  Future<List<TransactionModel>> getUserTransactions({
    required String userId,
    int limit = 50,
    TransactionType? type,
    TransactionStatus? status,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.transactionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (type != null) {
        query = query.where('type', isEqualTo: type.toString().split('.').last);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status.toString().split('.').last);
      }

      final QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('خطأ في جلب المعاملات: ${e.toString()}');
    }
  }

  // Get all transactions (Admin only)
  Future<List<TransactionModel>> getAllTransactions({
    int limit = 100,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.transactionsCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startDate != null) {
        query = query.where('createdAt', 
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('createdAt', 
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('خطأ في جلب جميع المعاملات: ${e.toString()}');
    }
  }

  // ===== SCHOOLS MANAGEMENT =====

  // Get all schools
  Future<List<SchoolModel>> getSchools() async {
    try {
      final QuerySnapshot query = await _firestore
          .collection(AppConstants.schoolsCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return query.docs.map((doc) => SchoolModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('خطأ في جلب المدارس: ${e.toString()}');
    }
  }

  // Add school (Admin only)
  Future<void> addSchool(SchoolModel school) async {
    try {
      await _firestore
          .collection(AppConstants.schoolsCollection)
          .add(school.toFirestore());
    } catch (e) {
      throw Exception('خطأ في إضافة المدرسة: ${e.toString()}');
    }
  }

  // Update school (Admin only)
  Future<void> updateSchool(SchoolModel school) async {
    try {
      await _firestore
          .collection(AppConstants.schoolsCollection)
          .doc(school.id)
          .update(school.toFirestore());
    } catch (e) {
      throw Exception('خطأ في تحديث المدرسة: ${e.toString()}');
    }
  }

  // Delete school (Admin only)
  Future<void> deleteSchool(String schoolId) async {
    try {
      await _firestore
          .collection(AppConstants.schoolsCollection)
          .doc(schoolId)
          .update({'isActive': false});
    } catch (e) {
      throw Exception('خطأ في حذف المدرسة: ${e.toString()}');
    }
  }
}
