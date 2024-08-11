import 'package:flutter/material.dart';
import 'package:habit_harmony/models/transaction_model.dart';
import 'package:habit_harmony/repositories/transaction_repository.dart';
import '../models/category_model.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();

  List<TransactionModel> _transactions = [];
  List<Category> _categories = [];
  List<TransactionModel> get transactions => _transactions;
  List<Category> get categories => _categories;

  Future<void> fetchTransactions() async {
    _transactions = await _repository.getTransactions();
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final newTransaction = await _repository.insertTransaction(transaction);
    _transactions.insert(0, newTransaction);
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _repository.updateTransaction(transaction);
    int index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      notifyListeners();
    }
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

  Category? getCategoryById(String id) {
    return _categories.firstWhere(
      (category) => category.id == id,
      orElse: () => Category(id: '', name: '', icon: '', color: '', type: ''),
    );
  }

  List<TransactionModel> getFilteredTransactions({
    required String transactionType,
    required String period,
  }) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    switch (period) {
      case 'Day':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        endDate = startDate.add(Duration(days: 6));
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'Year':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31);
        break;
      default:
        startDate = DateTime(1900); // A date far in the past
    }

    return _transactions
        .where((transaction) =>
            transaction.transactionType == transactionType &&
            transaction.date.isAfter(startDate.subtract(Duration(days: 1))) &&
            transaction.date.isBefore(endDate.add(Duration(days: 1))))
        .toList();
  }

  double getTotalAmount(List<TransactionModel> transactions) {
    return transactions.fold(0, (sum, transaction) => sum + transaction.amount);
  }
}
