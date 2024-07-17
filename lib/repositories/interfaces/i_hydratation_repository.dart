import 'package:nick_ai/models/hydration_model.dart';

abstract class IHydratationRepository {
  Future<void> addDrinkEntry(HydrationModel entry);
  Future<List<HydrationModel>> fetchDrinkEntries(DateTime date);
  Future<List<HydrationModel>> fetchDrinkEntriesByRange(
      DateTime startDate, DateTime endDate);
  Future<void> deleteDrinkEntry(String id);
}
