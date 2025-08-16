import 'package:cloud_firestore/cloud_firestore.dart';

enum WiFiCardStatus { available, reserved, sold, disabled }

class WiFiCardModel {
  final String id;
  final String provider; // yemenmobile, mtn, sabafon, why
  final int value; // 500, 1000, 2000, 5000, 10000
  final String code; // الكود الفعلي للكرت
  final String? serial; // الرقم المسلسل (اختياري)
  final WiFiCardStatus status;
  final DateTime createdAt;
  final DateTime? soldAt;
  final String? soldToUserId;
  final String? uploadedBy; // المسؤول الذي رفع الكرت
  final String? batchId; // معرف الدفعة
  final Map<String, dynamic>? metadata; // بيانات إضافية

  WiFiCardModel({
    required this.id,
    required this.provider,
    required this.value,
    required this.code,
    this.serial,
    this.status = WiFiCardStatus.available,
    required this.createdAt,
    this.soldAt,
    this.soldToUserId,
    this.uploadedBy,
    this.batchId,
    this.metadata,
  });

  // Convert from Firebase Document
  factory WiFiCardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WiFiCardModel(
      id: doc.id,
      provider: data['provider'] ?? '',
      value: data['value'] ?? 0,
      code: data['code'] ?? '',
      serial: data['serial'],
      status: WiFiCardStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => WiFiCardStatus.available,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      soldAt: data['soldAt'] != null 
          ? (data['soldAt'] as Timestamp).toDate()
          : null,
      soldToUserId: data['soldToUserId'],
      uploadedBy: data['uploadedBy'],
      batchId: data['batchId'],
      metadata: data['metadata'] != null 
          ? Map<String, dynamic>.from(data['metadata'])
          : null,
    );
  }

  // Convert to Firebase Document
  Map<String, dynamic> toFirestore() {
    return {
      'provider': provider,
      'value': value,
      'code': code,
      'serial': serial,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'soldAt': soldAt != null ? Timestamp.fromDate(soldAt!) : null,
      'soldToUserId': soldToUserId,
      'uploadedBy': uploadedBy,
      'batchId': batchId,
      'metadata': metadata,
    };
  }

  // Copy with modifications
  WiFiCardModel copyWith({
    String? provider,
    int? value,
    String? code,
    String? serial,
    WiFiCardStatus? status,
    DateTime? soldAt,
    String? soldToUserId,
    String? uploadedBy,
    String? batchId,
    Map<String, dynamic>? metadata,
  }) {
    return WiFiCardModel(
      id: id,
      provider: provider ?? this.provider,
      value: value ?? this.value,
      code: code ?? this.code,
      serial: serial ?? this.serial,
      status: status ?? this.status,
      createdAt: createdAt,
      soldAt: soldAt ?? this.soldAt,
      soldToUserId: soldToUserId ?? this.soldToUserId,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      batchId: batchId ?? this.batchId,
      metadata: metadata ?? this.metadata,
    );
  }

  // Get provider name in Arabic
  String getProviderNameAr() {
    switch (provider) {
      case 'yemenmobile':
        return 'يمن موبايل';
      case 'mtn':
        return 'إم تي إن';
      case 'sabafon':
        return 'سبأفون';
      case 'why':
        return 'واي';
      default:
        return provider;
    }
  }

  // Get status name in Arabic
  String getStatusNameAr() {
    switch (status) {
      case WiFiCardStatus.available:
        return 'متاح';
      case WiFiCardStatus.reserved:
        return 'محجوز';
      case WiFiCardStatus.sold:
        return 'مباع';
      case WiFiCardStatus.disabled:
        return 'معطل';
    }
  }

  // Get formatted value
  String getFormattedValue() {
    return '$value ريال';
  }
}
