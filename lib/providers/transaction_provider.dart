import 'package:flutter/material.dart';
import 'package:pennywise/models/transaction_model.dart';
import 'package:pennywise/providers/account_provider.dart';
import 'package:pennywise/providers/loading_provider.dart';
import 'package:pennywise/repositories/transaction_repository.dart';
import '../models/category_model.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionRepository _repository;
  final AccountProvider _accountProvider;
  final LoadingProvider _loadingProvider;

  TransactionProvider(
    this._repository,
    this._accountProvider,
    this._loadingProvider,
  );

  List<TransactionModel> _transactions = [];
  List<Category> _categories = [];
  List<TransactionModel> get transactions => _transactions;
  List<Category> get categories => _categories;

  Future<void> fetchTransactions() async {
    _transactions = await _repository.getTransactions();
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      _loadingProvider.setLoading(true);
      final newTransaction = await _repository.insertTransaction(transaction);
      _transactions.insert(0, newTransaction);
      //update balance
      await _accountProvider.updateBalance(
        transaction.accountId,
        transaction.amount,
        transaction.transactionType,
      );
      notifyListeners();
    } catch (e) {
      print('Error adding transaction: $e');
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      _loadingProvider.setLoading(true);
      await _repository.updateTransaction(transaction);
      int index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating transaction: $e');
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  Future<void> deleteTransaction(TransactionModel transaction) async {
    try {
      _loadingProvider.setLoading(true);
      await _repository.deleteTransaction(transaction.id).then((value) async {
        await _accountProvider.updateBalance(
          transaction.accountId,
          transaction.amount,
          transaction.transactionType == 'income' ? 'expense' : 'income',
        );
        _transactions.removeWhere((t) => t.id == transaction.id);
      });
      //return delete transactino sof
      notifyListeners();
    } catch (e) {
      print('Error deleting transaction: $e');
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  Future<void> fetchCategories() async {
    try {
      _loadingProvider.setLoading(true);
      _categories = await _repository.getCategories();
      notifyListeners();
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  Future<Category> getCategoryById(String id) async {
    try {
      _loadingProvider.setLoading(true);
      return await _repository.getCategoryById(id);
    } catch (e) {
      print('Error fetching category: $e');
      throw e; // O maneja el error de otra manera si prefieres
    } finally {
      _loadingProvider.setLoading(false);
    }
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
