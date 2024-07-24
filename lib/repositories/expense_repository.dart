import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_harmony/models/category_model.dart';
import 'package:habit_harmony/models/expense_model.dart';
import 'package:habit_harmony/models/payment_method_model.dart';

class ExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference _getExpensesCollection() {
    String userId = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(userId).collection('expenses');
  }

  Future<Expense> insertExpense(Expense expense) async {
    DocumentReference docRef =
        await _getExpensesCollection().add(expense.toFirestore());
    return expense.copyWith(id: docRef.id);
  }

  Future<void> deleteExpense(String id) async {
    await _getExpensesCollection().doc(id).delete();
  }

  Future<List<Expense>> getExpenses() async {
      QuerySnapshot snapshot = await _getExpensesCollection()
          .orderBy('date', descending: true) // Order by date in descending order
          .get();
      return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
    }

  Future<List<Category>> getCategories() async {
    QuerySnapshot snapshot = await _firestore.collection('categories')
    .where('type', isEqualTo: 'expense') 
    .get();
    return snapshot.docs
        .map((doc) => Category.fromFirestore(doc))
        .toList();
  }

  Future<List<PaymentMethod>> getPaymentMethods() async {
    QuerySnapshot snapshot =
        await _firestore.collection('paymentMethods').get();
    return snapshot.docs
        .map((doc) => PaymentMethod.fromFirestore(doc))
        .toList();
  }
}
