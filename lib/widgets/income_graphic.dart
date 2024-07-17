import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class IncomeGraphicWidget extends StatefulWidget {
  const IncomeGraphicWidget({
    super.key,
  });

  @override
  State<IncomeGraphicWidget> createState() => _IncomeGraphicWidgetState();
}

class _IncomeGraphicWidgetState extends State<IncomeGraphicWidget> {
  final List<Map<String, dynamic>> income = [
    {'category': 'Salary', 'amount': 5000},
    {'category': 'Freelance', 'amount': 2000},
    {'category': 'Extra', 'amount': 1000},
  ];
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                  maxY: income
                      .map((e) => e['amount'] as num)
                      .reduce((a, b) => a > b ? a : b)
                      .toDouble(),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < income.length) {
                            return Text(income[index]['category']);
                          }
                          return Text('');
                        },
                      ),
                    ),
                  ),
                  barGroups: income.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value['amount'].toDouble(),
                          color: Colors.green,
                        )
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
