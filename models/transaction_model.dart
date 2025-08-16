import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { networkRecharge, electricity, water, school }
enum TransactionStatus { pending, success, failed, cancelled }

class TransactionModel {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final Map<String, dynamic> details;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;
  final String? referenceNumber;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.details,
    this.status = TransactionStatus.pending,
    required this.createdAt,
    this.completedAt,
    this.failureReason,
    this.referenceNumber,
  });

  // Convert from Firebase Document
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => TransactionType.networkRecharge,
      ),
      amount: (data['amount'] ?? 0.0).toDouble(),
      details: Map<String, dynamic>.from(data['details'] ?? {}),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => TransactionStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      failureReason: data['failureReason'],
      referenceNumber: data['referenceNumber'],
    );
  }

  // Convert to Firebase Document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toString().split('.').last,
      'amount': amount,
      'details': details,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'failureReason': failureReason,
      'referenceNumber': referenceNumber,
    };
  }

  // Copy with modifications
  TransactionModel copyWith({
    String? userId,
    TransactionType? type,
    double? amount,
    Map<String, dynamic>? details,
    TransactionStatus? status,
    DateTime? completedAt,
    String? failureReason,
    String? referenceNumber,
  }) {
    return TransactionModel(
      id: id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      details: details ?? this.details,
      status: status ?? this.status,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
      referenceNumber: referenceNumber ?? this.referenceNumber,
    );
  }

  // Get Arabic transaction type name
  String getTypeNameAr() {
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

  // Get Arabic status name
  String getStatusNameAr() {
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
}
