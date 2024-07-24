import 'package:flutter/material.dart';
import 'package:habit_harmony/models/transaction_model.dart';
import 'package:habit_harmony/models/payment_method_model.dart';
import 'package:habit_harmony/repositories/transaction_repository.dart';
import '../models/category_model.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();
  List<TransactionModel> _transactions = [];
  List<Category> _categories = [];
  List<PaymentMethod> _paymentMethods = [];

  List<TransactionModel> get transactions => _transactions;
  List<Category> get categories => _categories;
  List<PaymentMethod> get paymentMethods => _paymentMethods;

  Future<void> fetchTransactions() async {
    _transactions = await _repository.getTransactions();
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final newTransaction = await _repository.insertTransaction(transaction);
    int insertIndex = _transactions.indexWhere((t) => t.date.isBefore(newTransaction.date));

    if (insertIndex == -1) {
      _transactions.add(newTransaction);
    } else {
      _transactions.insert(insertIndex, newTransaction);
    }

    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _repository.deleteTransaction(id);
    _transactions.removeWhere((transaction) => transaction.id == id);
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    _categories = await _repository.getCategories();
    notifyListeners();
  }

  Future<void> fetchPaymentMethods() async {
    _paymentMethods = await _repository.getPaymentMethods();
    notifyListeners();
  }
}
