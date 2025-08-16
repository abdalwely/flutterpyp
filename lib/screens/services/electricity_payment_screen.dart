import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ElectricityPaymentScreen extends ConsumerStatefulWidget {
  static const String routeName = '/electricity-payment';

  const ElectricityPaymentScreen({super.key});

  @override
  ConsumerState<ElectricityPaymentScreen> createState() => _ElectricityPaymentScreenState();
}

class _ElectricityPaymentScreenState extends ConsumerState<ElectricityPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _meterNumberController = TextEditingController();
  double? selectedAmount;
  bool isLoading = false;
  Map<String, dynamic>? meterInfo;

  final List<double> quickAmounts = [100, 200, 500, 1000, 2000, 5000];

  @override
  void dispose() {
    _meterNumberController.dispose();
    super.dispose();
  }

  void _inquireMeter() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // محاكاة استعلام العداد
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        meterInfo = {
          'meterNumber': _meterNumberController.text,
          'customerName': 'أحمد محمد علي',
          'address': 'صنعاء - شارع الزبيري - حي السبعين',
          'lastReading': '12,450 كيلو واط ساعة',
          'lastPayment': '2024-01-15',
          'outstandingBalance': 0.0,
        };
      });
    } catch (e) {
      _showErrorSnackBar('خطأ في الاستعلام: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handlePayment() async {
    if (selectedAmount == null) {
      _showErrorSnackBar('يرجى اختيار مبلغ الشحن');
      return;
    }

    final currentUser = ref.read(authProvider).value;
    if (currentUser == null) {
      _showErrorSnackBar('خطأ في بيانات المستخدم');
      return;
    }

    setState(() => isLoading = true);

    try {
      // محاكاة عملية الدفع
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('خطأ في المعاملة: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'تم شحن الكهرباء بنجاح!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'تم شحن ${selectedAmount!.toStringAsFixed(0)} ريال لعداد رقم ${_meterNumberController.text}',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'موافق',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شحن الكهرباء'),
        backgroundColor: AppTheme.warningColor,
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
              // Meter Number Input
              const Text(
                'رقم العداد',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _meterNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'أدخل رقم العداد',
                        prefixIcon: Icon(Icons.electrical_services),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال رقم العداد';
                        }
                        if (value.length < 6) {
                          return 'رقم العداد غير صحيح';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isLoading ? null : _inquireMeter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.warningColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'استعلام',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),

              // Meter Information
              if (meterInfo != null) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.warningColor,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'معلومات العداد',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('اسم العميل', meterInfo!['customerName']),
                      _buildInfoRow('العنوان', meterInfo!['address']),
                      _buildInfoRow('آخر قراءة', meterInfo!['lastReading']),
                      _buildInfoRow('آخر دفعة', meterInfo!['lastPayment']),
                      if (meterInfo!['outstandingBalance'] > 0)
                        _buildInfoRow(
                          'المتبقي',
                          '${meterInfo!['outstandingBalance']} ريال',
                          color: AppTheme.errorColor,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Amount Selection
                const Text(
                  'اختر مبلغ الشحن',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2,
                  ),
                  itemCount: quickAmounts.length,
                  itemBuilder: (context, index) {
                    final amount = quickAmounts[index];
                    final isSelected = selectedAmount == amount;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedAmount = amount;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.warningColor.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.warningColor
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppTheme.warningColor
                                    : AppTheme.textPrimary,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            Text(
                              'ريال',
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? AppTheme.warningColor
                                    : AppTheme.textSecondary,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Summary
                if (selectedAmount != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ملخص العملية',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow('رقم العداد', _meterNumberController.text),
                        _buildSummaryRow('المبلغ', '${selectedAmount!.toStringAsFixed(0)} ريال'),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'المجموع:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            Text(
                              '${selectedAmount!.toStringAsFixed(0)} ريال',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.warningColor,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                // Payment Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (selectedAmount != null && !isLoading)
                        ? _handlePayment
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.warningColor,
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
                            'شحن الكهرباء',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color ?? AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontFamily: 'Cairo',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}
