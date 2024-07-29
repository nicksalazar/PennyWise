import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:habit_harmony/providers/transfer_provider.dart';
import 'package:habit_harmony/models/transfer_model.dart';

class TransferHistoryWidget extends StatefulWidget {
  @override
  _TransferHistoryWidgetState createState() => _TransferHistoryWidgetState();
}

class _TransferHistoryWidgetState extends State<TransferHistoryWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Day', 'Week', 'Month', 'Year', 'Period'];
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _startDate = DateTime.now();
            _endDate = DateTime.now();
            break;
          case 1:
            _startDate = DateTime.now().subtract(Duration(days: 7));
            _endDate = DateTime.now();
            break;
          case 2:
            _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
            _endDate = DateTime.now();
            break;
          case 3:
            _startDate = DateTime(DateTime.now().year, 1, 1);
            _endDate = DateTime.now();
            break;
          case 4:
            // For 'Period', we'll show a date range picker
            _showDateRangePicker();
            break;
        }
      });
    }
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
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
              child: Consumer<TransferProvider>(
                builder: (context, transferProvider, child) {
                  return FutureBuilder<List<TransferModel>>(
                    future: transferProvider.getTransfersByDateRange(
                        _startDate, _endDate),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No transfers found'));
                      } else {
                        final transfers = snapshot.data!;
                        final groupedTransfers =
                            _groupTransfersByDate(transfers);
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
                                        transfer.sourceAccountId ==
                                                transfer.destinationAccountId
                                            ? 'Deposit'
                                            : 'Transfer',
                                      ),
                                      subtitle: Text(
                                          '${transfer.sourceAccountId} to ${transfer.destinationAccountId}'),
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
                      }
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement new transfer creation
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
