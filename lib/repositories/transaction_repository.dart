import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_harmony/models/transaction_model.dart';
import 'package:habit_harmony/models/category_model.dart';
import 'package:habit_harmony/models/payment_method_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<TransactionModel>> getTransactions() async {
    QuerySnapshot snapshot = await _firestore.collection('transactions').get();
    return snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
  }

  Future<TransactionModel> insertTransaction(TransactionModel transaction) async {
    DocumentReference docRef = await _firestore.collection('transactions').add(transaction.toFirestore());
    DocumentSnapshot doc = await docRef.get();
    return TransactionModel.fromFirestore(doc);
  }

  Future<void> deleteTransaction(String id) async {
    await _firestore.collection('transactions').doc(id).delete();
  }

  Future<List<Category>> getCategories() async {
    QuerySnapshot snapshot = await _firestore.collection('categories').get();
    return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
  }

  Future<List<PaymentMethod>> getPaymentMethods() async {
    QuerySnapshot snapshot = await _firestore.collection('paymentMethods').get();
    return snapshot.docs.map((doc) => PaymentMethod.fromFirestore(doc)).toList();
  }
}
