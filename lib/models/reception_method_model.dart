import 'package:cloud_firestore/cloud_firestore.dart';

class ReceptionMethod {
  final String id;
  final String name;
  final String color;

  ReceptionMethod({required this.id, required this.name, required this.color});

  factory ReceptionMethod.fromMap(Map<String, dynamic> map) {
    return ReceptionMethod(
      id: map['id'],
      name: map['name'],
      color: map['color'],
    );
  }

  factory ReceptionMethod.fromFirestore(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReceptionMethod(
      id: doc.id,
      name: data['name'],
      color: data['color'],
    );
  }
}
