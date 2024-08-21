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
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(context, listen: false).fetchAccounts();
    });
    isExpense = widget.initialTransactionType == 'expense';
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transaction'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildToggleButtons(),
              SizedBox(height: 20),
              _buildAmountInput(),
              SizedBox(height: 20),
              _buildAccountDropdown(accountProvider),
              SizedBox(height: 20),
              _buildCategoryGrid(categoryProvider),
              SizedBox(height: 20),
              _buildDateSelection(),
              SizedBox(height: 20),
              // _buildTagsSection(),
              // SizedBox(height: 20),
              _buildCommentSection(),
              SizedBox(height: 20),
              _buildAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isExpense = true),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isExpense ? Colors.white : Colors.green,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    'EXPENSES',
                    style: TextStyle(
                      color: isExpense ? Colors.green : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isExpense = false),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !isExpense ? Colors.white : Colors.green,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    'INCOME',
                    style: TextStyle(
                      color: !isExpense ? Colors.green : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 24),
            decoration: InputDecoration(
              hintText: '0',
              border: InputBorder.none,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              return null;
            },
          ),
        ),
        Text('PEN', style: TextStyle(fontSize: 24, color: Colors.green)),
        IconButton(
          icon: Icon(Icons.calculate, color: Colors.green),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CalculatorScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAccountDropdown(AccountProvider accountProvider) {

    final accounts = accountProvider.accounts
        .where((Account account) => account.id != 'total')
        .toList();

    final cuentas = accounts.map((e) => e.name).toList();
    return DropdownButtonFormField<Account>(
      value: selectedAccount,
      hint: Text('Select Account'),
      items: accounts
          .map((Account account) {
        return DropdownMenuItem<Account>(
          value: account,
          child: Text("${account.name} - PEN S/. ${account.balance}"),
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

  Widget _buildCategoryGrid(CategoryProvider categoryProvider) {
    List<Category> categories = categoryProvider.categories
        .where(
            (category) => category.type == (isExpense ? 'expense' : 'income'))
        .toList();
    print("categories ${categories.length}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categories', style: TextStyle(color: Colors.grey)),
        SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category;
            return GestureDetector(
              onTap: () => setState(() => selectedCategory = category),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color.fromARGB(255, 76, 175, 135)
                          : Color(int.parse(
                              category.color.replaceFirst('#', '0xff'))),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(getIconDataByName(category.icon),
                        color: Colors.white),
                  ),
                  SizedBox(height: 5),
                  Text(category.name, style: TextStyle(fontSize: 12)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateSelection() {
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date', style: TextStyle(color: Colors.grey)),
        SizedBox(height: 10),
        Row(
          children: [
            _buildDateButton(now, 'Today'),
            SizedBox(width: 10),
            _buildDateButton(now.subtract(Duration(days: 1)), 'Yesterday'),
            SizedBox(width: 10),
            _buildDateButton(now.subtract(Duration(days: 2)), '2 days ago'),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.calendar_today, color: Colors.green),
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
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateButton(DateTime date, String label) {
    final isSelected = DateUtils.isSameDay(date, selectedDate);
    return ElevatedButton(
      child: Text('${date.day}/${date.month}\n$label'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        textStyle: TextStyle(fontSize: 12),
      ),
      onPressed: () {
        setState(() {
          selectedDate = date;
        });
      },
    );
  }

  Widget _buildTagsSection() {
    return Row(
      children: [
        Text('Tags', style: TextStyle(color: Colors.grey)),
        SizedBox(width: 10),
        ElevatedButton.icon(
          icon: Icon(Icons.add, color: Colors.green),
          label: Text('Add tag', style: TextStyle(color: Colors.green)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.green),
          ),
          onPressed: () {
            // TODO: Implement add tag functionality
          },
        ),
        Spacer(),
        Icon(Icons.search, color: Colors.green),
      ],
    );
  }

  Widget _buildCommentSection() {
    return TextFormField(
      controller: commentController,
      decoration: InputDecoration(
        hintText: 'Comment',
        border: UnderlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        child: Text('Add'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate() && selectedCategory != null) {
            // TODO: Implement add transaction functionality
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
              SnackBar(content: Text('Please select a category')),
            );
          }
        },
      ),
    );
  }
}
