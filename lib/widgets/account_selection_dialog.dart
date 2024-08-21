import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pennywise/providers/account_provider.dart';

class AccountSelectionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        return AlertDialog(
          title: Text('Select account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('Hide balance from Home Screen'),
                value: accountProvider.hideBalance,
                onChanged: (bool value) {
                  accountProvider.setHideBalance(value);
                },
              ),
              ...accountProvider.accounts
                  .map((account) => RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 10),
                            Text(account.name),
                          ],
                        ),
                        subtitle:
                            Text('S/.${account.balance.toStringAsFixed(2)}'),
                        value: account.id,
                        groupValue: accountProvider.selectedAccountId,
                        onChanged: (String? value) {
                          if (value != null) {
                            accountProvider.setSelectedAccountId(value);
                            Navigator.of(context).pop(); // Close the dialog
                          }
                        },
                      ))
                  .toList(),
            ],
          ),
          actions: [
            TextButton(
              child: Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('SELECT'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
