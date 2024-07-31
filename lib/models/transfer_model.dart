import 'package:cloud_firestore/cloud_firestore.dart';

class TransferModel {
  final String id;
  final String sourceAccountId;
  final String destinationAccountId;
  final double amount;
  final DateTime date;
  final String comment;
  final String type;

  TransferModel({
    required this.id,
    required this.sourceAccountId,
    required this.destinationAccountId,
    required this.amount,
    required this.date,
    required this.comment,
    required this.type,
  });

  factory TransferModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransferModel(
      id: doc.id,
      sourceAccountId: data['sourceAccountId'],
      destinationAccountId: data['destinationAccountId'] ?? '',
      amount: data['amount'],
      date: (data['date'] as Timestamp).toDate(),
      comment: data['comment'],
      type: data['type'] ?? 'transfer',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sourceAccountId': sourceAccountId,
      'destinationAccountId': destinationAccountId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'comment': comment,
      'type': type,
    };
  }
}
