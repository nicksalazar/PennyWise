import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habit_harmony/models/account_model.dart';
import 'package:habit_harmony/providers/Income_provider.dart';
import 'package:habit_harmony/providers/account_provider.dart';
import 'package:provider/provider.dart';

class AccountsScreen extends StatefulWidget {
  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(context, listen: false).fetchAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<AccountProvider>(context, listen: false)
              .fetchAccounts();
        },
        child:
            Consumer<AccountProvider>(builder: (context, itemProvider, child) {
          final accounts = itemProvider.accounts;

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text('Total Balance', style: TextStyle(fontSize: 18)),
                  Text(
                    '\$${accounts.fold(0.0, (prev, account) => prev + account.balance).toString()}',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
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
                            onTap: () => _showAddAccountDialog(context,
                                isEdit: true,
                                id: account.id,
                                existingIcon: iconDataMap[account.icon],
                                existingName: account.name,
                                existingAmount: account.balance),
                            child: AccountCard(
                              icon: iconDataMap[account.icon] ??
                                  Icons.help, // Use the map to get the IconData
                              title: account.name,
                              amount: account.balance.toInt(),
                              color: Colors.white,
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
        }),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context,
      {bool isEdit = false,
      String? id,
      IconData? existingIcon,
      String? existingName,
      double? existingAmount}) {
    IconData? selectedIcon = existingIcon;
    TextEditingController defaultValueController =
        TextEditingController(text: existingAmount?.toString() ?? '0');
    TextEditingController accountNameController =
        TextEditingController(text: existingName ?? '');

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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: defaultValueController,
                        decoration: InputDecoration(
                          labelText: 'Default Value',
                          hintText: '0',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                      ),
                      SizedBox(height: 16.0),
                      TextField(
                        controller: accountNameController,
                        decoration: InputDecoration(
                          labelText: 'Account Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text('Select an Icon:'),
                      SizedBox(height: 16.0),
                      Container(
                        height: 200.0, // Adjust height as needed
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, // Number of icons per row
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                          ),
                          itemCount: iconDataMap.length,
                          itemBuilder: (context, index) {
                            String iconName = iconDataMap.keys.elementAt(index);
                            IconData iconData = iconDataMap[iconName]!;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIcon = iconData;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedIcon == iconData
                                        ? Colors.blue
                                        : Colors.transparent,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Icon(
                                  iconData,
                                  size: 36.0,
                                  color: selectedIcon == iconData
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          if (isEdit) {
                            Provider.of<AccountProvider>(context, listen: false)
                                .editAccount(
                              Account(
                                id: id!,
                                name: accountNameController.text,
                                icon: iconDataMap.keys.firstWhere(
                                  (key) => iconDataMap[key] == selectedIcon,
                                  orElse: () => 'help',
                                ),
                                balance:
                                    double.parse(defaultValueController.text),
                              ),
                            );
                            Navigator.pop(context);
                          } else {
                            Provider.of<AccountProvider>(context, listen: false)
                                .addAccount(
                              Account(
                                id: accountNameController.text,
                                name: accountNameController.text,
                                icon: iconDataMap.keys.firstWhere(
                                  (key) => iconDataMap[key] == selectedIcon,
                                  orElse: () => 'help',
                                ),
                                balance:
                                    double.parse(defaultValueController.text),
                              ),
                            );
                
                            Navigator.pop(context);
                          }
                        },
                        child: Text(isEdit ? 'Edit Account' : 'Create Account'),
                      ),
                      // Add a delete button if editing an existing account
                      if (isEdit)
                        ElevatedButton(
                          onPressed: () {
                            Provider.of<AccountProvider>(context, listen: false)
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
            );
          },
        );
      },
    ).whenComplete(() {
      // Reset the state when the bottom sheet is closed
      selectedIcon = null;
      defaultValueController.clear();
      accountNameController.clear();
    });
  }

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
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 36.0),
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
