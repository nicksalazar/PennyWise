import 'package:flutter/material.dart';
import 'package:habit_harmony/models/account_model.dart';
import 'package:habit_harmony/models/income_model.dart';
import 'package:habit_harmony/repositories/account_repository.dart';
import 'package:habit_harmony/repositories/income_repository.dart';
import '../models/category_model.dart';

class IncomeProvider with ChangeNotifier {
  final IncomeRepository _repository = IncomeRepository();
  final AccountsRepository _accountsRepository = AccountsRepository();
  List<Income> _incomes = [];
  List<Category> _categories = [];
  List<Account> _accounts = [];

  List<Income> get incomes => _incomes;
  List<Category> get categories => _categories;
  List<Account> get accounts => _accounts;

  Future<void> fetchIncomes() async {
    _incomes = await _repository.getIncomes();
    notifyListeners();
  }

  Future<void> addIncome(Income income) async {
    final newIncome = await _repository.insertIncome(income);
    int insertIndex =
        _incomes.indexWhere((e) => e.date.isBefore(newIncome.date));

    if (insertIndex == -1) {
      _incomes.add(newIncome);
    } else {
      _incomes.insert(insertIndex, newIncome);
    }

    notifyListeners();
  }

  Future<void> deleteIncome(String id) async {
    await _repository.deleteIncome(id);
    _incomes.removeWhere((income) => income.id == id);
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    _categories = await _repository.getCategories();
    notifyListeners();
  }

  Future<void> fetchAccounts() async {
    _accounts = await _accountsRepository.getAccounts();
    notifyListeners();
  }
}
