import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_harmony/models/category_model.dart';
import 'package:habit_harmony/providers/account_provider.dart';
import 'package:habit_harmony/providers/category_provider.dart';
import 'package:habit_harmony/providers/transaction_provider.dart';
import 'package:habit_harmony/screens/transactions/transaction_by_category_screen.dart';
import 'package:habit_harmony/utils/icon_utils.dart';
import 'package:habit_harmony/widgets/account_selection_dialog.dart';
import 'package:habit_harmony/widgets/my_drawer.dart';
import 'package:provider/provider.dart';
import 'package:habit_harmony/utils/icon_utils.dart';

class HomeScreen extends StatelessWidget {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false)
          .fetchTransactions();
      Provider.of<CategoryProvider>(context, listen: false);
      Provider.of<AccountProvider>(context, listen: false);
    });
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
    return Consumer2<AccountProvider, TransactionProvider>(
        builder: (context, accountProvider, transactionProvider, child) {
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
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AccountSelectionDialog();
                  },
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.monetization_on),
                  Padding(padding: EdgeInsets.only(left: 8)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        accountProvider.selectedAccountName,
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        accountProvider.hideBalance
                            ? '****'
                            : 'S/.${accountProvider.selectedAccountBalance.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
            _buildTransactionsTab(
                'expense', accountProvider, transactionProvider),
            _buildTransactionsTab(
                'income', accountProvider, transactionProvider),
          ],
        ),
        drawer: MyDrawer(),
      );
    });
  }

  Widget _buildTransactionsTab(
    String transactionType,
    AccountProvider accountProvider,
    TransactionProvider transactionProvider,
  ) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categories = categoryProvider.categories;
        final allTransactions = transactionProvider.getFilteredTransactions(
          transactionType: transactionType,
          period: _selectedPeriod,
        );
        final transactions =
            accountProvider.getTransactionsForSelectedAccount(allTransactions);

        // Group transactions by category and sum amounts
        Map<String, double> categoryTotals = {};
        for (var transaction in transactions) {
          categoryTotals[transaction.categoryId] =
              (categoryTotals[transaction.categoryId] ?? 0) +
                  transaction.amount;
        }

        final categoryItems = categoryTotals.entries.map((entry) {
          final category = categories.firstWhere(
            (category) => category.id == entry.key,
            orElse: () => Category(
                id: '',
                name: 'Unknown',
                color: '#000000',
                icon: 'help',
                type: transactionType),
          );
          return ExpenseItem(
            category.id,
            category.name,
            0, // We'll calculate this later
            entry.value,
            Color(int.parse(category.color.replaceFirst('#', '0xff'))),
            getIconDataByName(category.icon),
          );
        }).toList();

        // Calculate percentages
        double total = categoryItems.fold(0, (sum, item) => sum + item.amount);
        categoryItems.forEach((item) {
          item.percentage = ((item.amount / total) * 100).round();
        });

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
                    Text(_getDateRangeText()),
                    SizedBox(height: 16),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: _isScrolled ? 100 : 200,
                      child: _isScrolled
                          ? _buildCompactChart(categoryItems)
                          : _buildPieChart(categoryItems),
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        onPressed: () {
                          context.go('/home/new_transaction/$transactionType');
                        },
                        child: Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...categoryItems
                .map((item) => _buildExpenseItem(item, transactionType)),
          ],
        );
      },
    );
  }

  String _getDateRangeText() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Day':
        return '${now.day} ${_getMonthName(now.month)}';
      case 'Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(Duration(days: 6));
        return '${startOfWeek.day} - ${endOfWeek.day} ${_getMonthName(endOfWeek.month)}';
      case 'Month':
        return '${_getMonthName(now.month)} ${now.year}';
      case 'Year':
        return '${now.year}';
      default:
        return '';
    }
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthNames[month - 1];
  }

  Widget _buildPieChart(List<ExpenseItem> data) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: data
                  .map((item) => PieChartSectionData(
                        color: item.color,
                        value: item.amount,
                        title: '${item.percentage}%',
                        radius: 50,
                        titleStyle: TextStyle(fontSize: 12),
                      ))
                  .toList(),
            ),
          ),
        ),
        Center(
          child: Text(
            'S/.${data.fold(0.0, (sum, item) => sum + item.amount).toStringAsFixed(2)}',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactChart(List<ExpenseItem> data) {
    if (data.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text('No hay datos para mostrar'),
        ),
      );
    }

    double maxY = data
        .map((item) => item.amount)
        .reduce((max, amount) => amount > max ? amount : max);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: data
            .asMap()
            .entries
            .map((entry) => BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.amount,
                      color: entry.value.color,
                      width: 12,
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }

  Widget _buildExpenseItem(ExpenseItem item, String transactionType) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionsByCategory(
              categoryId: item.id,
              categoryName: item.name,
              transactionType: transactionType, // or 'income'
            ),
          ),
        );
      },
      child: Card(
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
              Text('S/.${item.amount.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpenseItem {
  //id
  final String id;
  final String name;
  int percentage;
  final double amount;
  final Color color;
  final IconData icon;

  ExpenseItem(
      this.id, this.name, this.percentage, this.amount, this.color, this.icon);
}
