import '../constants/app_constants.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';

/// Mock data class for displaying UI without API connection
class MockData {
  // Mock User Data
  static UserModel get mockUser => UserModel(
        uid: 'mock-user-123',
        name: 'أحمد محمد علي',
        email: 'ahmed.mohamed@example.com',
        phone: '+967 777 123 456',
        balance: 1250.00,
        isAdmin: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        photoUrl: null,
      );

  // Mock Admin User
  static UserModel get mockAdminUser => UserModel(
        uid: 'mock-admin-123',
        name: 'سارة أحمد',
        email: 'admin@paypoint.ye',
        phone: '+967 711 123 456',
        balance: 5000.00,
        isAdmin: true,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        photoUrl: null,
      );

  // Mock Transactions
  static List<TransactionModel> get mockTransactions => [
        TransactionModel(
          id: 'txn-001',
          userId: 'mock-user-123',
          type: TransactionType.networkRecharge,
          amount: 1000.0,
          status: TransactionStatus.success,
          details: {
            'network': 'yemen_mobile',
            'networkName': 'يمن موبايل',
            'value': 1000,
            'cardCode': '123456789012345',
            'serialNumber': '987654321',
          },
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          completedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        TransactionModel(
          id: 'txn-002',
          userId: 'mock-user-123',
          type: TransactionType.electricity,
          amount: 500.0,
          status: TransactionStatus.success,
          details: {
            'meterNumber': '123456789',
            'customerName': 'أحمد محمد علي',
            'amount': 500,
          },
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        TransactionModel(
          id: 'txn-003',
          userId: 'mock-user-123',
          type: TransactionType.water,
          amount: 250.0,
          status: TransactionStatus.pending,
          details: {
            'accountNumber': '789012345',
            'customerName': 'أحمد محمد علي',
            'amount': 250,
          },
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        TransactionModel(
          id: 'txn-004',
          userId: 'mock-user-123',
          type: TransactionType.school,
          amount: 300.0,
          status: TransactionStatus.success,
          details: {
            'studentName': 'محمد أحمد',
            'studentId': 'STD-001',
            'school': 'مدرسة الأمل',
            'amount': 300,
          },
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          completedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        TransactionModel(
          id: 'txn-005',
          userId: 'mock-user-123',
          type: TransactionType.networkRecharge,
          amount: 500.0,
          status: TransactionStatus.failed,
          details: {
            'network': 'mtn',
            'networkName': 'MTN',
            'value': 500,
          },
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          failureReason: 'عذراً، لا توجد كروت متاحة',
        ),
      ];

  // Mock Network Cards
  static List<Map<String, dynamic>> get mockNetworkCards => [
        {
          'id': 'card-001',
          'network': 'yemen_mobile',
          'value': 1000,
          'code': '123456789012345',
          'serial': '987654321',
          'isUsed': false,
          'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'id': 'card-002',
          'network': 'mtn',
          'value': 500,
          'code': '567890123456789',
          'serial': '123456789',
          'isUsed': false,
          'createdAt': DateTime.now().subtract(const Duration(days: 2)),
        },
        {
          'id': 'card-003',
          'network': 'sabafon',
          'value': 250,
          'code': '890123456789012',
          'serial': '456789123',
          'isUsed': false,
          'createdAt': DateTime.now().subtract(const Duration(days: 3)),
        },
      ];

  // Mock Schools
  static List<Map<String, dynamic>> get mockSchools => [
        {
          'id': 'school-001',
          'name': 'مدرسة الأمل',
          'code': 'SCH-001',
          'location': 'صنعاء',
          'isActive': true,
        },
        {
          'id': 'school-002',
          'name': 'مدرسة المستقبل',
          'code': 'SCH-002',
          'location': 'عدن',
          'isActive': true,
        },
        {
          'id': 'school-003',
          'name': 'مدرسة الن��ر',
          'code': 'SCH-003',
          'location': 'تعز',
          'isActive': true,
        },
      ];

  // Mock Statistics for Admin
  static Map<String, dynamic> get mockStatistics => {
        'totalUsers': 1250,
        'totalTransactions': 8945,
        'totalRevenue': 125000.0,
        'successfulTransactions': 8234,
        'pendingTransactions': 456,
        'failedTransactions': 255,
        'dailyTransactions': [
          {'date': '2024-01-01', 'count': 45},
          {'date': '2024-01-02', 'count': 67},
          {'date': '2024-01-03', 'count': 89},
          {'date': '2024-01-04', 'count': 34},
          {'date': '2024-01-05', 'count': 56},
          {'date': '2024-01-06', 'count': 78},
          {'date': '2024-01-07', 'count': 123},
        ],
        'networkDistribution': {
          'yemen_mobile': 45,
          'mtn': 30,
          'sabafon': 15,
          'y': 10,
        },
      };

  // Mock Notifications
  static List<Map<String, dynamic>> get mockNotifications => [
        {
          'id': 'notif-001',
          'title': 'تم إضافة كروت جديدة',
          'message': 'تم إضافة كروت يمن موبايل جديدة بقيمة 1000 ريال',
          'type': 'info',
          'isRead': false,
          'createdAt': DateTime.now().subtract(const Duration(hours: 1)),
        },
        {
          'id': 'notif-002',
          'title': 'تم إكمال المعاملة',
          'message': 'تم شحن الكهرباء بنجاح للعداد رقم 123456789',
          'type': 'success',
          'isRead': false,
          'createdAt': DateTime.now().subtract(const Duration(hours: 3)),
        },
        {
          'id': 'notif-003',
          'title': 'فشل في المعاملة',
          'message': 'فشل في شحن كرت MTN، يرجى المحاولة مرة أخرى',
          'type': 'error',
          'isRead': true,
          'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        },
      ];

  // Helper method to simulate API delay
  static Future<T> simulateApiCall<T>(T data, {Duration? delay}) async {
    await Future.delayed(delay ?? const Duration(milliseconds: 800));
    return data;
  }

  // Helper method to simulate API error
  static Future<T> simulateApiError<T>(String errorMessage, {Duration? delay}) async {
    await Future.delayed(delay ?? const Duration(milliseconds: 500));
    throw Exception(errorMessage);
  }

  // Get recent transactions (last 3)
  static List<TransactionModel> get recentTransactions {
    final transactions = mockTransactions;
    transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return transactions.take(3).toList();
  }

  // Get transactions by status
  static List<TransactionModel> getTransactionsByStatus(TransactionStatus status) {
    return mockTransactions.where((tx) => tx.status == status).toList();
  }

  // Get transactions by type
  static List<TransactionModel> getTransactionsByType(TransactionType type) {
    return mockTransactions.where((tx) => tx.type == type).toList();
  }

  // Mock balance update
  static double calculateNewBalance(double currentBalance, double amount, bool isDeduction) {
    if (isDeduction) {
      return currentBalance - amount;
    } else {
      return currentBalance + amount;
    }
  }
}
