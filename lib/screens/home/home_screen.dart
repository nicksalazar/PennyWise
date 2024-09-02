import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pennywise/models/category_model.dart';
import 'package:pennywise/providers/account_provider.dart';
import 'package:pennywise/providers/category_provider.dart';
import 'package:pennywise/providers/transaction_provider.dart';
import 'package:pennywise/screens/transactions/transaction_by_category_screen.dart';
import 'package:pennywise/utils/icon_utils.dart';
import 'package:pennywise/widgets/account_selection_dialog.dart';
import 'package:pennywise/widgets/my_drawer.dart';
import 'package:provider/provider.dart';

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
  int _selectedPeriodIndex = 1; // 1 corresponde a 'week'
  bool _isScrolled = false;
  ScrollController _scrollController = ScrollController();

  late List<String> _periodOptions;
  late List<String> _periodValues;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false)
          .fetchTransactions();
      Provider.of<CategoryProvider>(context, listen: false);
      Provider.of<AccountProvider>(context, listen: false).initializeData();
    });
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _periodOptions = [
      AppLocalizations.of(context)!.day,
      AppLocalizations.of(context)!.week,
      AppLocalizations.of(context)!.month,
      AppLocalizations.of(context)!.year,
      AppLocalizations.of(context)!.period,
    ];
    _periodValues = ['day', 'week', 'month', 'year', 'period'];
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
              Tab(text: AppLocalizations.of(context)!.expenses),
              Tab(text: AppLocalizations.of(context)!.income),
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
          period: _periodValues[_selectedPeriodIndex],
        );
        final transactions =
            accountProvider.getTransactionsForSelectedAccount(allTransactions);

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
                name: AppLocalizations.of(context)!.unknown,
                color: '#000000',
                icon: 'help',
                type: transactionType),
          );
          return ExpenseItem(
            category.id,
            category.name,
            0,
            entry.value,
            Color(int.parse(category.color.replaceFirst('#', '0xff'))),
            getIconDataByName(category.icon),
          );
        }).toList();

        double total = categoryItems.fold(0, (sum, item) => sum + item.amount);
        categoryItems.map((item) {
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
                          .asMap()
                          .entries
                          .map((entry) => GestureDetector(
                                onTap: () => setState(
                                    () => _selectedPeriodIndex = entry.key),
                                child: Text(
                                  entry.value,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: _selectedPeriodIndex == entry.key
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
    switch (_periodValues[_selectedPeriodIndex]) {
      case 'day':
        return '${now.day} ${_getMonthName(now.month)}';
      case 'week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(Duration(days: 6));
        return '${startOfWeek.day} - ${endOfWeek.day} ${_getMonthName(endOfWeek.month)}';
      case 'month':
        return '${_getMonthName(now.month)} ${now.year}';
      case 'year':
        return '${now.year}';
      default:
        return '';
    }
  }

  String _getMonthName(int month) {
    final monthNames = [
      AppLocalizations.of(context)!.jan,
      AppLocalizations.of(context)!.feb,
      AppLocalizations.of(context)!.mar,
      AppLocalizations.of(context)!.apr,
      AppLocalizations.of(context)!.may,
      AppLocalizations.of(context)!.jun,
      AppLocalizations.of(context)!.jul,
      AppLocalizations.of(context)!.aug,
      AppLocalizations.of(context)!.sep,
      AppLocalizations.of(context)!.oct,
      AppLocalizations.of(context)!.nov,
      AppLocalizations.of(context)!.dec
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
          child: Text(AppLocalizations.of(context)!.noDataToDisplay),
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
              transactionType: transactionType,
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
  final String id;
  final String name;
  int percentage;
  final double amount;
  final Color color;
  final IconData icon;

  ExpenseItem(
      this.id, this.name, this.percentage, this.amount, this.color, this.icon);
}
