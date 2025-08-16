import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_model.dart';
import '../models/transaction_model.dart';
import '../models/school_model.dart';
import '../services/firestore_service.dart';

// Firestore Service Provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

// Cards Provider
final cardsProvider = FutureProvider.family<List<CardModel>, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(firestoreServiceProvider);
  return await service.getAvailableCards(
    network: params['network'],
    value: params['value'],
    limit: params['limit'] ?? 10,
  );
});

// Card Statistics Provider
final cardStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(firestoreServiceProvider);
  return await service.getCardStatistics();
});

// User Transactions Provider
final userTransactionsProvider = FutureProvider.family<List<TransactionModel>, String>((ref, userId) async {
  final service = ref.watch(firestoreServiceProvider);
  return await service.getUserTransactions(userId: userId);
});

// Schools Provider
final schoolsProvider = FutureProvider<List<SchoolModel>>((ref) async {
  final service = ref.watch(firestoreServiceProvider);
  return await service.getSchools();
});

// Transaction Controller
class TransactionController extends StateNotifier<AsyncValue<TransactionModel?>> {
  final FirestoreService _firestoreService;

  TransactionController(this._firestoreService) : super(const AsyncValue.data(null));

  // Create Transaction
  Future<String?> createTransaction(TransactionModel transaction) async {
    state = const AsyncValue.loading();
    try {
      final transactionId = await _firestoreService.createTransaction(transaction);
      
      // If it's a network recharge, process the card purchase
      if (transaction.type == TransactionType.networkRecharge) {
        final details = transaction.details;
        final card = await _firestoreService.purchaseCard(
          network: details['network'],
          value: details['value'],
          userId: transaction.userId,
        );

        if (card != null) {
          // Update transaction with card details
          await _firestoreService.updateTransactionStatus(
            transactionId: transactionId,
            status: TransactionStatus.success,
            referenceNumber: card.code,
          );

          final updatedTransaction = transaction.copyWith(
            status: TransactionStatus.success,
            completedAt: DateTime.now(),
            referenceNumber: card.code,
            details: {
              ...details,
              'cardCode': card.code,
              'cardSerial': card.serial,
            },
          );

          state = AsyncValue.data(updatedTransaction);
        } else {
          await _firestoreService.updateTransactionStatus(
            transactionId: transactionId,
            status: TransactionStatus.failed,
            failureReason: 'لا توجد كروت متاحة',
          );
          
          state = AsyncValue.error('لا توجد كروت متاحة', StackTrace.current);
        }
      } else {
        // For other services, mark as success (in real app, integrate with payment gateway)
        await _firestoreService.updateTransactionStatus(
          transactionId: transactionId,
          status: TransactionStatus.success,
          referenceNumber: DateTime.now().millisecondsSinceEpoch.toString(),
        );

        final updatedTransaction = transaction.copyWith(
          status: TransactionStatus.success,
          completedAt: DateTime.now(),
          referenceNumber: DateTime.now().millisecondsSinceEpoch.toString(),
        );

        state = AsyncValue.data(updatedTransaction);
      }

      return transactionId;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  // Clear current transaction
  void clearTransaction() {
    state = const AsyncValue.data(null);
  }
}

// Transaction Controller Provider
final transactionControllerProvider = 
    StateNotifierProvider<TransactionController, AsyncValue<TransactionModel?>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return TransactionController(service);
});
