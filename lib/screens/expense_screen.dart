import 'package:flutter/material.dart';
import 'package:habit_harmony/models/account_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:habit_harmony/providers/expense_provider.dart';
import 'package:habit_harmony/widgets/expense_add_form.dart';
import 'package:habit_harmony/widgets/spending_chart.dart';

import '../models/category_model.dart';
import '../models/payment_method_model.dart';

class ExpenseScreen extends StatefulWidget {
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).fetchExpenses();
      Provider.of<ExpenseProvider>(context, listen: false).fetchCategories();
      Provider.of<ExpenseProvider>(context, listen: false).fetchAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<ExpenseProvider>(context, listen: false)
              .fetchExpenses();
        },
        child: Consumer<ExpenseProvider>(
          builder: (context, expenseProvider, child) {
            final expenses = expenseProvider.expenses;
            final categories = expenseProvider.categories;
            final accounts = expenseProvider.accounts;
            if (expenses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.money_off, size: 100, color: Colors.grey),
                    SizedBox(height: 20),
                    Text(
                      "No expenses recorded",
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: expenses.length + 1, // +1 for the chart
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SpendingChart(),
                  );
                }

                final expense = expenses[index - 1];
                final category = categories.firstWhere(
                  (cat) => cat.id == expense.categoryId,
                  orElse: () => Category(
                      id: '',
                      name: 'Unknown',
                      color: '#CCCCCC',
                      type: "expense"),
                );
                final account = accounts.firstWhere(
                  (acc) => acc.id == expense.accountId,
                  orElse: () => Account(
                    id: '',
                    name: 'Unknown',
                    balance: 0,
                    icon: "help",
                  ),
                );

                return Dismissible(
                  key: Key(expense.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    // Show confirmation dialog
                    final result = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirm Deletion"),
                          content: Text(
                              "Are you sure you want to delete this item?"),
                          actions: <Widget>[
                            TextButton(
                              child: Text("Cancel"),
                              onPressed: () {
                                // User canceled the deletion, insert the item back into the list
                                Navigator.of(context)
                                    .pop(false); // Close the dialog
                              },
                            ),
                            TextButton(
                              child: Text("Delete"),
                              onPressed: () {
                                // User confirmed the deletion, delete the item from Firebase
                                Navigator.of(context)
                                    .pop(true); // Close the dialog
                              },
                            ),
                          ],
                        );
                      },
                    );
                    if (result == true) {
                      // User confirmed the deletion, delete the item from Firebase
                      expenseProvider.deleteExpense(expense.id);
                      return true; // Proceed with the dismissal
                    } else {
                      // User canceled or dismissed the dialog, do not dismiss the item
                      return false; // Cancel the dismissal
                    }
                  },
                  child: Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Color(
                            int.parse('0xFF${category.color.substring(1)}')),
                        child: Icon(Icons.category, color: Colors.white),
                      ),
                      title: Text(
                        expense.description,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            DateFormat('MMMM d, y').format(expense.date),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 4),
                          Chip(
                            label: Text(
                              account.name,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            backgroundColor: Color(int.parse(
                                '0xFF${category.color.substring(1)}')),
                          ),
                        ],
                      ),
                      trailing: Text(
                        '- \S/${expense.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(
                            int.parse('0xFF${category.color.substring(1)}'),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddBudgetForm(initialCategory: "expense");
            },
          );
        },
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
      ),
    );
  }
}
