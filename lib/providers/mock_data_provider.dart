import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/data/mock_data.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

/// Provider for mock user data when API is not available
final mockUserProvider = Provider<UserModel>((ref) => MockData.mockUser);

/// Provider for mock admin user data
final mockAdminUserProvider = Provider<UserModel>((ref) => MockData.mockAdminUser);

/// Provider for mock transactions
final mockTransactionsProvider = Provider<List<TransactionModel>>((ref) => MockData.mockTransactions);

/// Provider for recent mock transactions (last 3)
final mockRecentTransactionsProvider = Provider<List<TransactionModel>>((ref) => MockData.recentTransactions);

/// Provider for mock statistics
final mockStatisticsProvider = Provider<Map<String, dynamic>>((ref) => MockData.mockStatistics);

/// Provider for mock notifications
final mockNotificationsProvider = Provider<List<Map<String, dynamic>>>((ref) => MockData.mockNotifications);

/// Provider for mock network cards
final mockNetworkCardsProvider = Provider<List<Map<String, dynamic>>>((ref) => MockData.mockNetworkCards);

/// Provider for mock schools
final mockSchoolsProvider = Provider<List<Map<String, dynamic>>>((ref) => MockData.mockSchools);

/// Provider to check if app should use mock data (when API fails)
final useMockDataProvider = StateProvider<bool>((ref) => false);

/// Enhanced auth state provider that falls back to mock data
final enhancedCurrentUserProvider = Provider<UserModel?>((ref) {
  final useMockData = ref.watch(useMockDataProvider);
  
  if (useMockData) {
    return MockData.mockUser;
  }
  
  // Try to get real user data, fallback to mock on error
  try {
    // This would normally watch the real auth provider
    // For now, return mock data until API is connected
    return MockData.mockUser;
  } catch (e) {
    // Enable mock data mode on error
    Future.microtask(() => ref.read(useMockDataProvider.notifier).state = true);
    return MockData.mockUser;
  }
});

/// Enhanced transactions provider with mock fallback
final enhancedTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final useMockData = ref.watch(useMockDataProvider);
  
  if (useMockData) {
    return MockData.mockTransactions;
  }
  
  // Try to get real transaction data, fallback to mock on error
  try {
    // This would normally watch the real transactions provider
    // For now, return mock data until API is connected
    return MockData.mockTransactions;
  } catch (e) {
    // Enable mock data mode on error
    Future.microtask(() => ref.read(useMockDataProvider.notifier).state = true);
    return MockData.mockTransactions;
  }
});

/// Provider for balance with mock fallback
final enhancedBalanceProvider = Provider<double>((ref) {
  final user = ref.watch(enhancedCurrentUserProvider);
  return user?.balance ?? 1250.0;
});

/// Provider for user name with mock fallback  
final enhancedUserNameProvider = Provider<String>((ref) {
  final user = ref.watch(enhancedCurrentUserProvider);
  return user?.name ?? 'أحمد محمد علي';
});

/// Provider for admin status with mock fallback
final enhancedIsAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(enhancedCurrentUserProvider);
  return user?.isAdmin ?? false;
});
