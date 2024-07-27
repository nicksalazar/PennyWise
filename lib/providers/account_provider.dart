import 'package:flutter/material.dart';
import 'package:habit_harmony/models/account_model.dart';
import 'package:habit_harmony/repositories/account_repository.dart';

class AccountProvider with ChangeNotifier {
  final AccountsRepository _repository = AccountsRepository();
  List<Account> _accounts = [];

  List<Account> get accounts => _accounts;

  Future<void> fetchAccounts() async {
    _accounts = await _repository.getAccounts();
    notifyListeners();
  }

  Future<void> addAccount(Account account) async {
    final newAccount = await _repository.insertAccount(account);
    _accounts.add(newAccount);
    notifyListeners();
  }

  Future<void> deleteAccount(String id) async {
    await _repository.deleteAccount(id);
    _accounts.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  Future<void> editAccount(Account account) async {
    await _repository.updateAccount(account);
    final index = _accounts.indexWhere((element) => element.id == account.id);
    _accounts[index] = account;
    notifyListeners();
  }
}
