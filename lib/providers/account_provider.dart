import 'package:flutter/material.dart';
import 'package:habit_harmony/models/account_model.dart';
import 'package:habit_harmony/models/transfer_model.dart';
import 'package:habit_harmony/repositories/account_repository.dart';
import 'package:habit_harmony/repositories/transfer_repository.dart';

class AccountProvider with ChangeNotifier {
  final AccountsRepository _repository = AccountsRepository();
  final TransferRepository _transferRepository = TransferRepository();
  List<Account> _accounts = [];

  List<Account> get accounts => _accounts;

  Future<void> fetchAccounts() async {
    _accounts = await _repository.getAccounts();
    notifyListeners();
  }

  Future<void> addAccount(Account account) async {
    try {
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
      //feth accounts
      await fetchAccounts();
      notifyListeners();
    } catch (e, stackTrace) {
      // Manejar la excepción aquí
      print('Error creating transfer: $e');
      print('Stack trace: $stackTrace');
      // Puedes lanzar la excepción nuevamente si necesitas que se maneje en otro lugar
      rethrow;
    }
  }

  Future<void> deleteAccount(String id) async {
    await _repository.deleteAccount(id);
    _accounts.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  Future<void> editAccount(Account account) async {
    Account acc = await _repository.updateAccount(account);
    await _transferRepository.adjustBalance(acc.id, acc.balance);
    //fetch accounts
    await fetchAccounts();
    notifyListeners();
  }
}
