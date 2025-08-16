import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../models/transaction_model.dart';
import '../../providers/firestore_provider.dart';

class TransactionsAdminScreen extends ConsumerStatefulWidget {
  static const String routeName = '/admin/transactions';
  
  const TransactionsAdminScreen({super.key});

  @override
  ConsumerState<TransactionsAdminScreen> createState() => _TransactionsAdminScreenState();
}

class _TransactionsAdminScreenState extends ConsumerState<TransactionsAdminScreen> {
  TransactionType? selectedType;
  TransactionStatus? selectedStatus;
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة المعاملات',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Type and Status filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TransactionType?>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'نوع العملية',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem<TransactionType?>(
                            value: null,
                            child: Text('جميع الأنواع', style: TextStyle(fontFamily: 'Cairo')),
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
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: DropdownButtonFormField<TransactionStatus?>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'الحالة',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem<TransactionStatus?>(
                            value: null,
                            child: Text('جميع الحالات', style: TextStyle(fontFamily: 'Cairo')),
                          ),
                          ...TransactionStatus.values.map((status) {
                            return DropdownMenuItem<TransactionStatus?>(
                              value: status,
                              child: Text(
                                _getStatusNameAr(status),
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Date filters
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'من تاريخ',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text(
                            startDate != null
                                ? DateFormat('yyyy/MM/dd', 'ar').format(startDate!)
                                : 'اختر التاريخ',
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'إلى تاريخ',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text(
                            endDate != null
                                ? DateFormat('yyyy/MM/dd', 'ar').format(endDate!)
                                : 'اختر التاريخ',
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Clear filters button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedType = null;
                        selectedStatus = null;
                        startDate = null;
                        endDate = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text(
                      'مسح الفلاتر',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Transactions List
          Expanded(
            child: FutureBuilder<List<TransactionModel>>(
              future: _getFilteredTransactions(),
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
                        const Text(
                          'خطأ في تحميل المعاملات',
                          style: TextStyle(
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
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: AppConstants.textSecondary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'لا توجد معاملات',
                          style: TextStyle(
                            fontSize: 18,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    Color statusColor = _getStatusColor(transaction.status);
    IconData statusIcon = _getStatusIcon(transaction.status);

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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.getTypeNameAr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${transaction.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppConstants.textSecondary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
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
            
            const SizedBox(height: 12),
            
            // Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المبلغ: ${transaction.amount.toStringAsFixed(2)} ريال',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
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
            
            const SizedBox(height: 8),
            
            Text(
              'المستخدم: ${transaction.userId}',
              style: const TextStyle(
                fontSize: 12,
                color: AppConstants.textSecondary,
                fontFamily: 'Cairo',
              ),
            ),
            
            // Additional details based on type
            if (transaction.details.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildTransactionDetails(transaction),
            ],
            
            // Action buttons for pending transactions
            if (transaction.status == TransactionStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _updateTransactionStatus(
                        transaction.id,
                        TransactionStatus.failed,
                      ),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text(
                        'رفض',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.errorColor,
                        side: const BorderSide(color: AppConstants.errorColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateTransactionStatus(
                        transaction.id,
                        TransactionStatus.success,
                      ),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text(
                        'قبول',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.successColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
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
          'رقم العداد: ${transaction.details['meterNumber'] ?? ''} - العميل: ${transaction.details['customerName'] ?? ''}',
          style: const TextStyle(
            fontSize: 12,
            color: AppConstants.textSecondary,
            fontFamily: 'Cairo',
          ),
        );
      case TransactionType.water:
        return Text(
          'رقم الحساب: ${transaction.details['accountNumber'] ?? ''} - العميل: ${transaction.details['customerName'] ?? ''}',
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

  Future<List<TransactionModel>> _getFilteredTransactions() async {
    final service = ref.read(firestoreServiceProvider);
    return await service.getAllTransactions(
      startDate: startDate,
      endDate: endDate,
    );
  }

  void _updateTransactionStatus(String transactionId, TransactionStatus status) async {
    try {
      final service = ref.read(firestoreServiceProvider);
      await service.updateTransactionStatus(
        transactionId: transactionId,
        status: status,
        referenceNumber: status == TransactionStatus.success
            ? DateTime.now().millisecondsSinceEpoch.toString()
            : null,
        failureReason: status == TransactionStatus.failed
            ? 'تم رفض المعاملة من قبل المسؤول'
            : null,
      );

      setState(() {}); // Refresh the list

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == TransactionStatus.success
                ? 'تم قبول المعاملة'
                : 'تم رفض المعاملة',
          ),
          backgroundColor: status == TransactionStatus.success
              ? AppConstants.successColor
              : AppConstants.errorColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${e.toString()}'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  void _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          startDate = pickedDate;
        } else {
          endDate = pickedDate;
        }
      });
    }
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

  String _getStatusNameAr(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return 'قيد المعالجة';
      case TransactionStatus.success:
        return 'مكتملة';
      case TransactionStatus.failed:
        return 'فاشلة';
      case TransactionStatus.cancelled:
        return 'ملغية';
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.success:
        return AppConstants.successColor;
      case TransactionStatus.failed:
        return AppConstants.errorColor;
      case TransactionStatus.pending:
        return AppConstants.warningColor;
      case TransactionStatus.cancelled:
        return AppConstants.textSecondary;
    }
  }

  IconData _getStatusIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.success:
        return Icons.check_circle;
      case TransactionStatus.failed:
        return Icons.error;
      case TransactionStatus.pending:
        return Icons.pending;
      case TransactionStatus.cancelled:
        return Icons.cancel;
    }
  }
}
