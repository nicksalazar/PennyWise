import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pennywise/models/category_model.dart';
import 'package:pennywise/providers/category_provider.dart';
import 'package:pennywise/utils/icon_utils.dart';
import 'package:provider/provider.dart';

class NewCategoryScreen extends StatefulWidget {
  @override
  _NewCategoryScreenState createState() => _NewCategoryScreenState();
}

class _NewCategoryScreenState extends State<NewCategoryScreen> {
  bool isExpense = true;
  String _name = '';
  String _type = 'expense';
  String _selectedIcon = 'help';
  Color _selectedColor = Colors.red;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final categories = categorizedIcons.entries
        .map((e) => e.value)
        .expand((element) => element)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Category'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'Enter a category name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Radio(
                    value: true,
                    groupValue: isExpense,
                    onChanged: (bool? value) {
                      setState(() {
                        isExpense = value!;
                      });
                    },
                  ),
                  Text('Expenses'),
                  Radio(
                    value: false,
                    groupValue: isExpense,
                    onChanged: (bool? value) {
                      setState(() {
                        isExpense = value!;
                      });
                    },
                  ),
                  Text('Income'),
                ],
              ),
              SizedBox(height: 16),
              Text('Icons'),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                ),
                itemCount: (categories.length * 0.08).ceil() + 1,
                itemBuilder: (context, index) {
                  if (index == (categories.length * 0.08).ceil()) {
                    return InkWell(
                      onTap: () async {
                        final result = await context.push(
                          '/categories/icon_catalog',
                        );
                        print("here is result $result");
                        if (result != null && result is String) {
                          setState(() {
                            _selectedIcon = result;
                          });
                        }
                      },
                      child: Icon(
                        Icons.more_horiz,
                        size: 40,
                      ),
                    );
                  }

                  final iconName = categories[index];
                  final iconData = getIconDataByName(iconName);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIcon = iconName;
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: _selectedIcon == iconName
                          ? _selectedColor
                          : Colors.grey[300],
                      child: Icon(
                        iconData,
                        color: _selectedIcon == iconName
                            ? Colors.white
                            : Colors.black,
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              Text('Color'),
              Wrap(
                spacing: 8,
                children: [
                  ColorButton(
                      color: Colors.pink,
                      isSelected: _selectedColor == Colors.pink,
                      onTap: () => setColor(Colors.pink)),
                  ColorButton(
                      color: Colors.blue,
                      isSelected: _selectedColor == Colors.blue,
                      onTap: () => setColor(Colors.blue)),
                  ColorButton(
                      color: Colors.yellow,
                      isSelected: _selectedColor == Colors.yellow,
                      onTap: () => setColor(Colors.yellow)),
                  ColorButton(
                      color: Colors.green,
                      isSelected: _selectedColor == Colors.green,
                      onTap: () => setColor(Colors.green)),
                  ColorButton(
                      color: Colors.red,
                      isSelected: _selectedColor == Colors.red,
                      onTap: () => setColor(Colors.red)),
                  ColorButton(
                      color: Colors.cyan,
                      isSelected: _selectedColor == Colors.cyan,
                      onTap: () => setColor(Colors.cyan)),
                  ColorButton(
                      color: Colors.grey,
                      isSelected: _selectedColor == Colors.grey,
                      onTap: () => setColor(Colors.grey)),
                ],
              ),
              //rectangle button with rounder yellow
              SizedBox(
                height: 16,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newCategory = Category(
        id: '',
        name: _name,
        icon: _selectedIcon,
        color:
            '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
        type: isExpense ? 'expense' : 'income',
      );
      Provider.of<CategoryProvider>(context, listen: false)
          .addCategory(newCategory);
      context.pop();
    }
  }

  void setColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }
}

class ColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const ColorButton({
    Key? key,
    required this.color,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
      ),
    );
  }
}
