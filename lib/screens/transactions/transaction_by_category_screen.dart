import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pennywise/models/category_model.dart';
import 'package:pennywise/providers/category_provider.dart';
import 'package:provider/provider.dart';
import 'package:pennywise/models/transaction_model.dart';
import 'package:pennywise/providers/transaction_provider.dart';
import 'package:pennywise/utils/icon_utils.dart';
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
  void initState() {
    // TODO: implement initState
    super.initState();
    // Fetch categories after the widget is built
    Future.microtask(() {
      Provider.of<TransactionProvider>(context, listen: false)
          .fetchCategories();
          //category provider
      Provider.of<CategoryProvider>(context, listen: false);
    });
  }

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
      body: Consumer2<TransactionProvider, CategoryProvider>(
        builder: (context, transactionProvider, categoryProvider, child) {
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
                child: _buildTransactionList(context, transactions,
                    transactionProvider, categoryProvider),
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
      TransactionProvider transactionProvider,
      CategoryProvider categoryProvider) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return FutureBuilder<Category>(
          future: categoryProvider.getCategoryById(transaction.categoryId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListTile(
                title: Text('Loading...'),
              );
            } else if (snapshot.hasError) {
              return ListTile(
                title: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData) {
              return ListTile(
                title: Text('No category found'),
              );
            } else {
              final category = snapshot.data!;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(
                      int.parse(category.color.replaceFirst('#', '0xff'))),
                  child: Icon(getIconDataByName(category.icon),
                      color: Colors.white),
                ),
                title: Text(category.name),
                subtitle:
                    Text(DateFormat('MMMM d, y').format(transaction.date)),
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
                  context.go("/home/transaction_detail/${transaction.id}");
                },
              );
            }
          },
        );
      },
    );
  }
}
