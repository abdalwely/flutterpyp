import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/config/app_config.dart';
import '../../services/wifi_cards_service.dart';
import '../../providers/auth_provider.dart';
import '../transactions/transaction_result_screen.dart';

class NetworkRechargeScreen extends ConsumerStatefulWidget {
  static const String routeName = '/network-recharge';
  
  const NetworkRechargeScreen({super.key});

  @override
  ConsumerState<NetworkRechargeScreen> createState() => _NetworkRechargeScreenState();
}

class _NetworkRechargeScreenState extends ConsumerState<NetworkRechargeScreen> {
  String? selectedProvider;
  int? selectedValue;
  bool isLoading = false;
  final WiFiCardsService _wifiCardsService = WiFiCardsService();

  void _handlePurchase() async {
    if (selectedProvider == null || selectedValue == null) {
      _showErrorSnackBar('يرجى اختيار المزود وفئة الكرت');
      return;
    }

    final firebaseUser = ref.read(authProvider).value;
    print('🔍 [NetworkRecharge] Firebase user: ${firebaseUser?.uid}');
    if (firebaseUser == null) {
      _showErrorSnackBar('خطأ في بيانات المستخدم');
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    print('🔍 [NetworkRecharge] Current user: ${currentUser?.uid}, Phone: ${currentUser?.phone}');
    if (currentUser == null) {
      _showErrorSnackBar('خطأ في تحميل بيانات المستخدم');
      return;
    }

    setState(() => isLoading = true);

    try {
      // تنفيذ عملية الشراء
      final result = await _wifiCardsService.processPurchase(
        provider: selectedProvider!,
        value: selectedValue!,
        userId: currentUser.uid,
        userPhone: currentUser.phone ?? '+967777000000',
      );

      if (mounted) {
        if (result['success']) {
          // الانتقال إلى صفحة النتيجة
          Navigator.of(context).pushReplacementNamed(
            TransactionResultScreen.routeName,
            arguments: {
              'transactionId': result['transactionId'],
              'isSuccess': true,
              'cardCode': result['cardCode'],
              'cardSerial': result['cardSerial'],
              'provider': selectedProvider,
              'value': selectedValue,
              'message': result['message'],
            },
          );
        } else {
          _showErrorSnackBar(result['message'] ?? 'حدث خطأ في العملية');
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شحن كروت الشبكة'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.cyan,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider Selection
            const Text(
              'اختر المزود',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            
            const SizedBox(height: 16),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: AppConfig.supportedNetworks.length,
              itemBuilder: (context, index) {
                final network = AppConfig.supportedNetworks[index];
                final isSelected = selectedProvider == network['id'];
                
                return InkWell(
                  onTap: network['isActive'] ? () {
                    setState(() {
                      selectedProvider = network['id'];
                      selectedValue = null; // Reset value when changing provider
                    });
                  } : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Color(network['color']).withOpacity(0.1) 
                          : Colors.cyan,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? Color(network['color']) 
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Color(network['color']).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(network['color']),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.sim_card,
                            color: Colors.cyan,
                            size: 28,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Text(
                          network['name'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected 
                                ? Color(network['color']) 
                                : AppTheme.textPrimary,
                            fontFamily: 'Cairo',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        if (!network['isActive'])
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, 
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'غير متاح',
                              style: TextStyle(
                                color: Colors.cyan,
                                fontSize: 10,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Value Selection
            if (selectedProvider != null) ...[
              const Text(
                'اختر فئة الكرت',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  fontFamily: 'Cairo',
                ),
              ),
              
              const SizedBox(height: 16),
              
              Builder(
                builder: (context) {
                  final network = AppConfig.supportedNetworks
                      .firstWhere((n) => n['id'] == selectedProvider);
                  final supportedAmounts = List<int>.from(network['supportedAmounts']);
                  
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: supportedAmounts.length,
                    itemBuilder: (context, index) {
                      final value = supportedAmounts[index];
                      final isSelected = selectedValue == value;
                      
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedValue = value;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppTheme.primaryColor.withOpacity(0.1) 
                                : Colors.cyan,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected 
                                  ? AppTheme.primaryColor 
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$value',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected 
                                      ? AppTheme.primaryColor 
                                      : AppTheme.textPrimary,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              Text(
                                'ريال',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected 
                                      ? AppTheme.primaryColor 
                                      : AppTheme.textSecondary,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Summary Card
            if (selectedProvider != null && selectedValue != null) ...[
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
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'المزود:',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          AppConfig.supportedNetworks
                              .firstWhere((n) => n['id'] == selectedProvider)['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'الفئة:',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          '$selectedValue ريال',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                    
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
                          '$selectedValue ريال',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Warning Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.warningColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.warningColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'سيتم إرسال كود الكرت إلى رقم هاتفك المسجل عبر الرسائل النصية فور تأكيد العملية.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Purchase Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (selectedProvider != null && 
                           selectedValue != null && 
                           !isLoading)
                    ? _handlePurchase
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.cyan,
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                        ),
                      )
                    : const Text(
                        'شراء الكرت',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
