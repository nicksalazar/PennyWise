import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_harmony/models/account_model.dart';
import 'package:habit_harmony/providers/account_provider.dart';
import 'package:habit_harmony/utils/icon_utils.dart';
import 'package:habit_harmony/widgets/my_drawer.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
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
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text('Accounts'),
      ),
      body:
          Consumer<AccountProvider>(builder: (context, accountProvider, child) {
  
        List<Account> accounts = accountProvider.accounts;
        if (accounts.isNotEmpty) {
          accounts.removeAt(0);
        }
        return Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Total:',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '\S/. ${accounts.fold(0.0, (prev, account) => prev + account.balance).toString()}',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.history),
                  label: Text('Transfer history'),
                  onPressed: () {
                    context.go("/accounts/transfer_history");
                  },
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.swap_horiz),
                  label: Text('New transfer'),
                  onPressed: () {
                    context.go("/accounts/new_transfer");
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  accounts.isEmpty
                      ? Center(
                          child: Text('No accounts found'),
                        )
                      : Column(
                          children: accounts
                              .map((account) => InkWell(
                                    onTap: () {
                                      context.go(
                                          "/accounts/edit_account/${account.id}");
                                    },
                                    child: AccountListItem(
                                      icon: getIconDataByName(account.icon),
                                      name: account.name,
                                      balance: 'S/.${account.balance}',
                                      color: Color(
                                        int.parse(account.color
                                            .replaceFirst('#', '0xFF')),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                ],
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          context.go('/accounts/new_account');
        },
      ),
    );
  }
}

class AccountListItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final String balance;
  final Color color;

  const AccountListItem({
    Key? key,
    required this.icon,
    required this.name,
    required this.balance,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(name),
      trailing: Text(
        balance,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
