import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_harmony/models/transaction_model.dart';
import 'package:habit_harmony/models/category_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference _getTransactionsCollection() {
    String userId = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  Future<List<TransactionModel>> getTransactions() async {
    QuerySnapshot snapshot = await _getTransactionsCollection()
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();
  }

  Future<TransactionModel> insertTransaction(
      TransactionModel transaction) async {
    DocumentReference docRef =
        await _getTransactionsCollection().add(transaction.toFirestore());
    DocumentSnapshot doc = await docRef.get();
    return TransactionModel.fromFirestore(doc);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _getTransactionsCollection()
        .doc(transaction.id)
        .update(transaction.toFirestore());
  }

  Future<void> deleteTransaction(String id) async {
    await _getTransactionsCollection().doc(id).delete();
  }

  Future<List<Category>> getCategories() async {
    String userId = _auth.currentUser!.uid;
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .get();
    return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
  }
}
