import 'package:habit_harmony/models/category_model.dart';
import 'package:habit_harmony/models/expense_model.dart';
import 'package:habit_harmony/models/payment_method_model.dart';

abstract class IBudgetRepository {
  Future<List<PaymentMethod>> getMetodosPago();
  Future<List<Category>> getCategories();
  Future<void> archiveItem(String id, {bool archive = true});
  Future<Expense> insertItem(Expense item);
  Future<List<Expense>> getItems();
}