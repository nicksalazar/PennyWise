import 'package:flutter/material.dart';
import 'package:habit_harmony/screens/transactions/calculator_screen.dart';
import 'package:habit_harmony/themes/app_theme.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  bool isExpense = true;
  String selectedCategory = '';
  TextEditingController amountController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  final List<Map<String, dynamic>> categories = [
    {'name': 'Health', 'icon': Icons.favorite, 'color': Colors.red},
    {'name': 'Leisure', 'icon': Icons.wallet, 'color': Colors.green},
    {'name': 'Home', 'icon': Icons.home, 'color': Colors.blue},
    {'name': 'Cafe', 'icon': Icons.restaurant, 'color': Colors.orange},
    {'name': 'Education', 'icon': Icons.school, 'color': Colors.purple},
    {
      'name': 'Groceries',
      'icon': Icons.shopping_basket,
      'color': Colors.lightBlue
    },
    {'name': 'Family', 'icon': Icons.family_restroom, 'color': Colors.red},
    {'name': 'More', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transactions'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildToggleButtons(),
              SizedBox(height: 20),
              _buildAmountInput(),
              SizedBox(height: 20),
              Text('Account', style: TextStyle(color: Colors.grey)),
              Text('Not selected', style: TextStyle(color: Colors.green)),
              SizedBox(height: 20),
              Text('Categories', style: TextStyle(color: Colors.grey)),
              _buildCategoryGrid(),
              SizedBox(height: 20),
              _buildDateSelection(),
              SizedBox(height: 20),
              _buildTagsSection(),
              SizedBox(height: 20),
              _buildCommentSection(),
              SizedBox(height: 20),
              _buildPhotoSection(),
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
          child: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 24),
            decoration: InputDecoration(
              hintText: '0',
              border: InputBorder.none,
            ),
          ),
        ),
        Text('PEN', style: TextStyle(fontSize: 24, color: Colors.green)),
        IconButton(
          icon: Icon(Icons.calculate, color: Colors.green),
          onPressed: () {
            //NAVIGATOR PUSSH CALCULATOR_sCREEN
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CalculatorScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () => setState(() => selectedCategory = category['name']),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: category['color'],
                  shape: BoxShape.circle,
                ),
                child: Icon(category['icon'], color: Colors.white),
              ),
              SizedBox(height: 5),
              Text(category['name'], style: TextStyle(fontSize: 12)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateSelection() {
    final now = DateTime.now();
    return Row(
      children: [
        _buildDateButton(now, 'today'),
        SizedBox(width: 10),
        _buildDateButton(now.subtract(Duration(days: 1)), 'yesterday'),
        SizedBox(width: 10),
        _buildDateButton(now.subtract(Duration(days: 2)), 'two days ago'),
        SizedBox(width: 10),
        IconButton(
          icon: Icon(Icons.calendar_today, color: Colors.green),
          onPressed: () {
            // TODO: Implement date picker
          },
        ),
      ],
    );
  }

  Widget _buildDateButton(DateTime date, String label) {
    return ElevatedButton(
      child: Text('${date.day}/${date.month}\n$label'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        textStyle: TextStyle(fontSize: 12),
      ),
      onPressed: () {
        // TODO: Implement date selection
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
    return TextField(
      controller: commentController,
      decoration: InputDecoration(
        hintText: 'Comment',
        border: UnderlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildPhotoSection() {
    return Row(
      children: List.generate(
          3,
          (index) => Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              )),
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
          // TODO: Implement add transaction functionality
        },
      ),
    );
  }
}
