import 'package:flutter/material.dart';
import 'package:nick_ai/models/category_model.dart';
import 'package:nick_ai/models/income_model.dart';
import 'package:nick_ai/models/reception_method_model.dart';
import 'package:nick_ai/repositories/income_repository.dart'; 

class IncomeProvider with ChangeNotifier {
  List<IncomeModel> _items = [];
  List<Category> _categories = [];
  List<ReceptionMethodModel> _receptionMethod = [];

  List<IncomeModel> get items => _items;
  List<Category> get categories => _categories;
  List<ReceptionMethodModel> get metodosPago => _receptionMethod;

  //categories
  final IncomeRepository _repository = IncomeRepository();

  void addItem(IncomeModel item) async {
    final Item = await _repository.insertItem(item);
    _items.insert(0, Item);
    notifyListeners();
  }

  void removeItem(String id, {bool archive = true}) {
    _items.removeWhere((item) => item.id == id);
    _repository.archiveItem(id, archive: archive);
    notifyListeners();
  }

  Future<void> fetchItems() async {
    final items = await _repository.getItems();
    _items.clear();
    _items.addAll(items);
    notifyListeners();
  }

  Future<void> loadInitialData() async {
    final categories = await _repository.getCategories();
    final receptionsMethods = await _repository.getReceptionsPayment();
    _categories.addAll(categories);
    _receptionMethod.addAll(receptionsMethods);
    notifyListeners();
  }
}
