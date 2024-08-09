import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_harmony/models/account_model.dart';
import 'package:habit_harmony/providers/account_provider.dart';
import 'package:habit_harmony/providers/transfer_provider.dart';

import 'package:provider/provider.dart';

class AccountsScreen extends StatefulWidget {
  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  TextEditingController defaultValueController =
      TextEditingController(text: '0');
  TextEditingController accountNameController = TextEditingController();
  String? id;
  Color? _selectedColor;
  IconData? _selectedIcon;
  final _formKey = GlobalKey<FormState>();

  final List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
  ];

  final Map<String, IconData> iconDataMap = {
    'account_balance': Icons.account_balance,
    'account_circle': Icons.account_circle,
    'add_shopping_cart': Icons.add_shopping_cart,
    'airplanemode_active': Icons.airplanemode_active,
    'alarm': Icons.alarm,
    'album': Icons.album,
    'all_inclusive': Icons.all_inclusive,
    'android': Icons.android,
    'announcement': Icons.announcement,
    'apps': Icons.apps,
    // Add more icons as needed
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(context, listen: false).fetchAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // backgroundColor: Color(0xFFF5F5F5),
      child: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<AccountProvider>(context, listen: false)
              .fetchAccounts();
        },
        child: Consumer<TransferProvider>(
            builder: (context, transerProvider, child) {
          return Consumer<AccountProvider>(
              builder: (context, itemProvider, child) {
            final accounts = itemProvider.accounts;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Total Balance',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '\$${accounts.fold(0.0, (prev, account) => prev + account.balance).toString()}',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    // SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            // showModalBottomSheet(
                            //   context: context,
                            //   isScrollControlled: true,
                            //   builder: (context) => TransferHistoryWidget(),
                            // );
                          },
                          child: Column(
                            children: [
                              Icon(Icons.history, size: 30),
                              Text('Transfer History',
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Column(
                            children: [
                              Icon(Icons.money_sharp, size: 30),
                              Text('Transfer Account',
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                          ...accounts.map((account) {
                            return GestureDetector(
                              onTap: () => _showAddAccountDialog(
                                context,
                                isEdit: true,
                                id: account.id,
                                existingIcon: iconDataMap[account.icon],
                                existingName: account.name,
                                existingAmount: account.balance,
                                existingColor: account.color,
                              ),
                              child: AccountCard(
                                icon: iconDataMap[account.icon] ??
                                    Icons
                                        .help, // Use the map to get the IconData
                                title: account.name,
                                amount: account.balance.toInt(),
                                //color here and validate if is null
                                // Color here and validate if it is null
                                color: (account.color != null &&
                                        account.color.isNotEmpty &&
                                        account.color.length ==
                                            7 && // Ensure the hex color is in the format #RRGGBB
                                        account.color.startsWith('#'))
                                    ? () {
                                        try {
                                          final parsedColor = Color(int.parse(
                                                  account.color.substring(1),
                                                  radix: 16) +
                                              0xFF000000); // Add alpha value
                                          print('Parsed color: $parsedColor');
                                          return parsedColor;
                                        } catch (e) {
                                          print('Error parsing color: $e');
                                          return Colors
                                              .blue; // Fallback color in case of error
                                        }
                                      }()
                                    : Colors.blue,
                              ),
                            );
                          }),
                          GestureDetector(
                            onTap: () {
                              _showAddAccountDialog(context);
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Icon(Icons.add,
                                      size: 24, color: Colors.grey),
                                )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        }),
      ),
    );
  }

  Future<void> _submitForm(bool isEdit) async {
    if (_selectedColor != null && _selectedIcon != null) {
      String hexColor =
          '#${_selectedColor!.value.toRadixString(16).substring(2)}';

      if (isEdit) {
        Provider.of<AccountProvider>(context, listen: false).editAccount(
          Account(
            id: id!,
            name: accountNameController.text,
            icon: iconDataMap.keys.firstWhere(
              (key) => iconDataMap[key] == _selectedIcon,
              orElse: () => 'help',
            ),
            balance: double.parse(defaultValueController.text),
            color: hexColor,
          ),
        );
        Navigator.pop(context);
      } else {
        Provider.of<AccountProvider>(context, listen: false).addAccount(
          Account(
            id: "",
            name: accountNameController.text,
            icon: iconDataMap.keys.firstWhere(
              (key) => iconDataMap[key] == _selectedIcon,
              orElse: () => 'help',
            ),
            balance: double.parse(defaultValueController.text),
            color: hexColor,
          ),
        );

        Navigator.pop(context);
      }
    }
  }

  void _showAddAccountDialog(
    BuildContext context, {
    bool isEdit = false,
    String? id,
    IconData? existingIcon,
    String? existingName,
    double? existingAmount,
    String? existingColor,
  }) {
    defaultValueController =
        TextEditingController(text: existingAmount?.toString() ?? '0');
    accountNameController = TextEditingController(text: existingName ?? '');
    _selectedColor = (existingColor != null && existingColor.isNotEmpty)
        ? Color(int.parse(existingColor.substring(1), radix: 16))
        : null;
    this.id = id;
    _selectedIcon = existingIcon;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: defaultValueController,
                          decoration: InputDecoration(
                            labelText: 'Default Value',
                            hintText: '0',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
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
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: accountNameController,
                          decoration: InputDecoration(
                            labelText: 'Account Name',
                            border: OutlineInputBorder(),
                          ),
                          //here is the validator
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        Text('Select an Icon:'),
                        SizedBox(height: 16.0),
                        Container(
                          height: 200.0, // Adjust height as needed
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4, // Number of icons per row
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                            ),
                            itemCount: iconDataMap.length,
                            itemBuilder: (context, index) {
                              String iconName =
                                  iconDataMap.keys.elementAt(index);
                              IconData iconData = iconDataMap[iconName]!;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedIcon = iconData;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _selectedIcon == iconData
                                          ? Colors.blue
                                          : Colors.transparent,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Icon(
                                    iconData,
                                    size: 36.0,
                                    color: _selectedIcon == iconData
                                        ? Colors.blue
                                        : Colors.black,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        FormField<Color>(validator: (value) {
                          if (value == null) {
                            return 'Please select a color';
                          }
                          return null;
                        }, builder: (FormFieldState<Color> state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8.0,
                                children: _colors.map((color) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedColor = color;
                                        state.didChange(
                                            color); // Notificar al FormField del cambio
                                      });
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: color,
                                        border: _selectedColor == color
                                            ? Border.all(
                                                width: 3, color: Colors.black)
                                            : null,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              if (state.hasError)
                                Text(
                                  state.errorText!,
                                  style: TextStyle(color: Colors.red),
                                ),
                            ],
                          );
                        }),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // El formulario es válido
                              // Realizar la acción deseada
                              _submitForm(isEdit);
                            }
                          },
                          child:
                              Text(isEdit ? 'Edit Account' : 'Create Account'),
                        ),
                        // Add a delete button if editing an existing account
                        if (isEdit)
                          ElevatedButton(
                            onPressed: () {
                              Provider.of<AccountProvider>(context,
                                      listen: false)
                                  .deleteAccount(id!);
                              Navigator.pop(context);
                            },
                            child: Text('Delete Account'),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      // Reset the state when the bottom sheet is closed
      _selectedIcon = null;
      _selectedColor = null;
      defaultValueController.clear();
      accountNameController.clear();
    });
  }
}

class AccountCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int amount;
  final Color color;

  AccountCard({
    required this.icon,
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            size: 36.0,
            color: color,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              Text('\$${amount.toString()}'),
            ],
          ),
        ],
      ),
    );
  }
}
