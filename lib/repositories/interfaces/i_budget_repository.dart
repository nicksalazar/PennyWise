import 'package:nick_ai/models/category_model.dart';
import 'package:nick_ai/models/expense_model.dart';
import 'package:nick_ai/models/metodo_pago_model.dart';

abstract class IBudgetRepository {
  Future<List<PaymentMethod>> getMetodosPago();
  Future<List<Category>> getCategories();
  Future<void> archiveItem(String id, {bool archive = true});
  Future<Expense> insertItem(Expense item);
  Future<List<Expense>> getItems();
}