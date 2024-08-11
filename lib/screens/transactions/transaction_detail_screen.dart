import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_harmony/models/account_model.dart';
import 'package:habit_harmony/models/category_model.dart';
import 'package:habit_harmony/providers/account_provider.dart';
import 'package:habit_harmony/providers/category_provider.dart';
import 'package:habit_harmony/providers/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:habit_harmony/models/transaction_model.dart';

class TransactionDetailScreen extends StatelessWidget {
  final String transactionId;

  TransactionDetailScreen({required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return Consumer3<TransactionProvider, CategoryProvider, AccountProvider>(
      builder: (context, transactionProvider, categoryProvider, accountProvider,
          child) {
        final transaction = transactionProvider.transactions.firstWhere(
          (t) => t.id == transactionId,
          orElse: () => TransactionModel(
            id: '',
            amount: 0,
            description: 'Unknown',
            date: DateTime.now(),
            categoryId: '',
            accountId: '',
            transactionType: '',
          ),
        );

        final category = categoryProvider.categories.firstWhere(
          (c) => c.id == transaction.categoryId,
          orElse: () => Category(
            id: '',
            name: 'Unknown',
            color: '#000000',
            icon: 'help',
            type: 'expense',
          ),
        );

        final account = accountProvider.accounts.firstWhere(
          (a) => a.id == transaction.accountId,
          orElse: () => Account(
            id: '',
            name: 'Unknown',
            balance: 0,
            color: '#000000',
            icon: 'help',
          ),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text('Transaction Details'),
            actions: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  // TODO: Implement edit functionality
                },
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'S/.${transaction.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 16),
                _buildDetailRow('Description', transaction.description),
                _buildDetailRow('Category', category.name),
                _buildDetailRow('Account', account.name),
                _buildDetailRow('Date', _formatDate(transaction.date)),
                SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    child: Text('Delete Transaction'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Deletion'),
                            content: Text(
                                'Are you sure you want to delete this transaction?'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Delete'),
                                onPressed: () {
                                  transactionProvider
                                      .deleteTransaction(transaction.id);
                                  Navigator.of(context).pop();
                                  context.go('/');
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
