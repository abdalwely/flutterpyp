import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolModel {
  final String id;
  final String name;
  final String nameEn;
  final String address;
  final String phone;
  final String? email;
  final String? logoUrl;
  final bool isActive;
  final List<SchoolFee> fees;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;

  SchoolModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.address,
    required this.phone,
    this.email,
    this.logoUrl,
    this.isActive = true,
    this.fees = const [],
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  // Convert from Firebase Document
  factory SchoolModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SchoolModel(
      id: doc.id,
      name: data['name'] ?? '',
      nameEn: data['nameEn'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'],
      logoUrl: data['logoUrl'],
      isActive: data['isActive'] ?? true,
      fees: (data['fees'] as List<dynamic>?)
          ?.map((fee) => SchoolFee.fromMap(fee))
          .toList() ?? [],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      createdBy: data['createdBy'],
    );
  }

  // Convert to Firebase Document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameEn': nameEn,
      'address': address,
      'phone': phone,
      'email': email,
      'logoUrl': logoUrl,
      'isActive': isActive,
      'fees': fees.map((fee) => fee.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null 
          ? Timestamp.fromDate(updatedAt!)
          : null,
      'createdBy': createdBy,
    };
  }

  // Copy with modifications
  SchoolModel copyWith({
    String? name,
    String? nameEn,
    String? address,
    String? phone,
    String? email,
    String? logoUrl,
    bool? isActive,
    List<SchoolFee>? fees,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return SchoolModel(
      id: id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      logoUrl: logoUrl ?? this.logoUrl,
      isActive: isActive ?? this.isActive,
      fees: fees ?? this.fees,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

class SchoolFee {
  final String id;
  final String name;
  final String nameEn;
  final double amount;
  final String description;
  final bool isActive;
  final DateTime? dueDate;

  SchoolFee({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.amount,
    required this.description,
    this.isActive = true,
    this.dueDate,
  });

  factory SchoolFee.fromMap(Map<String, dynamic> map) {
    return SchoolFee(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      nameEn: map['nameEn'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? true,
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'amount': amount,
      'description': description,
      'isActive': isActive,
      'dueDate': dueDate != null 
          ? Timestamp.fromDate(dueDate!)
          : null,
    };
  }

  SchoolFee copyWith({
    String? name,
    String? nameEn,
    double? amount,
    String? description,
    bool? isActive,
    DateTime? dueDate,
  }) {
    return SchoolFee(
      id: id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  String getFormattedAmount() {
    return '${amount.toStringAsFixed(0)} ريال';
  }
}
