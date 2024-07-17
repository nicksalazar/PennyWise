import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String description;
  final DateTime date;
  final String categoryId;
  final double amount;
  final String paymentMethodId;

  Expense({
    required this.id,
    required this.description,
    required this.date,
    required this.categoryId,
    required this.amount,
    required this.paymentMethodId,
  });

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      categoryId: data['categoryId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      paymentMethodId: data['paymentMethodId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'date': Timestamp.fromDate(date),
      'categoryId': categoryId,
      'amount': amount,
      'paymentMethodId': paymentMethodId,
    };
  }

  Future<Expense> copyWith({required String id}) {
    return Future.value(Expense(
      id: id,
      description: description,
      date: date,
      categoryId: categoryId,
      amount: amount,
      paymentMethodId: paymentMethodId,
    ));
  }
}
