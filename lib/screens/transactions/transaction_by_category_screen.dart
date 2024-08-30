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

class _TransactionsByCategoryState extends State<TransactionsByCategory>
    with SingleTickerProviderStateMixin {
  String _selectedPeriod = 'Month';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    Future.microtask(() {
      Provider.of<TransactionProvider>(context, listen: false)
          .fetchCategories();
    }).then((_) => _animationController.forward());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName.toUpperCase()),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _searchTransactions(context),
            tooltip: 'Search transactions',
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

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildTotalAmountHeader(context, totalAmount),
                _buildFilterOptions(),
                Expanded(
                  child: _buildTransactionList(context, transactions,
                      transactionProvider, categoryProvider),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addNewTransaction(context),
        tooltip: 'Add new transaction',
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
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white),
          ),
          Text(
            'S/.${totalAmount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
    return transactions.isEmpty
        ? Center(child: Text('No transactions found'))
        : ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return FutureBuilder<Category>(
                future:
                    categoryProvider.getCategoryById(transaction.categoryId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildSkeletonListTile();
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
                    return _buildTransactionListTile(
                        context, transaction, category);
                  }
                },
              );
            },
          );
  }

  Widget _buildSkeletonListTile() {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
      ),
      title: Container(
        width: 100,
        height: 16,
        color: Colors.grey[300],
      ),
      subtitle: Container(
        width: 150,
        height: 14,
        color: Colors.grey[300],
      ),
      trailing: Container(
        width: 60,
        height: 20,
        color: Colors.grey[300],
      ),
    );
  }

  Widget _buildTransactionListTile(
      BuildContext context, TransactionModel transaction, Category category) {
    return ListTile(
      leading: Hero(
        tag: 'category_icon_${transaction.id}',
        child: CircleAvatar(
          backgroundColor:
              Color(int.parse(category.color.replaceFirst('#', '0xff'))),
          child: Icon(getIconDataByName(category.icon), color: Colors.white),
        ),
      ),
      title: Text(
        category.name,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        DateFormat('MMMM d, y').format(transaction.date),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(
        'S/.${transaction.amount.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: transaction.transactionType == 'expense'
                  ? Colors.red
                  : Colors.green,
            ),
      ),
      onTap: () => _navigateToTransactionDetail(context, transaction.id),
    );
  }

  void _searchTransactions(BuildContext context) {
    // TODO: Implement search functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Search functionality coming soon!')),
    );
  }

  void _addNewTransaction(BuildContext context) {
    // TODO: Navigate to add transaction screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add transaction functionality coming soon!')),
    );
  }

  void _navigateToTransactionDetail(
      BuildContext context, String transactionId) {
    context.go("/home/transaction_detail/$transactionId");
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
