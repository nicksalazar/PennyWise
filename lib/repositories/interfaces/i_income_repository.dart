import 'package:nick_ai/models/category_model.dart';
import 'package:nick_ai/models/income_model.dart';
import 'package:nick_ai/models/reception_method_model.dart';

abstract class IIncomeRepository {
  Future<List<ReceptionMethodModel>> getReceptionsPayment();
  Future<List<Category>> getCategories();
  Future<void> archiveItem(String id, {bool archive = true});
  Future<IncomeModel> insertItem(IncomeModel item);
  Future<List<IncomeModel>> getItems();
}
