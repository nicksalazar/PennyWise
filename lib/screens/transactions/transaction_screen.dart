import 'package:flutter/material.dart';
import 'package:pennywise/models/transaction_model.dart';
import 'package:pennywise/providers/transaction_provider.dart';
import 'package:pennywise/utils/icon_utils.dart';
import 'package:provider/provider.dart';
import 'package:pennywise/providers/account_provider.dart';
import 'package:pennywise/providers/category_provider.dart';
import 'package:pennywise/models/account_model.dart';
import 'package:pennywise/models/category_model.dart';
import 'package:pennywise/screens/transactions/calculator_screen.dart';

class TransactionScreen extends StatefulWidget {
  final String initialTransactionType;

  TransactionScreen({Key? key, required this.initialTransactionType})
      : super(key: key);
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isExpense = true;
  Account? selectedAccount;
  Category? selectedCategory;
  TextEditingController amountController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(context, listen: false).fetchAccounts();
    });
    isExpense = widget.initialTransactionType == 'expense';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountProvider = Provider.of<AccountProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transaction', style: theme.textTheme.titleLarge),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildToggleButtons(theme),
              SizedBox(height: 24),
              _buildAmountInput(theme),
              SizedBox(height: 24),
              _buildAccountDropdown(accountProvider, theme),
              SizedBox(height: 24),
              _buildCategorySection(categoryProvider, theme),
              SizedBox(height: 24),
              _buildDateSelection(theme),
              SizedBox(height: 24),
              _buildCommentSection(theme),
              SizedBox(height: 24),
              _buildAddButton(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButtons(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: theme.colorScheme.surface,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              'EXPENSES',
              isExpense,
              () => setState(() => isExpense = true),
              theme,
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              'INCOME',
              !isExpense,
              () => setState(() => isExpense = false),
              theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
      String label, bool isSelected, VoidCallback onTap, ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.bodyLarge!.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: theme.textTheme.headlineMedium,
            decoration: InputDecoration(
              hintText: '0',
              border: InputBorder.none,
              prefixIcon:
                  Icon(Icons.monetization_on, color: theme.colorScheme.primary),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              return null;
            },
          ),
        ),
        Text('PEN',
            style: theme.textTheme.titleLarge!
                .copyWith(color: theme.colorScheme.primary)),
        IconButton(
          icon: Icon(Icons.calculate, color: theme.colorScheme.primary),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CalculatorScreen()),
            );
          },
          tooltip: 'Open Calculator',
        ),
      ],
    );
  }

  Widget _buildAccountDropdown(
      AccountProvider accountProvider, ThemeData theme) {
    final accounts = accountProvider.accounts
        .where((Account account) => account.id != 'total')
        .toList();

    return DropdownButtonFormField<Account>(
      value: selectedAccount,
      hint: Text('Select Account', style: theme.textTheme.bodyLarge),
      decoration: InputDecoration(
        prefixIcon:
            Icon(Icons.account_balance, color: theme.colorScheme.primary),
      ),
      items: accounts.map((Account account) {
        return DropdownMenuItem<Account>(
          value: account,
          child: Text("${account.name} - PEN S/. ${account.balance}",
              style: theme.textTheme.bodyMedium),
        );
      }).toList(),
      onChanged: (Account? newValue) {
        setState(() {
          selectedAccount = newValue;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select an account';
        }
        return null;
      },
    );
  }

  Widget _buildCategorySection(
      CategoryProvider categoryProvider, ThemeData theme) {
    List<Category> categories = categoryProvider.categories
        .where(
            (category) => category.type == (isExpense ? 'expense' : 'income'))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categories', style: theme.textTheme.titleMedium),
        SizedBox(height: 12),
        Container(
          height: 100, // Altura fija para el contenedor de categorías
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory == category;
              return Padding(
                padding: EdgeInsets.only(right: 16),
                child: _buildCategoryItem(category, isSelected, theme),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
      Category category, bool isSelected, ThemeData theme) {
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = category),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Color(int.parse(category.color.replaceFirst('#', '0xff'))),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isSelected ? theme.colorScheme.primary : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              getIconDataByName(category.icon),
              color: isSelected ? theme.colorScheme.onPrimary : Colors.white,
              size: 30,
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: 60,
            child: Text(
              category.name,
              style: theme.textTheme.bodySmall!.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection(ThemeData theme) {
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date', style: theme.textTheme.titleMedium),
        SizedBox(height: 12),
        Row(
          children: [
            _buildDateButton(now, 'Today', theme),
            SizedBox(width: 8),
            _buildDateButton(
                now.subtract(Duration(days: 1)), 'Yesterday', theme),
            SizedBox(width: 8),
            _buildDateButton(
                now.subtract(Duration(days: 2)), '2 days ago', theme),
            SizedBox(width: 8),
            IconButton(
              icon:
                  Icon(Icons.calendar_today, color: theme.colorScheme.primary),
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              tooltip: 'Select Date',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateButton(DateTime date, String label, ThemeData theme) {
    final isSelected = DateUtils.isSameDay(date, selectedDate);
    return ElevatedButton(
      child: Text(
        '${date.day}/${date.month}\n$label',
        style: theme.textTheme.bodySmall!.copyWith(
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.primary,
        ),
        textAlign: TextAlign.center,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        setState(() {
          selectedDate = date;
        });
      },
    );
  }

  Widget _buildCommentSection(ThemeData theme) {
    return TextFormField(
      controller: commentController,
      decoration: InputDecoration(
        hintText: 'Add a comment',
        prefixIcon: Icon(Icons.comment, color: theme.colorScheme.primary),
      ),
      maxLines: 3,
      style: theme.textTheme.bodyMedium,
    );
  }

  Widget _buildAddButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        child: Text(
          'Add Transaction',
          style: theme.textTheme.titleMedium!
              .copyWith(color: theme.colorScheme.onPrimary),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate() && selectedCategory != null) {
            Provider.of<TransactionProvider>(context, listen: false)
                .addTransaction(
              TransactionModel(
                id: '',
                description: commentController.text,
                date: selectedDate,
                categoryId: selectedCategory!.id,
                accountId: selectedAccount!.id,
                amount: double.parse(amountController.text),
                transactionType: isExpense ? 'expense' : 'income',
              ),
            );
            Navigator.of(context).pop();
          } else if (selectedCategory == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please select a category'),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
      ),
    );
  }
}
