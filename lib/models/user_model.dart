import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final double balance;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.balance = 0.0,
    this.isAdmin = false,
    required this.createdAt,
    this.lastLoginAt,
  });

  // Convert from Firebase Document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      photoUrl: data['photoUrl'],
      balance: (data['balance'] ?? 0.0).toDouble(),
      isAdmin: data['isAdmin'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null 
          ? (data['lastLoginAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert to Firebase Document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'balance': balance,
      'isAdmin': isAdmin,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null 
          ? Timestamp.fromDate(lastLoginAt!)
          : null,
    };
  }

  // Copy with modifications
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    double? balance,
    bool? isAdmin,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      balance: balance ?? this.balance,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
