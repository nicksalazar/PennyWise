import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_harmony/models/account_model.dart';
import 'package:habit_harmony/providers/account_provider.dart';
import 'package:habit_harmony/utils/icon_utils.dart';
import 'package:provider/provider.dart';

class AddAccountScreen extends StatefulWidget {
  final Account? account;

  AddAccountScreen({this.account});

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
    if (widget.account != null) {
      accountNameController.text = widget.account!.name;
      balanceController.text = widget.account!.balance.toString();
      selectedIcon = widget.account!.icon;
      selectedColor =
          Color(int.parse(widget.account!.color.replaceFirst('#', '0xFF')));

      // Assuming the currency is stored in the account model, update this line accordingly
      selectedCurrency =
          'PEN'; // Update this line if currency is stored in the account model
      includeInTotal =
          true; // Update this line if includeInTotal is stored in the account model
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account == null ? 'Add account' : 'Edit account'),
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
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
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
              Container(
                height: 200.0, // Adjust height as needed
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // Number of icons per row
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: iconMap.length,
                  itemBuilder: (context, index) {
                    String iconName = iconMap.keys.elementAt(index);
                    IconData iconData = iconMap[iconName]!;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIcon = iconName;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedIcon == iconName
                                ? selectedColor
                                : Colors.transparent,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(
                          iconData,
                          size: 36.0,
                          color: selectedIcon == iconName
                              ? selectedColor
                              : Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
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
                      onTap: () {},
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
              if (widget.account != null) // Check if editing
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
                        .deleteAccount(widget.account!.id);
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
                      _submitForm(widget.account != null);
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
    if (selectedColor != null && selectedIcon != null) {
      String hexColor =
          '#${selectedColor!.value.toRadixString(16).substring(2)}';

      if (isEdit) {
        Provider.of<AccountProvider>(context, listen: false).editAccount(
          Account(
            id: widget.account!.id,
            name: accountNameController.text,
            icon: selectedIcon,
            balance: double.parse(balanceController.text),
            color: hexColor,
          ),
        );
        Navigator.pop(context);
      } else {
        Provider.of<AccountProvider>(context, listen: false).addAccount(
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
  }
}
