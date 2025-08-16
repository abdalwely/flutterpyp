import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

class ApiService {
  static const String baseUrl = 'https://api.paypoint.ye';
  static const String yemenMobileApiUrl = 'https://api.yemenmobile.ye';
  static const String mtnApiUrl = 'https://api.mtn.ye';
  static const String sabafoneApiUrl = 'https://api.sabafone.ye';
  static const String electricityApiUrl = 'https://api.electricity.gov.ye';
  static const String waterApiUrl = 'https://api.water.gov.ye';
  
  // Headers
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer ${AppConstants.apiKey}',
    'X-API-Version': '1.0',
  };

  // Network Recharge APIs
  static Future<ApiResponse<CardPurchaseResult>> purchaseNetworkCard({
    required String network,
    required int amount,
    required String phoneNumber,
  }) async {
    try {
      String apiUrl;
      Map<String, dynamic> requestBody;

      switch (network) {
        case 'yemenmobile':
          apiUrl = '$yemenMobileApiUrl/recharge';
          requestBody = {
            'phone_number': phoneNumber,
            'amount': amount,
            'service_type': 'prepaid_recharge',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          };
          break;
        case 'mtn':
          apiUrl = '$mtnApiUrl/topup';
          requestBody = {
            'mobile': phoneNumber,
            'value': amount,
            'type': 'credit',
            'reference': _generateReference(),
          };
          break;
        case 'sabafon':
          apiUrl = '$sabafoneApiUrl/charge';
          requestBody = {
            'subscriber_number': phoneNumber,
            'amount': amount,
            'product_type': 'balance',
            'transaction_id': _generateReference(),
          };
          break;
        case 'why':
          apiUrl = '$baseUrl/why/recharge';
          requestBody = {
            'phone': phoneNumber,
            'amount': amount,
            'type': 'balance',
            'ref_id': _generateReference(),
          };
          break;
        default:
          throw Exception('شبكة غير مدعومة');
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: _headers,
        body: json.encode(requestBody),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          CardPurchaseResult(
            success: true,
            cardCode: data['recharge_code'] ?? data['pin_code'] ?? data['voucher_code'],
            serialNumber: data['serial'] ?? data['transaction_id'],
            balance: data['balance']?.toDouble(),
            referenceNumber: data['reference'] ?? data['transaction_id'],
            message: data['message'] ?? 'تمت العملية بنجاح',
          ),
        );
      } else {
        return ApiResponse.error(
          data['message'] ?? 'فشلت عملية الشحن',
        );
      }
    } catch (e) {
      return ApiResponse.error('خطأ في الاتصال: ${e.toString()}');
    }
  }

  // Electricity Payment API
  static Future<ApiResponse<PaymentResult>> payElectricityBill({
    required String meterNumber,
    required double amount,
    required String customerName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$electricityApiUrl/payment'),
        headers: _headers,
        body: json.encode({
          'meter_number': meterNumber,
          'amount': amount,
          'customer_name': customerName,
          'payment_method': 'digital_wallet',
          'reference': _generateReference(),
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return ApiResponse.success(
          PaymentResult(
            success: true,
            receiptNumber: data['receipt_number'],
            chargeCode: data['charge_code'],
            units: data['units']?.toDouble(),
            referenceNumber: data['reference_number'],
            message: data['message'] ?? 'تم دفع الفاتورة بنجاح',
          ),
        );
      } else {
        return ApiResponse.error(
          data['error_message'] ?? 'فشل في دفع فاتورة الكهرباء',
        );
      }
    } catch (e) {
      return ApiResponse.error('خطأ في الاتصال: ${e.toString()}');
    }
  }

  // Water Payment API
  static Future<ApiResponse<PaymentResult>> payWaterBill({
    required String accountNumber,
    required double amount,
    required String customerName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$waterApiUrl/bill-payment'),
        headers: _headers,
        body: json.encode({
          'account_number': accountNumber,
          'amount': amount,
          'customer_name': customerName,
          'payment_type': 'mobile_payment',
          'transaction_ref': _generateReference(),
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['payment_status'] == 'completed') {
        return ApiResponse.success(
          PaymentResult(
            success: true,
            receiptNumber: data['receipt_id'],
            referenceNumber: data['payment_reference'],
            message: data['message'] ?? 'تم دفع فاتورة المياه بنجاح',
          ),
        );
      } else {
        return ApiResponse.error(
          data['error'] ?? 'فشل في دفع فاتورة المياه',
        );
      }
    } catch (e) {
      return ApiResponse.error('خطأ في الاتصال: ${e.toString()}');
    }
  }

  // SMS Notification API
  static Future<ApiResponse<bool>> sendSMSNotification({
    required String phoneNumber,
    required String message,
    String? templateId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$yemenMobileApiUrl/sms/send'),
        headers: _headers,
        body: json.encode({
          'to': phoneNumber,
          'message': message,
          'template_id': templateId,
          'sender_name': 'PayPoint',
          'priority': 'high',
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['sent'] == true) {
        return ApiResponse.success(true);
      } else {
        return ApiResponse.error(
          data['error'] ?? 'فشل في إرسال الرسالة',
        );
      }
    } catch (e) {
      return ApiResponse.error('خطأ في إرسال الرسالة: ${e.toString()}');
    }
  }

  // Balance Inquiry API
  static Future<ApiResponse<BalanceInfo>> checkBalance({
    required String network,
    required String phoneNumber,
  }) async {
    try {
      String apiUrl;
      Map<String, dynamic> requestBody;

      switch (network) {
        case 'yemenmobile':
          apiUrl = '$yemenMobileApiUrl/balance';
          requestBody = {'phone_number': phoneNumber};
          break;
        case 'mtn':
          apiUrl = '$mtnApiUrl/balance-inquiry';
          requestBody = {'mobile': phoneNumber};
          break;
        case 'sabafon':
          apiUrl = '$sabafoneApiUrl/balance';
          requestBody = {'subscriber_number': phoneNumber};
          break;
        default:
          throw Exception('استعلام الرصيد غير مدعوم لهذه الشبكة');
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: _headers,
        body: json.encode(requestBody),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(
          BalanceInfo(
            balance: data['balance']?.toDouble() ?? 0.0,
            currency: data['currency'] ?? 'YER',
            lastUpdate: DateTime.parse(data['last_update'] ?? DateTime.now().toIso8601String()),
            isActive: data['is_active'] ?? true,
          ),
        );
      } else {
        return ApiResponse.error(
          data['message'] ?? 'فشل في استعلام الرصيد',
        );
      }
    } catch (e) {
      return ApiResponse.error('خطأ في استعلام الرصيد: ${e.toString()}');
    }
  }

  // Utility methods
  static String _generateReference() {
    return 'PP${DateTime.now().millisecondsSinceEpoch}${(1000 + (9999 - 1000) * (DateTime.now().millisecond / 1000)).round()}';
  }

  // Test API Connection
  static Future<ApiResponse<bool>> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      );

      return response.statusCode == 200 
          ? ApiResponse.success(true)
          : ApiResponse.error('API غير متاح');
    } catch (e) {
      return ApiResponse.error('خطأ في الاتصال بالخدمة');
    }
  }

  rechargeNetwork({required String provider, required int value, required String userId, required String userPhone}) {}
}

// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse.success(this.data) 
      : success = true, error = null, statusCode = 200;
  
  ApiResponse.error(this.error, [this.statusCode]) 
      : success = false, data = null;
}

// Result Models
class CardPurchaseResult {
  final bool success;
  final String? cardCode;
  final String? serialNumber;
  final double? balance;
  final String? referenceNumber;
  final String message;

  CardPurchaseResult({
    required this.success,
    this.cardCode,
    this.serialNumber,
    this.balance,
    this.referenceNumber,
    required this.message,
  });
}

class PaymentResult {
  final bool success;
  final String? receiptNumber;
  final String? chargeCode;
  final double? units;
  final String? referenceNumber;
  final String message;

  PaymentResult({
    required this.success,
    this.receiptNumber,
    this.chargeCode,
    this.units,
    this.referenceNumber,
    required this.message,
  });
}

class BalanceInfo {
  final double balance;
  final String currency;
  final DateTime lastUpdate;
  final bool isActive;

  BalanceInfo({
    required this.balance,
    required this.currency,
    required this.lastUpdate,
    required this.isActive,
  });
}
