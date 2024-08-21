import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pennywise/models/account_model.dart';
import 'package:pennywise/providers/account_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pennywise/providers/transfer_provider.dart';
import 'package:pennywise/models/transfer_model.dart';

class TransferHistoryScreen extends StatefulWidget {
  @override
  _TransferHistoryScreenState createState() => _TransferHistoryScreenState();
}

class _TransferHistoryScreenState extends State<TransferHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Day', 'Week', 'Month', 'Year', 'Period'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // Initialize with today's transfers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransferProvider>(context, listen: false).getTodayTransfers();
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      final transferProvider =
          Provider.of<TransferProvider>(context, listen: false);
      DateTime now = DateTime.now();
      DateTime startDate, endDate;

      switch (_tabController.index) {
        case 0: // Day
          startDate = DateTime(now.year, now.month, now.day);
          endDate = startDate
              .add(Duration(days: 1))
              .subtract(Duration(microseconds: 1));
          break;
        case 1: // Week
          startDate = now.subtract(Duration(days: 7));
          endDate = now;
          break;
        case 2: // Month
          startDate = DateTime(now.year, now.month, 1);
          endDate = now;
          break;
        case 3: // Year
          startDate = DateTime(now.year, 1, 1);
          endDate = now;
          break;
        case 4: // Period
          _showDateRangePicker();
          return;
        default:
          return;
      }

      transferProvider.updateDateRange(startDate, endDate);
    }
  }

  void _showDateRangePicker() async {
    final transferProvider =
        Provider.of<TransferProvider>(context, listen: false);
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: transferProvider.startDate,
        end: transferProvider.endDate,
      ),
    );
    if (picked != null) {
      transferProvider.updateDateRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Transfer History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((String name) => Tab(text: name)).toList(),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Expanded(
              child: Consumer<AccountProvider>(
                  builder: (context, accountProvider, child) {
                return Consumer<TransferProvider>(
                  builder: (context, transferProvider, child) {
                    if (transferProvider.transfers.isEmpty) {
                      return Center(
                        child: Text('No transfers found'),
                      );
                    }

                    final groupedTransfers =
                        _groupTransfersByDate(transferProvider.transfers);

                    final accounts = accountProvider.accounts;
                    return ListView.builder(
                      itemCount: groupedTransfers.length,
                      itemBuilder: (context, index) {
                        final date = groupedTransfers.keys.elementAt(index);
                        final dateTransfers = groupedTransfers[date]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                DateFormat('MMMM d, y').format(date),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...dateTransfers.map((transfer) => ListTile(
                                  title: Text(
                                    () {
                                      switch (transfer.type) {
                                        case "deposit":
                                          return 'Deposit';
                                        case "adjustment":
                                          return 'Adjustment';
                                        case "transfer":
                                          return 'Transfer';
                                        case "initial":
                                          return 'Initial Balance';
                                        default:
                                          return 'Unknown';
                                      }
                                    }(),
                                  ),
                                  subtitle: Text(
                                    () {
                                      switch (transfer.type) {
                                        case "adjustment":
                                          final account = accounts.firstWhere(
                                            (account) =>
                                                account.id ==
                                                transfer.sourceAccountId,
                                            orElse: () => Account(
                                              id: "",
                                              name: "",
                                              icon: "",
                                              balance: 0,
                                              color: "",
                                            ),
                                          );
                                          return 'Adjustment to ${account.name}';
                                        case "transfer":
                                          final sourceAccount =
                                              accounts.firstWhere(
                                            (account) =>
                                                account.id ==
                                                transfer.sourceAccountId,
                                            orElse: () => Account(
                                              id: "",
                                              name: "",
                                              icon: "",
                                              balance: 0,
                                              color: "",
                                            ),
                                          );

                                          final destinationAccount =
                                              accounts.firstWhere(
                                            (account) =>
                                                account.id ==
                                                transfer.destinationAccountId,
                                            orElse: () => Account(
                                              id: "",
                                              name: "",
                                              icon: "",
                                              balance: 0,
                                              color: "",
                                            ),
                                          );
                                          return "transfer " +
                                              sourceAccount.name +
                                              " -> " +
                                              destinationAccount.name;
                                        case "initial":
                                          final account = accounts.firstWhere(
                                            (account) =>
                                                account.id ==
                                                transfer.destinationAccountId,
                                            orElse: () => Account(
                                              id: "",
                                              name: "",
                                              icon: "",
                                              balance: 0,
                                              color: "",
                                            ),
                                          );
                                          return 'Initial Balance to ${account.name}';
                                        default:
                                          return 'Unknown';
                                      }
                                    }(),
                                  ),
                                  trailing: Text(
                                    '\$${transfer.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: transfer.amount > 0
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )),
                          ],
                        );
                      },
                    );
                  },
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  context.go('/accounts/new_transfer');
                },
                child: Text('New Transfer'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<DateTime, List<TransferModel>> _groupTransfersByDate(
      List<TransferModel> transfers) {
    final groupedTransfers = <DateTime, List<TransferModel>>{};
    for (var transfer in transfers) {
      final date =
          DateTime(transfer.date.year, transfer.date.month, transfer.date.day);
      if (!groupedTransfers.containsKey(date)) {
        groupedTransfers[date] = [];
      }
      groupedTransfers[date]!.add(transfer);
    }
    return groupedTransfers;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
