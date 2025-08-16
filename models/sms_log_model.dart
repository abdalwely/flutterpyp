import 'package:cloud_firestore/cloud_firestore.dart';

enum SMSStatus { pending, sent, failed, delivered }

class SMSLogModel {
  final String id;
  final String transactionId;
  final String phoneNumber;
  final String message;
  final SMSStatus status;
  final DateTime createdAt;
  final DateTime? sentAt;
  final String? providerId; // معرف مزود الـ SMS
  final String? providerResponse;
  final String? errorMessage;
  final int retryCount;
  final Map<String, dynamic>? metadata;

  SMSLogModel({
    required this.id,
    required this.transactionId,
    required this.phoneNumber,
    required this.message,
    this.status = SMSStatus.pending,
    required this.createdAt,
    this.sentAt,
    this.providerId,
    this.providerResponse,
    this.errorMessage,
    this.retryCount = 0,
    this.metadata,
  });

  // Convert from Firebase Document
  factory SMSLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SMSLogModel(
      id: doc.id,
      transactionId: data['transactionId'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      message: data['message'] ?? '',
      status: SMSStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => SMSStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      sentAt: data['sentAt'] != null 
          ? (data['sentAt'] as Timestamp).toDate()
          : null,
      providerId: data['providerId'],
      providerResponse: data['providerResponse'],
      errorMessage: data['errorMessage'],
      retryCount: data['retryCount'] ?? 0,
      metadata: data['metadata'] != null 
          ? Map<String, dynamic>.from(data['metadata'])
          : null,
    );
  }

  // Convert to Firebase Document
  Map<String, dynamic> toFirestore() {
    return {
      'transactionId': transactionId,
      'phoneNumber': phoneNumber,
      'message': message,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'sentAt': sentAt != null ? Timestamp.fromDate(sentAt!) : null,
      'providerId': providerId,
      'providerResponse': providerResponse,
      'errorMessage': errorMessage,
      'retryCount': retryCount,
      'metadata': metadata,
    };
  }

  // Copy with modifications
  SMSLogModel copyWith({
    String? transactionId,
    String? phoneNumber,
    String? message,
    SMSStatus? status,
    DateTime? sentAt,
    String? providerId,
    String? providerResponse,
    String? errorMessage,
    int? retryCount,
    Map<String, dynamic>? metadata,
  }) {
    return SMSLogModel(
      id: id,
      transactionId: transactionId ?? this.transactionId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt,
      sentAt: sentAt ?? this.sentAt,
      providerId: providerId ?? this.providerId,
      providerResponse: providerResponse ?? this.providerResponse,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
      metadata: metadata ?? this.metadata,
    );
  }

  // Get status name in Arabic
  String getStatusNameAr() {
    switch (status) {
      case SMSStatus.pending:
        return 'قيد الإرسال';
      case SMSStatus.sent:
        return 'تم الإرسال';
      case SMSStatus.failed:
        return 'فشل الإرسال';
      case SMSStatus.delivered:
        return 'تم التسليم';
    }
  }
}
