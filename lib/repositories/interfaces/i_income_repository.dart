import 'package:habit_harmony/models/category_model.dart';
import 'package:habit_harmony/models/income_model.dart';
import 'package:habit_harmony/models/reception_method_model.dart';

abstract class IIncomeRepository {
  Future<List<ReceptionMethod>> getReceptionsPayment();
  Future<List<Category>> getCategories();
  Future<void> archiveItem(String id, {bool archive = true});
  Future<Income> insertItem(Income item);
  Future<List<Income>> getItems();
}
