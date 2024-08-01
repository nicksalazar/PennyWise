import 'package:flutter/material.dart';
import 'package:habit_harmony/models/transfer_model.dart';
import 'package:habit_harmony/providers/account_provider.dart';
import 'package:habit_harmony/repositories/transfer_repository.dart';

class TransferProvider with ChangeNotifier {
  final TransferRepository _transferRepository = TransferRepository();
  final AccountProvider _accountProvider;
  List<TransferModel> _transfers = [];
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  List<TransferModel> get transfers => _transfers;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  TransferProvider(this._accountProvider) {
    // Inicializar con las transferencias del día actual
    getTodayTransfers();
  }

  Future<void> addTransfer(TransferModel transfer) async {
    try {
      await _transferRepository.createTransfer(transfer);
      await _accountProvider.fetchAccounts();
      notifyListeners();
    } catch (e) {
      print('Error adding transfer: $e');
    }
  }

  //adjust balance
  Future<void> adjustBalance(String accountId, double amount) async {
    try {
      await _transferRepository.adjustBalance(accountId, amount);
      // Actualizar las cuentas después de la transferencia
      await _accountProvider.fetchAccounts();
    } catch (e) {
      print('Error adjusting balance: $e');
    }
  }

  Future<List<TransferModel>> getTransfersByDateRange(
      DateTime start, DateTime end) async {
    _startDate = start;
    _endDate = end;
    _transfers = await _transferRepository.getTransfersByDateRange(start, end);
    notifyListeners();
    return _transfers;
  }

  Future<List<TransferModel>> getTodayTransfers() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay =
        startOfDay.add(Duration(days: 1)).subtract(Duration(microseconds: 1));
    return getTransfersByDateRange(startOfDay, endOfDay);
  }

  void updateDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    getTransfersByDateRange(start, end);
  }
}
