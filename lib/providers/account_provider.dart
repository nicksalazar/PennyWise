import 'package:flutter/material.dart';
import 'package:habit_harmony/models/account_model.dart';
import 'package:habit_harmony/models/transfer_model.dart';
import 'package:habit_harmony/providers/loading_provider.dart';
import 'package:habit_harmony/repositories/account_repository.dart';
import 'package:habit_harmony/repositories/transfer_repository.dart';

class AccountProvider with ChangeNotifier {
  final AccountsRepository _repository;
  final TransferRepository _transferRepository;
  final LoadingProvider _loadingProvider;

  AccountProvider(
    this._repository,
    this._transferRepository,
    this._loadingProvider,
  );

  List<Account> _accounts = [];

  List<Account> get accounts => _accounts;

  Future<void> fetchAccounts() async {
    try {
      _loadingProvider.setLoading(true);
      _accounts = await _repository.getAccounts();
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error fetching accounts: $e');
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  Future<void> addAccount(Account account) async {
    try {
      _loadingProvider.setLoading(true);
      final newAccount = await _repository.insertAccount(account);
      //add new transfer for initial balance
      await _transferRepository.createTransferInitital(
        TransferModel(
          id: '',
          sourceAccountId: '',
          destinationAccountId: newAccount.id,
          amount: newAccount.balance,
          date: DateTime.now(),
          comment: 'Initial balance',
          type: 'initial',
        ),
      );
      //add to local variable the new account
      _accounts.add(newAccount);
      notifyListeners();
    } catch (e, stackTrace) {
      // Handle error
      print('Error adding account: $e');
      print(stackTrace);
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  Future<void> deleteAccount(String id) async {
    try {
      _loadingProvider.setLoading(true);
      await _repository.deleteAccount(id);
      _accounts.removeWhere((element) => element.id == id);
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error fetching accounts: $e');
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  Future<void> editAccount(Account account) async {
    try {
      _loadingProvider.setLoading(true);
      Account acc = await _repository.updateAccount(account);
      await _transferRepository.adjustBalance(acc.id, acc.balance);
      //update local variable
      _accounts[_accounts.indexWhere((element) => element.id == acc.id)] = acc;
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error fetching accounts: $e');
    } finally {
      _loadingProvider.setLoading(false);
    }
  }
}
