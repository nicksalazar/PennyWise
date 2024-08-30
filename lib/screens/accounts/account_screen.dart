import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pennywise/models/account_model.dart';
import 'package:pennywise/providers/account_provider.dart';
import 'package:pennywise/themes/app_theme.dart';
import 'package:pennywise/utils/icon_utils.dart';
import 'package:pennywise/widgets/my_drawer.dart';
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
    final theme = Theme.of(context);
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text('Accounts'),
      ),
      body: Consumer<AccountProvider>(
        builder: (context, accountProvider, child) {
          List<Account> accounts = accountProvider.accounts;
          if (accounts.isNotEmpty) {
            accounts.removeAt(0);
          }
          return RefreshIndicator(
            onRefresh: () => accountProvider.fetchAccounts(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildTotalBalance(accounts, theme),
                ),
                SliverToBoxAdapter(
                  child: _buildActionButtons(context, theme),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (accounts.isEmpty) {
                        return Center(
                          child: Text(
                            'No accounts found',
                            style: theme.textTheme.titleMedium,
                          ),
                        );
                      }
                      return _buildAccountItem(accounts[index], context, theme);
                    },
                    childCount: accounts.isEmpty ? 1 : accounts.length,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => context.go('/accounts/new_account'),
        backgroundColor: AppTheme.folly,
      ),
    );
  }

  Widget _buildTotalBalance(List<Account> accounts, ThemeData theme) {
    final totalBalance =
        accounts.fold(0.0, (prev, account) => prev + account.balance);
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Total Balance', style: theme.textTheme.titleMedium),
            SizedBox(height: 8),
            Text(
              'S/. ${totalBalance.toStringAsFixed(2)}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.folly,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.history),
              label: Text('Transfer History'),
              onPressed: () => context.go("/accounts/transfer_history"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.swap_horiz),
              label: Text('New Transfer'),
              onPressed: () => context.go("/accounts/new_transfer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountItem(
      Account account, BuildContext context, ThemeData theme) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Color(int.parse(account.color.replaceFirst('#', '0xFF'))),
          child: Icon(getIconDataByName(account.icon), color: Colors.white),
        ),
        title: Text(account.name, style: theme.textTheme.titleMedium),
        subtitle: Text('Balance',
            style:
                theme.textTheme.bodySmall), // Cambiado de caption a bodySmall
        trailing: Text(
          'S/.${account.balance.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.folly,
          ),
        ),
        onTap: () => context.go("/accounts/edit_account/${account.id}"),
      ),
    );
  }
}
