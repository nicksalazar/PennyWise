import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pennywise/models/transaction_model.dart';
import 'package:pennywise/models/category_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TransactionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance;

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
    QuerySnapshot snapshot = await _getTransactionsCollection()
        .get();
    return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
  }

  Future<Category> getCategoryById(String id) async {
    DocumentSnapshot doc = await _getTransactionsCollection()
        .doc(id)
        .get();
    return Category.fromFirestore(doc);
  }
}
