import 'package:cloud_firestore/cloud_firestore.dart';

enum CardStatus { available, sold, reserved }

class CardModel {
  final String id;
  final String network;
  final int value;
  final String code;
  final String serial;
  final CardStatus status;
  final DateTime createdAt;
  final DateTime? soldAt;
  final String? soldToUserId;

  CardModel({
    required this.id,
    required this.network,
    required this.value,
    required this.code,
    required this.serial,
    this.status = CardStatus.available,
    required this.createdAt,
    this.soldAt,
    this.soldToUserId,
  });

  // Convert from Firebase Document
  factory CardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CardModel(
      id: doc.id,
      network: data['network'] ?? '',
      value: data['value'] ?? 0,
      code: data['code'] ?? '',
      serial: data['serial'] ?? '',
      status: CardStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => CardStatus.available,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      soldAt: data['soldAt'] != null 
          ? (data['soldAt'] as Timestamp).toDate()
          : null,
      soldToUserId: data['soldToUserId'],
    );
  }

  // Convert to Firebase Document
  Map<String, dynamic> toFirestore() {
    return {
      'network': network,
      'value': value,
      'code': code,
      'serial': serial,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'soldAt': soldAt != null ? Timestamp.fromDate(soldAt!) : null,
      'soldToUserId': soldToUserId,
    };
  }

  // Copy with modifications
  CardModel copyWith({
    String? network,
    int? value,
    String? code,
    String? serial,
    CardStatus? status,
    DateTime? soldAt,
    String? soldToUserId,
  }) {
    return CardModel(
      id: id,
      network: network ?? this.network,
      value: value ?? this.value,
      code: code ?? this.code,
      serial: serial ?? this.serial,
      status: status ?? this.status,
      createdAt: createdAt,
      soldAt: soldAt ?? this.soldAt,
      soldToUserId: soldToUserId ?? this.soldToUserId,
    );
  }
}
