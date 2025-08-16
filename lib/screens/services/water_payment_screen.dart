import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/firestore_provider.dart';
import '../transactions/transaction_result_screen.dart';

class WaterPaymentScreen extends ConsumerStatefulWidget {
  static const String routeName = '/water-payment';
  
  const WaterPaymentScreen({super.key});

  @override
  ConsumerState<WaterPaymentScreen> createState() => _WaterPaymentScreenState();
}

class _WaterPaymentScreenState extends ConsumerState<WaterPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _customerNameController = TextEditingController();
  bool isLoading = false;

  final List<int> quickAmounts = [500, 1000, 2000, 3000, 5000, 10000];

  @override
  void dispose() {
    _accountNumberController.dispose();
    _amountController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  void _setQuickAmount(int amount) {
    _amountController.text = amount.toString();
  }

  void _handlePayment() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUserAsync = ref.read(authControllerProvider);
    final currentUser = currentUserAsync.value;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ في بيانات المستخدم'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final transaction = TransactionModel(
        id: '',
        userId: currentUser.uid,
        type: TransactionType.water,
        amount: double.parse(_amountController.text),
        details: {
          'accountNumber': _accountNumberController.text,
          'customerName': _customerNameController.text,
          'serviceType': 'water',
        },
        createdAt: DateTime.now(),
      );

      final transactionId = await ref
          .read(transactionControllerProvider.notifier)
          .createTransaction(transaction);

      if (transactionId != null && mounted) {
        Navigator.of(context).pushReplacementNamed(
          TransactionResultScreen.routeName,
          arguments: {
            'transactionId': transactionId,
            'isSuccess': true,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في المعاملة: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'دفع فاتورة المياه',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppConstants.secondaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppConstants.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppConstants.secondaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppConstants.secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'دفع فاتورة المياه',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          Text(
                            'سدد فاتورة المياه بسهولة وأمان',
                            style: TextStyle(
                              color: AppConstants.textSecondary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Customer Name Field
              const Text(
                'اسم العميل',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                  fontFamily: 'Cairo',
                ),
              ),
              
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _customerNameController,
                decoration: InputDecoration(
                  hintText: 'أدخل اسم العميل',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم العميل';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Account Number Field
              const Text(
                'رقم الحساب',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                  fontFamily: 'Cairo',
                ),
              ),
              
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'أدخل رقم الحساب',
                  prefixIcon: const Icon(Icons.water_drop),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم الحساب';
                  }
                  if (value.length < 6) {
                    return 'رقم الحساب يجب أن ��كون 6 أرقام على الأقل';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Amount Field
              const Text(
                'مبلغ الدفع',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                  fontFamily: 'Cairo',
                ),
              ),
              
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'أدخل المبلغ',
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: 'ريال',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال المب��غ';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'يرجى إدخال مبلغ صحيح';
                  }
                  if (amount < 50) {
                    return 'الحد الأدنى للدفع 50 ريال';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Quick Amount Buttons
              const Text(
                'مبالغ سريعة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textSecondary,
                  fontFamily: 'Cairo',
                ),
              ),
              
              const SizedBox(height: 8),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quickAmounts.map((amount) {
                  return InkWell(
                    onTap: () => _setQuickAmount(amount),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppConstants.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppConstants.secondaryColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        '$amount ريال',
                        style: const TextStyle(
                          color: AppConstants.secondaryColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              
              // Payment Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'دفع الفاتورة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Note
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'ستحصل على إيصال الدفع فوراً بعد إتمام العملية',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
