import 'package:flutter/material.dart';
import 'package:pennywise/models/transfer_model.dart';
import 'package:pennywise/providers/account_provider.dart';
import 'package:pennywise/providers/loading_provider.dart';
import 'package:pennywise/repositories/transfer_repository.dart';

class TransferProvider with ChangeNotifier {
  final TransferRepository _transferRepository;
  final LoadingProvider _loadingProvider;

  TransferProvider(this._transferRepository, this._loadingProvider) {
    getTodayTransfers();
  }
  List<TransferModel> _transfers = [];
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  List<TransferModel> get transfers => _transfers;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  Future<void> addTransfer(
      TransferModel transfer, AccountProvider accountProvider) async {
    try {
      _loadingProvider.setLoading(true);
      await _transferRepository.createTransfer(transfer);
      await accountProvider.fetchAccounts();
      notifyListeners();
    } catch (e) {
      print('Error adding transfer: $e');
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  //adjust balance
  Future<void> adjustBalance(String accountId, double amount) async {
    try {
      _loadingProvider.setLoading(true);
      await _transferRepository.adjustBalance(accountId, amount);
      notifyListeners();
    } catch (e) {
      print('Error adjusting balance: $e');
    } finally {
      _loadingProvider.setLoading(false);
    }
  }

  Future<List<TransferModel>> getTransfersByDateRange(
      DateTime start, DateTime end) async {
    try {
      _loadingProvider.setLoading(true);
      _startDate = start;
      _endDate = end;
      _transfers =
          await _transferRepository.getTransfersByDateRange(start, end);
      notifyListeners();
      return _transfers;
    } catch (e) {
      print('Error fetching transfers: $e');
      return [];
    } finally {
      _loadingProvider.setLoading(false);
    }
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

  Future<void> createTransferInitital(TransferModel transferModel) async {
    try {
      _loadingProvider.setLoading(true);
      await _transferRepository.createTransferInitital(transferModel);
      notifyListeners();
    } catch (e) {
      print('Error creating transfer: $e');
    } finally {
      _loadingProvider.setLoading(false);
    }
  }
}
