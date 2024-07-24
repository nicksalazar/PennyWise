import 'package:flutter/material.dart';
import 'package:habit_harmony/repositories/hydration_repository.dart';
import '../models/hydration_model.dart';

class HydrationProvider with ChangeNotifier {
  final HydrationRepository _repository;
  List<HydrationModel> _drinks = [];
  List<HydrationModel> _drinks_per_week = [];
  double _totalWaterConsumed = 0;
  final double dailyGoal = 2000;

  HydrationProvider(this._repository);

  List<HydrationModel> get drinks => _drinks;
  List<HydrationModel> get drinks_per_week => _drinks_per_week;
  double get totalWaterConsumed => _totalWaterConsumed;

  Future<void> fetchDrinkEntries() async {
    try {
      _drinks = await _repository.fetchDrinkEntries(DateTime.now());
      _calculateTotalWaterConsumed();
      notifyListeners();
    } catch (e) {
      print('Error fetching drink entries: $e');
    }
  }

  void _calculateTotalWaterConsumed() {
    _totalWaterConsumed = _drinks.fold(0, (sum, drink) => sum + drink.amount);
    //drinks per week
  }

  Future<void> addDrinkEntry(HydrationModel entry) async {
    await _repository.addDrinkEntry(entry);
    _drinks.add(entry);
    _drinks_per_week.add(entry);
    _calculateTotalWaterConsumed();
    notifyListeners();
  }

  //fetch drink by range
  Future<void> fetchDrinkEntriesByRange(
      DateTime startDate, DateTime endDate) async {
    try {
      _drinks_per_week = await _repository.fetchDrinkEntriesByRange(startDate, endDate);
      _calculateTotalWaterConsumed();
      notifyListeners();
    } catch (e) {
      print('Error fetching drink entries: $e');
    }
  }

  //deleteDrinkEntry
  Future<void> deleteDrinkEntry(String id) async {
    await _repository.deleteDrinkEntry(id);
    _drinks.removeWhere((element) => element.id == id);
    _drinks_per_week.removeWhere((element) => element.id == id);
    _calculateTotalWaterConsumed();
    notifyListeners();
  }
}
