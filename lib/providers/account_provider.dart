import 'package:flutter/material.dart';
import 'package:pennywise/models/account_model.dart';
import 'package:pennywise/models/transaction_model.dart';
import 'package:pennywise/models/transfer_model.dart';
import 'package:pennywise/providers/loading_provider.dart';
import 'package:pennywise/providers/transfer_provider.dart';
import 'package:pennywise/repositories/account_repository.dart';

class AccountProvider with ChangeNotifier {
  final AccountsRepository _repository;
  final TransferProvider _transferProvider;
  final LoadingProvider _loadingProvider;

  AccountProvider(
    this._repository,
    this._transferProvider,
    this._loadingProvider,
  ) {
    _selectedAccountId = 'total';
  }

  List<Account> _accounts = [];

  List<Account> get accounts => [
        Account(
          icon: 'total',
          id: 'total',
          name: 'Total',
          balance: getTotalBalance(),
          color: '0xFF000000',
        ),
        ..._accounts
      ];

  String _selectedAccountId = 'total';
  bool _hideBalance = false;

  String get selectedAccountId => _selectedAccountId;
  bool get hideBalance => _hideBalance;

  Future<void> initializeData() async {
    await fetchAccounts();
    notifyListeners();
  }

  double getTotalBalance() {
    return _accounts
        .where((item) => item.id != "total")
        .fold(0, (sum, account) => sum + account.balance);
  }

  double get selectedAccountBalance {
    if (_selectedAccountId == 'total') {
      return getTotalBalance();
    }
    return _accounts
        .firstWhere((account) => account.id == _selectedAccountId)
        .balance;
  }

  //get name of selected account
  String get selectedAccountName {
    if (_selectedAccountId.isEmpty) {
      return 'All accounts';
    }
    return accounts
        .firstWhere((account) => account.id == _selectedAccountId)
        .name;
  }

  void setSelectedAccountId(String id) {
    _selectedAccountId = id;
    notifyListeners();
  }

  void setHideBalance(bool value) {
    _hideBalance = value;
    notifyListeners();
  }

  List<TransactionModel> getTransactionsForSelectedAccount(
      List<TransactionModel> allTransactions) {
    if (_selectedAccountId == 'total') {
      return allTransactions;
    }
    return allTransactions
        .where((transaction) => transaction.accountId == _selectedAccountId)
        .toList();
  }

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
      await _transferProvider.createTransferInitital(
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
      Account oldAccount =
          _accounts.firstWhere((element) => element.id == account.id);
      double oldBalance = oldAccount.balance;
      Account updatedAccount = await _repository.updateAccount(account);

      double balanceDifference = updatedAccount.balance - oldBalance;

      // Ajustar el balance
      await _transferProvider.adjustBalance(
          updatedAccount.id, balanceDifference);
      //update local variable
      _accounts[_accounts.indexWhere(
          (element) => element.id == updatedAccount.id)] = updatedAccount;
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error fetching accounts: $e');
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  //UPDATE BALANCE
  Future<void> updateBalance(
    String accountId,
    double amount,
    String transactionType,
  ) async {
    try {
      _loadingProvider.setLoading(true);
      await _repository.updateBalance(accountId, amount, transactionType);
      //update local variable
      _accounts[_accounts.indexWhere((element) => element.id == accountId)]
          .balance += transactionType == 'income' ? amount : -amount;
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error fetching accounts: $e');
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  //getAccountById
  Account getAccountById(String id) {
    return _accounts.firstWhere((element) => element.id == id);
  }

  //adjust balance
  Future<void> adjustBalance(String accountId, double amount) async {
    try {
      _loadingProvider.setLoading(true);
      await _transferProvider.adjustBalance(accountId, amount);
      //update local variable
      _accounts[_accounts.indexWhere((element) => element.id == accountId)]
          .balance += amount;
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error fetching accounts: $e');
    } finally {
      _loadingProvider.setLoading(false);
    }
  }
}
