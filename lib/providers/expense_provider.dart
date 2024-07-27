import 'package:flutter/material.dart';
import 'package:habit_harmony/models/account_model.dart';
import 'package:habit_harmony/models/expense_model.dart';
import 'package:habit_harmony/models/payment_method_model.dart';
import 'package:habit_harmony/repositories/account_repository.dart';
import 'package:habit_harmony/repositories/expense_repository.dart';


import '../models/category_model.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseRepository _repository = ExpenseRepository();
  final AccountsRepository _accountsRepository = AccountsRepository();
  List<Expense> _expenses = [];
  List<Category> _categories = [];
  List<Account> _accounts = [];

  List<Expense> get expenses => _expenses;
  List<Category> get categories => _categories;
  List<Account> get accounts => _accounts;

  Future<void> fetchExpenses() async {
    _expenses = await _repository.getExpenses();
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    final newExpense = await _repository.insertExpense(expense);
    int insertIndex = _expenses.indexWhere((e) => e.date.isBefore(newExpense.date));
  
    if (insertIndex == -1) {
      _expenses.add(newExpense);
    } else {
      _expenses.insert(insertIndex, newExpense);
    }
  
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    await _repository.deleteExpense(id);
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    _categories = await _repository.getCategories();
    notifyListeners();
  }

  Future<List<Account>> fetchAccounts() async {
    _accounts = await _accountsRepository.getAccounts();
    notifyListeners();
    return _accounts;
  }
}
