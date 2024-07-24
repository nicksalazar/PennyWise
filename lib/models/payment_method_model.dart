import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentMethod {
  final String id;
  final String name;
  final String color;

  PaymentMethod({required this.id, required this.name, required this.color});

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'],
      name: map['name'],
      color: map['color'],
    );
  }

  factory PaymentMethod.fromFirestore(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentMethod(
      id: doc.id,
      name: data['name'],
      color: data['color'],
    );
  }
}