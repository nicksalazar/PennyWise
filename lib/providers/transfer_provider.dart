import 'package:flutter/material.dart';
import 'package:habit_harmony/models/transfer_model.dart';
import 'package:habit_harmony/providers/account_provider.dart';
import 'package:habit_harmony/repositories/account_repository.dart';
import 'package:habit_harmony/repositories/transfer_repository.dart';

class TransferProvider with ChangeNotifier {
  final TransferRepository _transferRepository = TransferRepository();
  final AccountProvider _accountProvider;
  List<TransferModel> _transfers = [];
  List<TransferModel> get transfers => _transfers;
  TransferProvider(this._accountProvider);
  Future<void> addTransfer(TransferModel transfer) async {
    try {
      await _transferRepository.createTransfer(transfer);
      _transfers.add(transfer);
      notifyListeners();
      // Actualizar las cuentas después de la transferencia
      await _accountProvider.fetchAccounts();
    } catch (e) {
      print('Error adding transfer: $e');
    }
  }

  Future<List<TransferModel>> getTransfersByDateRange(
      DateTime start, DateTime end) async {
    // Implement this method to fetch transfers from Firestore
    // between the start and end dates
    return [];
  }
}
