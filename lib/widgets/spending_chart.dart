import 'package:flutter/material.dart';
import 'package:habit_harmony/providers/expense_provider.dart';
import 'package:habit_harmony/utils/utils.dart' as utils;
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

class SpendingChart extends StatelessWidget {
  //constructor
  SpendingChart({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
      final expenses = expenseProvider.expenses;
      final categories = expenseProvider.categories;

      final colors = categories.map((category) {
        final colorHex = category.color.replaceFirst('#', '');
        final colorInt = int.parse(colorHex, radix: 16);
        return Color(colorInt).withOpacity(1.0);
      }).toList();
      return Card(
          margin: const EdgeInsets.all(0.0),
          elevation: 2.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            height: 350.0,
            child: Column(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: categories
                          .map((category) {
                            final totalAmount = expenses
                                .where((expense) =>
                                    expense.categoryId == category.id)
                                .fold<double>(
                                    0.0,
                                    (previousValue, element) =>
                                        previousValue + element.amount);
                            return MapEntry(category,
                                totalAmount); // Crea un MapEntry con la categoría y su total
                          })
                          .where((entry) =>
                              entry.value >
                              0)
                          .map((entry) {
                            return PieChartSectionData(
                              color: colors[categories.indexOf(entry
                                  .key)], // Usa entry.key para obtener la categoría
                              value: entry
                                  .value, // Usa entry.value para obtener el total
                              title: utils.formatCurrency(entry.value),
                              radius: 100.0,
                              titleStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            );
                          })
                          .toList(),
                      sectionsSpace: 0,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: categories
                      .map((category) {
                        final totalAmount = expenses
                            .where(
                                (expense) => expense.categoryId == category.id)
                            .fold<double>(
                                0.0,
                                (previousValue, element) =>
                                    previousValue + element.amount);
                        return MapEntry(category, totalAmount);
                      })
                      .where((entry) => entry.value > 0)
                      .map((entry) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16.0,
                              height: 16.0,
                              color: colors[categories.indexOf(entry.key)],
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              entry.key.name,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              utils.formatCurrency(entry.value),
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        );
                      })
                      .toList(),
                )
              ],
            ),
          ));
    });
  }
}
