import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_harmony/models/transaction_model.dart';
import 'package:habit_harmony/providers/transaction_provider.dart';
import 'package:habit_harmony/utils/icon_utils.dart';
import 'package:intl/intl.dart';

class TransactionsByCategory extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String transactionType;

  TransactionsByCategory({
    required this.categoryId,
    required this.categoryName,
    required this.transactionType,
  });

  @override
  _TransactionsByCategoryState createState() => _TransactionsByCategoryState();
}

class _TransactionsByCategoryState extends State<TransactionsByCategory> {
  String _selectedPeriod = 'Month';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName.toUpperCase()),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              // TODO: Implement download functionality
            },
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          final allTransactions = transactionProvider.getFilteredTransactions(
            transactionType: widget.transactionType,
            period: _selectedPeriod,
          );
          final transactions = allTransactions
              .where((t) => t.categoryId == widget.categoryId)
              .toList();
          final totalAmount = transactionProvider.getTotalAmount(transactions);

          return Column(
            children: [
              _buildTotalAmountHeader(context, totalAmount),
              _buildFilterOptions(),
              Expanded(
                child: _buildTransactionList(
                    context, transactions, transactionProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // TODO: Navigate to add transaction screen
        },
      ),
    );
  }

  Widget _buildTotalAmountHeader(BuildContext context, double totalAmount) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Theme.of(context).primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          Text(
            'S/.${totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<String>(
            value: _selectedPeriod,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedPeriod = newValue;
                });
              }
            },
            items: <String>['Day', 'Week', 'Month', 'Year']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
      BuildContext context,
      List<TransactionModel> transactions,
      TransactionProvider transactionProvider) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final category =
            transactionProvider.getCategoryById(transaction.categoryId);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(int.parse(
                category?.color.replaceFirst('#', '0xff') ?? '0xff000000')),
            child: Icon(getIconDataByName(category?.name ?? ""),
                color: Colors.white),
          ),
          title: Text(transaction.description),
          subtitle: Text(DateFormat('MMMM d, y').format(transaction.date)),
          trailing: Text(
            'S/.${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: transaction.transactionType == 'expense'
                  ? Colors.red
                  : Colors.green,
            ),
          ),
          onTap: () {
            // TODO: Navigate to transaction detail screen
          },
        );
      },
    );
  }
}
