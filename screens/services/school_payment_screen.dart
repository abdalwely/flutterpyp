import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../models/transaction_model.dart';
import '../../models/school_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/firestore_provider.dart';
import '../transactions/transaction_result_screen.dart';

class SchoolPaymentScreen extends ConsumerStatefulWidget {
  static const String routeName = '/school-payment';

  const SchoolPaymentScreen({super.key});

  @override
  ConsumerState<SchoolPaymentScreen> createState() => _SchoolPaymentScreenState();
}

class _SchoolPaymentScreenState extends ConsumerState<SchoolPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _amountController = TextEditingController();
  SchoolModel? selectedSchool;
  bool isLoading = false;

  final List<int> quickAmounts = [1000, 2000, 3000, 5000, 8000, 10000];

  @override
  void dispose() {
    _studentNameController.dispose();
    _studentIdController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _setQuickAmount(int amount) {
    _amountController.text = amount.toString();
  }

  void _handlePayment() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedSchool == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار المدرسة'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

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
        type: TransactionType.school,
        amount: double.parse(_amountController.text),
        details: {
          'schoolId': selectedSchool!.id,
          'schoolName': selectedSchool!.name,
          'studentName': _studentNameController.text,
          'studentId': _studentIdController.text,
          'serviceType': 'school_fees',
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
    final schoolsAsync = ref.watch(schoolsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'دفع الرسوم المدرسية',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppConstants.successColor,
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
                  color: AppConstants.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppConstants.successColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppConstants.successColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school,
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
                            'دفع الرسوم المدرسية',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          Text(
                            'ادفع رسوم المدرسة بسهولة وأمان',
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

              // School Selection
              const Text(
                'اختر المدرسة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                  fontFamily: 'Cairo',
                ),
              ),

              const SizedBox(height: 8),

              schoolsAsync.when(
                data: (schools) => DropdownButtonFormField<SchoolModel>(
                  value: selectedSchool,
                  decoration: InputDecoration(
                    hintText: '��ختر المدرسة',
                    prefixIcon: const Icon(Icons.school),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: schools.map((school) {
                    return DropdownMenuItem<SchoolModel>(
                      value: school,
                      child: Text(
                        school.name,
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                    );
                  }).toList(),
                  onChanged: (school) {
                    setState(() {
                      selectedSchool = school;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'يرجى اختيار المدرسة';
                    }
                    return null;
                  },
                ),
                loading: () => Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: const Center(
                    child: Text(
                      'خطأ في تحميل المدارس',
                      style: TextStyle(
                        color: Colors.red,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Student Name Field
              const Text(
                'اسم الطالب',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                  fontFamily: 'Cairo',
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _studentNameController,
                decoration: InputDecoration(
                  hintText: 'أدخل اسم الطالب',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم الطالب';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Student ID Field
              const Text(
                'رقم الطالب',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                  fontFamily: 'Cairo',
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _studentIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'أدخل رقم الطالب',
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم الطالب';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Amount Field
              const Text(
                'مبلغ الرسوم',
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
                    return 'يرجى إدخال المبلغ';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'يرجى إدخال مبلغ صحيح';
                  }
                  if (amount < 100) {
                    return 'الحد الأدنى للدفع 100 ريال';
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
                        color: AppConstants.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppConstants.successColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        '$amount ريال',
                        style: const TextStyle(
                          color: AppConstants.successColor,
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
                    backgroundColor: AppConstants.successColor,
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
                          'دفع الرسوم',
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
