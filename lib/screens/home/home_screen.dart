import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habit_harmony/screens/transactions/transaction_screen.dart';
import 'package:habit_harmony/widgets/my_drawer.dart';

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpenseTrackerHome();
  }
}

class ExpenseTrackerHome extends StatefulWidget {
  @override
  _ExpenseTrackerHomeState createState() => _ExpenseTrackerHomeState();
}

class _ExpenseTrackerHomeState extends State<ExpenseTrackerHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Week';
  bool _isScrolled = false;
  ScrollController _scrollController = ScrollController();

  final List<String> _periodOptions = [
    'Day',
    'Week',
    'Month',
    'Year',
    'Period'
  ];
  final List<ExpenseItem> _expenseData = [
    ExpenseItem('Debt', 29, 100, Color(0xFF4CAF50), Icons.credit_card),
    ExpenseItem('Bike', 28, 95, Color(0xFFE91E63), Icons.pedal_bike),
    ExpenseItem('Comida afuera', 22, 74, Color(0xFF2196F3), Icons.restaurant),
    ExpenseItem('Groceries', 12, 41.97, Color(0xFF3F51B5), Icons.shopping_cart),
    ExpenseItem('Haircut', 4, 15, Color(0xFFFFC107), Icons.content_cut),
    ExpenseItem('Streaming', 3, 11, Color(0xFFFF5722), Icons.movie),
    ExpenseItem(
        'Transportation', 2, 6, Color(0xFF03A9F4), Icons.directions_bus),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _isScrolled = _scrollController.offset > 50;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.monetization_on,
              ),
              Padding(padding: EdgeInsets.only(left: 8)),
              DropdownButton<String>(
                value: 'Total',
                onChanged: (String? newValue) {},
                items: <String>['Total', 'Option 1', 'Option 2']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(icon: Icon(Icons.receipt), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'EXPENSES'),
            Tab(text: 'INCOME'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExpensesTab(),
          Center(child: Text('Income Tab')),
        ],
      ),
      drawer: MyDrawer(),
    );
  }

  Widget _buildExpensesTab() {
    return ListView(
      controller: _scrollController,
      children: [
        Card(
          color: Theme.of(context).cardColor,
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _periodOptions
                      .map((period) => GestureDetector(
                            onTap: () =>
                                setState(() => _selectedPeriod = period),
                            child: Text(
                              period,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: _selectedPeriod == period
                                        ? Theme.of(context)
                                            .colorScheme
                                            .secondary
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                  ),
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(height: 16),
                Text('Jul 28 - Aug 3'),
                SizedBox(height: 16),
                _isScrolled ? _buildBarChart() : _buildPieChart(),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TransactionScreen()),
                      );
                    },
                    child: Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
        ),
        ..._expenseData.map(_buildExpenseItem).toList(),
      ],
    );
  }

  Widget _buildPieChart() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: _expenseData
                  .map((item) => PieChartSectionData(
                        color: item.color,
                        value: item.percentage.toDouble(),
                        title: '${item.percentage}%',
                        radius: 50,
                        titleStyle: TextStyle(
                          fontSize: 12,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
        Center(
          child: Text(
            'S/.342.97',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return SizedBox(
      height: 100,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barGroups: _expenseData
              .asMap()
              .entries
              .map((entry) => BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        fromY: entry.value.percentage.toDouble(),
                        toY: 100,
                        color: entry.value.color,
                        width: 16,
                      )
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildExpenseItem(ExpenseItem item) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: Icon(item.icon, color: item.color),
        title: Text(item.name),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${item.percentage}%'),
            Text(
              'S/.${item.amount.toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseItem {
  final String name;
  final int percentage;
  final double amount;
  final Color color;
  final IconData icon;

  ExpenseItem(this.name, this.percentage, this.amount, this.color, this.icon);
}
