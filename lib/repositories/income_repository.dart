import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_harmony/models/income_model.dart';
import 'package:habit_harmony/models/reception_method_model.dart';
import 'package:habit_harmony/repositories/account_repository.dart';
import '../models/category_model.dart';

class IncomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AccountsRepository _accountsRepository = AccountsRepository();
  CollectionReference _getIncomeCollection() {
    String userId = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(userId).collection('incomes');
  }

  Future<Income> insertIncome(Income income) async {
    DocumentReference docRef =
        await _getIncomeCollection().add(income.toFirestore());
    //update balance
    await _accountsRepository.updateBalance(income.accountId, income.amount);
    return income.copyWith(id: docRef.id);
  }

  Future<void> deleteIncome(String id) async {
    //update balance
    Income income = await _getIncomeCollection()
        .doc(id)
        .get()
        .then((doc) => Income.fromFirestore(doc));
    await _getIncomeCollection().doc(id).delete();
    //update balance
    await _accountsRepository.updateBalance(income.accountId, -income.amount);
  }

  Future<List<Income>> getIncomes() async {
    QuerySnapshot snapshot = await _getIncomeCollection()
        .orderBy('date', descending: true) // Order by date in descending order
        .get();
    return snapshot.docs.map((doc) => Income.fromFirestore(doc)).toList();
  }

  Future<List<Category>> getCategories() async {
    QuerySnapshot snapshot = await _firestore
        .collection('categories')
        .where('type', isEqualTo: 'income')
        .get();
    return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
  }

  Future<List<ReceptionMethod>> getReceptionMethods() async {
    QuerySnapshot snapshot =
        await _firestore.collection('paymentMethods').get();
    return snapshot.docs
        .map((doc) => ReceptionMethod.fromFirestore(doc))
        .toList();
  }
}
