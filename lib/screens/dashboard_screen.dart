import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habit_harmony/screens/account_screen.dart';
import 'package:habit_harmony/screens/expense_screen.dart';
import 'package:habit_harmony/screens/income_screen.dart';

class FinanceDashboard extends StatefulWidget {
  const FinanceDashboard({Key? key}) : super(key: key);

  @override
  _FinanceDashboardState createState() => _FinanceDashboardState();
}

class _FinanceDashboardState extends State<FinanceDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Accounts'),
            Tab(text: 'Expenses'),
            Tab(text: 'Income'),
            Tab(text: 'Analysis'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AccountsScreen(),
          ExpenseScreen(),
          IncomeScreen(),
          AnalysisTab(),
        ],
      ),
    );
  }
}

class OverviewTab extends StatelessWidget {
  final List<Map<String, dynamic>> monthlyData;
  final List<Map<String, dynamic>> expenses;

  const OverviewTab(
      {Key? key, required this.monthlyData, required this.expenses})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monthly Overview',
                      style: Theme.of(context).textTheme.headlineSmall),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: monthlyData
                                .map((data) => FlSpot(
                                      monthlyData.indexOf(data).toDouble(),
                                      data['income'].toDouble(),
                                    ))
                                .toList(),
                            isCurved: true,
                            dotData: FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: monthlyData
                                .map((data) => FlSpot(
                                      monthlyData.indexOf(data).toDouble(),
                                      data['expenses'].toDouble(),
                                    ))
                                .toList(),
                            isCurved: true,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30, // Adjust the size as needed
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < monthlyData.length) {
                                  return Text(monthlyData[index]['month']);
                                }
                                return Text('');
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Expense Breakdown',
                      style: Theme.of(context).textTheme.headlineSmall),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: PieChart(
                      PieChartData(
                        sections: expenses
                            .map((expense) => PieChartSectionData(
                                  color: Colors.primaries[
                                      expenses.indexOf(expense) %
                                          Colors.primaries.length],
                                  value: expense['amount'].toDouble(),
                                  title:
                                      '${expense['category']}\n${expense['amount']}',
                                  radius: 100,
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpensesTab extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;

  const ExpensesTab({Key? key, required this.expenses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expense Categories',
                style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: expenses
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
                          if (index >= 0 && index < expenses.length) {
                            return Text(
                              expenses[index]['category'],
                              style: meta.axisSide == AxisSide.bottom
                                  ? TextStyle(color: Colors.black, fontSize: 10)
                                  : TextStyle(color: Colors.transparent),
                            );
                          }
                          return Text('');
                        },
                        reservedSize: 40, // Adjust based on your UI needs
                      ),
                    ),
                  ),
                  barGroups: expenses.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                            toY: entry.value['amount'].toDouble(),
                            color: Colors.blue)
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

class AnalysisTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Financial Assistant',
                style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 16),
            Text(
                'Based on your spending habits, here are some recommendations:'),
            SizedBox(height: 8),
            Text(
                '• Your food expenses are higher than average. Consider meal prepping to reduce costs.'),
            Text("You're doing well with savings! Keep it up."),
            Text(
                '• Look into investing more of your income for long-term growth.'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement detailed analysis functionality
              },
              child: Text('Get Detailed Analysis'),
            ),
          ],
        ),
      ),
    );
  }
}
