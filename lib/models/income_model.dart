import 'package:cloud_firestore/cloud_firestore.dart';

class Income {
  final String id;
  final String description;
  final DateTime date;
  final String categoryId;
  final double amount;
  final String receptionMethod;

  Income({
    required this.id,
    required this.description,
    required this.date,
    required this.categoryId,
    required this.amount,
    required this.receptionMethod,
  });

  factory Income.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Income(
      id: doc.id,
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      categoryId: data['categoryId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      receptionMethod: data['receptionMethod'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'date': Timestamp.fromDate(date),
      'categoryId': categoryId,
      'amount': amount,
      'paymentMethodId': receptionMethod,
    };
  }

  Future<Income> copyWith({required String id}) {
    return Future.value(Income(
      id: id,
      description: description,
      date: date,
      categoryId: categoryId,
      amount: amount,
      receptionMethod: receptionMethod,
    ));
  }
}
