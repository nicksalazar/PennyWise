import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String description;
  final DateTime date;
  final DocumentReference categoryRef;
  final double amount;
  final DocumentReference paymentMethodRef;
  final String transactionType;
  
  TransactionModel({
    required this.id,
    required this.description,
    required this.date,
    required this.categoryRef,
    required this.amount,
    required this.paymentMethodRef,
    required this.transactionType,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      categoryRef: data['categoryRef'],
      amount: (data['amount'] ?? 0).toDouble(),
      paymentMethodRef: data['paymentMethodRef'],
      transactionType: data['transactionType'] ?? 'expense', // Default to 'expense' if not provided
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'date': Timestamp.fromDate(date),
      'categoryRef': categoryRef,
      'amount': amount,
      'paymentMethodRef': paymentMethodRef,
      'transactionType': transactionType,
    };
  }

  Future<TransactionModel> copyWith({required String id}) {
    return Future.value(TransactionModel(
      id: id,
      description: description,
      date: date,
      categoryRef: categoryRef,
      amount: amount,
      paymentMethodRef: paymentMethodRef,
      transactionType: transactionType,
    ));
  }
}
