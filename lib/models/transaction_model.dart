import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String description;
  final DateTime date;
  final String categoryId;
  final String accountId;
  final double amount;
  final String transactionType;

  TransactionModel({
    required this.id,
    required this.description,
    required this.date,
    required this.categoryId,
    required this.amount,
    required this.accountId,
    required this.transactionType,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      categoryId: data['categoryId'],
      amount: (data['amount'] ?? 0).toDouble(),
      accountId: data['accountId'],
      transactionType: data['transactionType'] ??
          'expense', // Default to 'expense' if not provided
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'date': Timestamp.fromDate(date),
      'categoryId': categoryId,
      'amount': amount,
      'accountId': accountId,
      'transactionType': transactionType,
    };
  }

  Future<TransactionModel> copyWith({required String id}) {
    return Future.value(TransactionModel(
      id: id,
      description: description,
      date: date,
      categoryId: categoryId,
      amount: amount,
      accountId: accountId,
      transactionType: transactionType,
    ));
  }
}
