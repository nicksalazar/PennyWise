import 'package:flutter/material.dart';
import 'package:nick_ai/models/expense_model.dart';
import 'package:nick_ai/models/metodo_pago_model.dart';
import 'package:nick_ai/repositories/expense_repository.dart';

import '../models/category_model.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseRepository _repository = ExpenseRepository();
  List<Expense> _expenses = [];
  List<Category> _categories = [];
  List<PaymentMethod> _paymentMethods = [];

  List<Expense> get expenses => _expenses;
  List<Category> get categories => _categories;
  List<PaymentMethod> get paymentMethods => _paymentMethods;

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

  Future<void> fetchPaymentMethods() async {
    _paymentMethods = await _repository.getPaymentMethods();
    notifyListeners();
  }
}
