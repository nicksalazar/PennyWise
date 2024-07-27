import 'package:flutter_test/flutter_test.dart';
import 'package:habit_harmony/models/income_model.dart';

void main() {
  group('Income Model Tests', () {
	test('Crear instancia de Income', () {
	  final income = Income(
		id: '1',
		description: 'Salary',
		date: DateTime.now(),
		categoryId: 'cat1',
		amount: 1000.0,
		accountId: 'Bank Transfer',
	  );

	  expect(income.description, 'Salary');
	  expect(income.amount, 1000.0);
	});
  });
}