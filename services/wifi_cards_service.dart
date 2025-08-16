import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wifi_card_model.dart';
import '../models/transaction_model.dart';
import '../models/sms_log_model.dart';
import '../core/constants/app_constants.dart';

class WiFiCardsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== الحصول على الكروت المتاحة =====
  
  Future<List<WiFiCardModel>> getAvailableCards({
    required String provider,
    required int value,
    int limit = 10,
  }) async {
    try {
      final QuerySnapshot query = await _firestore
          .collection('wifi_cards')
          .where('provider', isEqualTo: provider)
          .where('value', isEqualTo: value)
          .where('status', isEqualTo: 'available')
          .limit(limit)
          .get();

      return query.docs.map((doc) => WiFiCardModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('خطأ في جلب الكروت: ${e.toString()}');
    }
  }

  // ===== شراء كرت واي-فاي =====
  
  Future<Map<String, dynamic>> purchaseWiFiCard({
    required String provider,
    required int value,
    required String userId,
    required String userPhone,
  }) async {
    try {
      return await _firestore.runTransaction<Map<String, dynamic>>((transaction) async {
        // 1. البحث عن كرت متاح
        final cardQuery = await _firestore
            .collection('wifi_cards')
            .where('provider', isEqualTo: provider)
            .where('value', isEqualTo: value)
            .where('status', isEqualTo: 'available')
            .limit(1)
            .get();

        if (cardQuery.docs.isEmpty) {
          throw Exception('لا توجد كروت متاحة من هذه الفئة');
        }

        final cardDoc = cardQuery.docs.first;
        final card = WiFiCardModel.fromFirestore(cardDoc);

        // 2. تحديث حالة الكرت إلى "محجوز" مؤقتاً
        final updatedCard = card.copyWith(
          status: WiFiCardStatus.reserved,
          soldAt: DateTime.now(),
          soldToUserId: userId,
        );
        transaction.update(cardDoc.reference, updatedCard.toFirestore());

        // 3. إنشاء معاملة
        final transactionModel = TransactionModel(
          id: '',
          userId: userId,
          type: TransactionType.networkRecharge,
          amount: value.toDouble(),
          details: {
            'provider': provider,
            'cardId': card.id,
            'cardCode': card.code,
            'cardSerial': card.serial,
            'phoneNumber': userPhone,
          },
          status: TransactionStatus.pending,
          createdAt: DateTime.now(),
        );

        final transactionRef = _firestore.collection('transactions').doc();
        transaction.set(transactionRef, transactionModel.toFirestore());

        // 4. إنشاء سجل SMS
        final smsMessage = _buildSMSMessage(
          provider: provider,
          value: value,
          code: card.code,
          serial: card.serial,
        );

        final smsLog = SMSLogModel(
          id: '',
          transactionId: transactionRef.id,
          phoneNumber: userPhone,
          message: smsMessage,
          status: SMSStatus.pending,
          createdAt: DateTime.now(),
        );

        final smsRef = _firestore.collection('sms_logs').doc();
        transaction.set(smsRef, smsLog.toFirestore());

        return {
          'success': true,
          'transactionId': transactionRef.id,
          'cardCode': card.code,
          'cardSerial': card.serial,
          'smsId': smsRef.id,
          'message': 'تم شراء الكرت بنجاح. سيتم إرسال الكود عبر الرسائل النصية.',
        };
      });
    } catch (e) {
      throw Exception('خطأ في شراء الكرت: ${e.toString()}');
    }
  }

  // ===== محاكاة إرسال SMS =====
  
  Future<bool> sendSMS({
    required String transactionId,
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // محاكاة إرسال SMS (في التطبيق الحقيقي سيتم استخدام مزود SMS)
      await Future.delayed(const Duration(seconds: 2));

      // تحديث سجل SMS
      final smsQuery = await _firestore
          .collection('sms_logs')
          .where('transactionId', isEqualTo: transactionId)
          .limit(1)
          .get();

      if (smsQuery.docs.isNotEmpty) {
        await smsQuery.docs.first.reference.update({
          'status': 'sent',
          'sentAt': Timestamp.fromDate(DateTime.now()),
          'providerId': 'mock_provider',
          'providerResponse': 'Success: Message sent successfully',
        });
      }

      // تحديث حالة المعاملة
      await _firestore
          .collection('transactions')
          .doc(transactionId)
          .update({
        'status': 'success',
        'completedAt': Timestamp.fromDate(DateTime.now()),
        'referenceNumber': 'PP${DateTime.now().millisecondsSinceEpoch}',
      });

      // تحديث حالة الكرت إلى "مباع"
      final transactionDoc = await _firestore
          .collection('transactions')
          .doc(transactionId)
          .get();
      
      if (transactionDoc.exists) {
        final transactionData = transactionDoc.data() as Map<String, dynamic>;
        final cardId = transactionData['details']['cardId'];
        
        if (cardId != null) {
          await _firestore
              .collection('wifi_cards')
              .doc(cardId)
              .update({
            'status': 'sold',
            'soldAt': Timestamp.fromDate(DateTime.now()),
          });
        }
      }

      return true;
    } catch (e) {
      // في حالة فشل الإرسال
      await _handleSMSFailure(transactionId, e.toString());
      return false;
    }
  }

  // ===== معالجة فشل إرسال SMS =====
  
  Future<void> _handleSMSFailure(String transactionId, String error) async {
    try {
      // تحديث سجل SMS
      final smsQuery = await _firestore
          .collection('sms_logs')
          .where('transactionId', isEqualTo: transactionId)
          .limit(1)
          .get();

      if (smsQuery.docs.isNotEmpty) {
        await smsQuery.docs.first.reference.update({
          'status': 'failed',
          'errorMessage': error,
          'retryCount': FieldValue.increment(1),
        });
      }

      // تحديث حالة المعاملة
      await _firestore
          .collection('transactions')
          .doc(transactionId)
          .update({
        'status': 'failed',
        'failureReason': 'فشل في إرسال الرسالة النصية: $error',
        'completedAt': Timestamp.fromDate(DateTime.now()),
      });

      // إعادة الكرت إلى حالة "متاح"
      final transactionDoc = await _firestore
          .collection('transactions')
          .doc(transactionId)
          .get();
      
      if (transactionDoc.exists) {
        final transactionData = transactionDoc.data() as Map<String, dynamic>;
        final cardId = transactionData['details']['cardId'];
        
        if (cardId != null) {
          await _firestore
              .collection('wifi_cards')
              .doc(cardId)
              .update({
            'status': 'available',
            'soldAt': null,
            'soldToUserId': null,
          });
        }
      }
    } catch (e) {
      print('خطأ في معالجة فشل SMS: $e');
    }
  }

  // ===== بناء رسالة SMS =====
  
  String _buildSMSMessage({
    required String provider,
    required int value,
    required String code,
    String? serial,
  }) {
    final providerName = _getProviderNameAr(provider);
    final serialText = serial != null ? '\nالرقم المسلسل: $serial' : '';
    
    return '''🎉 تم شراء كرت $providerName بقيمة $value ريال بنجاح!

💳 كود الكرت: $code$serialText

📱 PayPoint - خدمات الدفع الإلكتروني
للاستفسار: 777000000''';
  }

  String _getProviderNameAr(String provider) {
    switch (provider) {
      case 'yemenmobile':
        return 'يمن موبايل';
      case 'mtn':
        return 'إم تي إن';
      case 'sabafon':
        return 'سبأفون';
      case 'why':
        return 'واي';
      default:
        return provider;
    }
  }

  // ===== إضافة كروت جديدة (للمسؤولين) =====
  
  Future<void> addWiFiCards(List<WiFiCardModel> cards) async {
    try {
      final batch = _firestore.batch();

      for (final card in cards) {
        final docRef = _firestore.collection('wifi_cards').doc();
        batch.set(docRef, card.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('خطأ في إضافة الكروت: ${e.toString()}');
    }
  }

  // ===== إحصائيات الكروت =====
  
  Future<Map<String, dynamic>> getCardsStatistics() async {
    try {
      final QuerySnapshot allCards = await _firestore
          .collection('wifi_cards')
          .get();

      final Map<String, dynamic> stats = {
        'total': allCards.size,
        'available': 0,
        'sold': 0,
        'reserved': 0,
        'byProvider': <String, Map<String, int>>{},
        'byValue': <int, Map<String, int>>{},
      };

      for (final doc in allCards.docs) {
        final card = WiFiCardModel.fromFirestore(doc);
        
        // إحصائيات الحالة
        switch (card.status) {
          case WiFiCardStatus.available:
            stats['available']++;
            break;
          case WiFiCardStatus.sold:
            stats['sold']++;
            break;
          case WiFiCardStatus.reserved:
            stats['reserved']++;
            break;
          case WiFiCardStatus.disabled:
            break;
        }

        // إحصائيات المزود
        if (!stats['byProvider'].containsKey(card.provider)) {
          stats['byProvider'][card.provider] = {
            'total': 0,
            'available': 0,
            'sold': 0,
          };
        }
        stats['byProvider'][card.provider]['total']++;
        if (card.status == WiFiCardStatus.available) {
          stats['byProvider'][card.provider]['available']++;
        } else if (card.status == WiFiCardStatus.sold) {
          stats['byProvider'][card.provider]['sold']++;
        }

        // إحصائيات القيمة
        if (!stats['byValue'].containsKey(card.value)) {
          stats['byValue'][card.value] = {
            'total': 0,
            'available': 0,
            'sold': 0,
          };
        }
        stats['byValue'][card.value]['total']++;
        if (card.status == WiFiCardStatus.available) {
          stats['byValue'][card.value]['available']++;
        } else if (card.status == WiFiCardStatus.sold) {
          stats['byValue'][card.value]['sold']++;
        }
      }

      return stats;
    } catch (e) {
      throw Exception('خطأ في جلب إحصائيات الكروت: ${e.toString()}');
    }
  }

  // ===== تشغيل عملية شراء كاملة =====
  
  Future<Map<String, dynamic>> processPurchase({
    required String provider,
    required int value,
    required String userId,
    required String userPhone,
  }) async {
    try {
      // 1. شراء الكرت
      final purchaseResult = await purchaseWiFiCard(
        provider: provider,
        value: value,
        userId: userId,
        userPhone: userPhone,
      );

      if (!purchaseResult['success']) {
        return purchaseResult;
      }

      // 2. إرسال SMS
      await Future.delayed(const Duration(seconds: 1)); // محاكاة التأخير
      
      final smsSuccess = await sendSMS(
        transactionId: purchaseResult['transactionId'],
        phoneNumber: userPhone,
        message: _buildSMSMessage(
          provider: provider,
          value: value,
          code: purchaseResult['cardCode'],
          serial: purchaseResult['cardSerial'],
        ),
      );

      return {
        'success': smsSuccess,
        'transactionId': purchaseResult['transactionId'],
        'cardCode': purchaseResult['cardCode'],
        'cardSerial': purchaseResult['cardSerial'],
        'message': smsSuccess 
            ? 'تم شراء الكرت وإرسال الكود بنجاح!'
            : 'تم شراء الكرت ولكن فشل إرسال الرسالة النصية',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
