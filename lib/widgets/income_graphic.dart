import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:habit_harmony/models/category_model.dart';
import 'package:habit_harmony/models/income_model.dart';

class IncomeGraphicWidget extends StatefulWidget {
  final List<Income> incomes;
  final List<Category> categories;

  const IncomeGraphicWidget({
    super.key,
    required this.incomes,
    required this.categories,
  });

  @override
  State<IncomeGraphicWidget> createState() => _IncomeGraphicWidgetState();
}

class _IncomeGraphicWidgetState extends State<IncomeGraphicWidget> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = widget.categories.where((category) {
      final categorySum = widget.incomes
          .where((income) => income.categoryId == category.id)
          .fold<double>(
              0.0, (previousValue, income) => previousValue + income.amount);
      return categorySum > 0;
    }).toList();

    // Create BarChartGroupData for each category
    final barGroups = filteredCategories.map((category) {
      final categorySum = widget.incomes
          .where((income) => income.categoryId == category.id)
          .fold<double>(
              0.0, (previousValue, income) => previousValue + income.amount);
      return BarChartGroupData(
        x: filteredCategories.indexOf(category),
        barRods: [
          BarChartRodData(
            toY: categorySum,
            color: Colors.blue,
          ),
        ],
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Income Sources',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < filteredCategories.length) {
                        return Text(
                          filteredCategories[index].name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        );
                      }
                      return const SizedBox(); // Add a return statement to ensure a non-null value is always returned
                    },
                    interval: 20,
                  ))),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval:
                        20, // Esto alineará las líneas de la cuadrícula con los títulos
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
