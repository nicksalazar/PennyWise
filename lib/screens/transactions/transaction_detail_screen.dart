import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pennywise/models/account_model.dart';
import 'package:pennywise/models/category_model.dart';
import 'package:pennywise/providers/account_provider.dart';
import 'package:pennywise/providers/category_provider.dart';
import 'package:pennywise/providers/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:pennywise/models/transaction_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  TransactionDetailScreen({required this.transactionId});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen>
    with SingleTickerProviderStateMixin {
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
          .fetchTransactions();
      Provider.of<AccountProvider>(context, listen: false).fetchAccounts();
    }).then((_) => _animationController.forward());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer3<TransactionProvider, CategoryProvider, AccountProvider>(
      builder: (context, transactionProvider, categoryProvider, accountProvider,
          child) {
        final transaction = transactionProvider.transactions.firstWhere(
          (t) => t.id == widget.transactionId,
          orElse: () => TransactionModel(
            id: '',
            amount: 0,
            description: l10n.unknown,
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
            name: l10n.unknown,
            color: '#000000',
            icon: 'help',
            type: 'expense',
          ),
        );

        final account = accountProvider.accounts.firstWhere(
          (a) => a.id == transaction.accountId,
          orElse: () => Account(
            id: '',
            name: l10n.unknown,
            balance: 0,
            color: '#000000',
            icon: 'help',
          ),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.transactionDetail),
            actions: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _editTransaction(context, transaction, l10n),
              ),
              // IconButton(
              //   icon: Icon(Icons.share),
              //   onPressed: () =>
              //       _shareTransaction(transaction, category, account),
              // ),
            ],
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'S/.${transaction.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 24),
                  _buildDetailGroup(
                    l10n.transactionDetail,
                    [
                      _buildDetailRow(l10n.trasactionDescription,
                          transaction.description, Icons.description),
                      _buildDetailRow(l10n.date, _formatDate(transaction.date),
                          Icons.calendar_today),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildDetailGroup(
                    l10n.categoryAndAccount,
                    [
                      _buildDetailRow(l10n.category, category.name, Icons.category,
                          color: Color(
                              int.parse('0xFF${category.color.substring(1)}'))),
                      _buildDetailRow(
                          l10n.accountsTitle, account.name, Icons.account_balance,
                          color: Color(
                              int.parse('0xFF${account.color.substring(1)}'))),
                    ],
                  ),
                  Spacer(),
                  Center(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.delete),
                      label: Text(l10n.deleteTransaction),
                      onPressed: () => _deleteTransaction(context, transaction, l10n),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                        minimumSize: Size(200, 50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon,
      {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon,
              color: color ?? Theme.of(context).iconTheme.color, size: 24),
          SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editTransaction(BuildContext context, TransactionModel transaction, AppLocalizations l10n) {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.comingSoon)),
    );
  }

//   void _shareTransaction(
//       TransactionModel transaction, Category category, Account account) {
//     final String shareText = '''
// Transaction Details:
// Amount: S/.${transaction.amount.toStringAsFixed(2)}
// Description: ${transaction.description}
// Date: ${_formatDate(transaction.date)}
// Category: ${category.name}
// Account: ${account.name}
// ''';
//     Share.share(shareText, subject: 'Transaction Details');
//   }

  void _deleteTransaction(BuildContext context, TransactionModel transaction, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteTransaction),
          content: Text(l10n.deleteTransactionPrompt),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text(l10n.delete),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await Provider.of<TransactionProvider>(context, listen: false)
                    .deleteTransaction(transaction)
                    .then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.transactionDeleted),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  GoRouter.of(context).go('/home');
                });
              },
            ),
          ],
        );
      },
    );
  }
}
