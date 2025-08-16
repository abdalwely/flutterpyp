import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/firestore_provider.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  static const String routeName = '/transactions';
  
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TransactionType? selectedType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserAsyncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'سجل المعاملات',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontFamily: 'Cairo'),
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'الناجحة'),
            Tab(text: 'المعلقة'),
          ],
        ),
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text(
                'خطأ في بيانات المستخدم',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            );
          }

          return Column(
            children: [
              // Filter Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TransactionType?>(
                        value: selectedType,
                        decoration: InputDecoration(
                          labelText: 'نوع العملية',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<TransactionType?>(
                            value: null,
                            child: Text('جميع العمليات', style: TextStyle(fontFamily: 'Cairo')),
                          ),
                          ...TransactionType.values.map((type) {
                            return DropdownMenuItem<TransactionType?>(
                              value: type,
                              child: Text(
                                _getTypeNameAr(type),
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedType = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Transactions List
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTransactionsList(user.uid, null),
                    _buildTransactionsList(user.uid, TransactionStatus.success),
                    _buildTransactionsList(user.uid, TransactionStatus.pending),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'خطأ: $error',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList(String userId, TransactionStatus? status) {
    return FutureBuilder<List<TransactionModel>>(
      future: _getFilteredTransactions(userId, status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppConstants.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'خطأ في تحميل المعاملات',
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppConstants.textSecondary,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() {}),
                  child: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              ],
            ),
          );
        }

        final transactions = snapshot.data ?? [];

        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: AppConstants.textSecondary,
                ),
                const SizedBox(height: 16),
                const Text(
                  '��ا توجد معاملات',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppConstants.textSecondary,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status == null
                      ? 'لم تقم بأي معاملات بعد'
                      : status == TransactionStatus.success
                          ? 'لا توجد معاملات ناجحة'
                          : 'لا توجد معاملات معلقة',
                  style: const TextStyle(
                    color: AppConstants.textSecondary,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildTransactionCard(transaction);
            },
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    Color statusColor;
    IconData statusIcon;

    switch (transaction.status) {
      case TransactionStatus.success:
        statusColor = AppConstants.successColor;
        statusIcon = Icons.check_circle;
        break;
      case TransactionStatus.failed:
        statusColor = AppConstants.errorColor;
        statusIcon = Icons.error;
        break;
      case TransactionStatus.pending:
        statusColor = AppConstants.warningColor;
        statusIcon = Icons.pending;
        break;
      case TransactionStatus.cancelled:
        statusColor = AppConstants.textSecondary;
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    transaction.getTypeNameAr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        transaction.getStatusNameAr(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المبلغ: ${transaction.amount.toStringAsFixed(2)} ريال',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondary,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  DateFormat('yyyy/MM/dd HH:mm', 'ar').format(transaction.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppConstants.textSecondary,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            
            // Show additional details based on transaction type
            if (transaction.details.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildTransactionDetails(transaction),
            ],
            
            // Show card code for successful network recharge
            if (transaction.type == TransactionType.networkRecharge &&
                transaction.status == TransactionStatus.success &&
                transaction.details['cardCode'] != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppConstants.successColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'رقم الكرت:',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppConstants.textSecondary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          transaction.details['cardCode'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.successColor,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        // Copy to clipboard functionality would go here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم نسخ رقم الكرت'),
                            backgroundColor: AppConstants.successColor,
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.copy,
                        color: AppConstants.successColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionDetails(TransactionModel transaction) {
    switch (transaction.type) {
      case TransactionType.networkRecharge:
        return Text(
          'الشبكة: ${transaction.details['networkName'] ?? ''} - الفئة: ${transaction.details['value']} ريال',
          style: const TextStyle(
            fontSize: 12,
            color: AppConstants.textSecondary,
            fontFamily: 'Cairo',
          ),
        );
      case TransactionType.electricity:
        return Text(
          'رقم العداد: ${transaction.details['meterNumber'] ?? ''}',
          style: const TextStyle(
            fontSize: 12,
            color: AppConstants.textSecondary,
            fontFamily: 'Cairo',
          ),
        );
      case TransactionType.water:
        return Text(
          'رقم الحساب: ${transaction.details['accountNumber'] ?? ''}',
          style: const TextStyle(
            fontSize: 12,
            color: AppConstants.textSecondary,
            fontFamily: 'Cairo',
          ),
        );
      case TransactionType.school:
        return Text(
          'المدرسة: ${transaction.details['schoolName'] ?? ''} - الطالب: ${transaction.details['studentName'] ?? ''}',
          style: const TextStyle(
            fontSize: 12,
            color: AppConstants.textSecondary,
            fontFamily: 'Cairo',
          ),
        );
    }
  }

  Future<List<TransactionModel>> _getFilteredTransactions(
    String userId,
    TransactionStatus? status,
  ) async {
    final service = ref.read(firestoreServiceProvider);
    final transactions = await service.getUserTransactions(
      userId: userId,
      status: status,
    );

    if (selectedType != null) {
      return transactions.where((t) => t.type == selectedType).toList();
    }

    return transactions;
  }

  String _getTypeNameAr(TransactionType type) {
    switch (type) {
      case TransactionType.networkRecharge:
        return 'شحن كرت شبكة';
      case TransactionType.electricity:
        return 'شحن كهرباء';
      case TransactionType.water:
        return 'دفع فاتورة مياه';
      case TransactionType.school:
        return 'رسوم مدرسية';
    }
  }
}
