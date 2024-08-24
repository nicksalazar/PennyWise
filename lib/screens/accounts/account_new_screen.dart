import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pennywise/models/account_model.dart';
import 'package:pennywise/providers/account_provider.dart';
import 'package:pennywise/providers/category_provider.dart';
import 'package:pennywise/utils/icon_utils.dart';
import 'package:pennywise/widgets/color_selector_widget.dart';
import 'package:provider/provider.dart';

class AddAccountScreen extends StatefulWidget {
  final String? accountId;

  AddAccountScreen({this.accountId});

  @override
  _AddAccountScreenState createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  String selectedIcon = '';
  Color selectedColor = Colors.yellow;
  String selectedCurrency = 'PEN';
  bool includeInTotal = true;
  TextEditingController accountNameController = TextEditingController();
  TextEditingController balanceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<Color> colors = [
    Colors.yellow,
    Colors.green.shade200,
    Colors.green,
    Colors.pink,
    Colors.blue,
    Colors.red,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    //get mains providers
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(context, listen: false).fetchAccounts();
      //categories
      Provider.of<CategoryProvider>(context, listen: false);
    });
    if (widget.accountId != null) {
      final account = Provider.of<AccountProvider>(context, listen: false)
          .getAccountById(widget.accountId!);
      accountNameController.text = account.name;
      balanceController.text = account.balance.toString();
      selectedIcon = account.icon;
      selectedColor = Color(int.parse(account.color.replaceFirst('#', '0xFF')));

      // Assuming the currency is stored in the account model, update this line accordingly
      selectedCurrency =
          'PEN'; // Update this line if currency is stored in the account model
      includeInTotal =
          true; // Update this line if includeInTotal is stored in the account model
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = categorizedIcons.entries
        .map((e) => e.value)
        .expand((element) => element)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.accountId == null ? 'Add account' : 'Edit account'),
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
              SizedBox(height: 20),
              TextFormField(
                controller: balanceController,
                decoration: InputDecoration(
                  labelText: 'Initial Balance',
                  suffixText: selectedCurrency,
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: accountNameController,
                decoration: InputDecoration(
                  labelText: 'Account name',
                  hintText: 'Enter account name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
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
                            selectedIcon = result;
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
                        selectedIcon = iconName;
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: selectedIcon == iconName
                          ? selectedColor
                          : Colors.grey[300],
                      child: Icon(
                        iconData,
                        color: selectedIcon == iconName
                            ? Colors.white
                            : Colors.black,
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              Text('Color', style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Row(
                children: colors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor.value == color.value
                              ? Colors.black
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList()
                  ..add(
                    GestureDetector(
                      onTap: () {
                        //ColorSelector
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ColorSelector(
                              onColorSelected: (color) {
                                setState(() {
                                  selectedColor = color;
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Icon(Icons.add, size: 20),
                      ),
                    ),
                  ),
              ),
              SizedBox(height: 20),
              Text('Select currency', style: TextStyle(fontSize: 16)),
              DropdownButton<String>(
                value: selectedCurrency,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCurrency = newValue!;
                  });
                },
                items: <String>['PEN', 'USD', 'EUR', 'GBP']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Do not include in total balance',
                      style: TextStyle(fontSize: 16)),
                  Switch(
                    value: !includeInTotal,
                    onChanged: (value) {
                      setState(() {
                        includeInTotal = !value;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
              SizedBox(height: 40),
              if (widget.accountId != null) // Check if editing
                ElevatedButton(
                  child: Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    textStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    // Handle delete account logic
                    Provider.of<AccountProvider>(context, listen: false)
                        .deleteAccount(widget.accountId!);
                    Navigator.pop(context);
                  },
                ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  child: Text('Add'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // El formulario es válido
                      // Realizar la acción deseada
                      _submitForm(widget.accountId != null);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm(bool isEdit) async {
    try {
      if (selectedColor != null && selectedIcon != null) {
        String hexColor =
            '#${selectedColor!.value.toRadixString(16).substring(2)}';

        if (isEdit) {
          await Provider.of<AccountProvider>(context, listen: false)
              .editAccount(
            Account(
              id: widget.accountId!,
              name: accountNameController.text,
              icon: selectedIcon,
              balance: double.parse(balanceController.text),
              color: hexColor,
            ),
          );
          Navigator.pop(context);
        } else {
          await Provider.of<AccountProvider>(context, listen: false).addAccount(
            Account(
              id: "",
              name: accountNameController.text,
              icon: selectedIcon,
              balance: double.parse(balanceController.text),
              color: hexColor,
            ),
          );

          Navigator.pop(context);
        }
      }
    } catch (e) {
      //snack dialog red
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
