import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pennywise/models/account_model.dart';
import 'package:pennywise/providers/account_provider.dart';
import 'package:intl/intl.dart';
import 'package:pennywise/themes/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:pennywise/providers/transfer_provider.dart';
import 'package:pennywise/models/transfer_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TransferHistoryScreen extends StatefulWidget {
  @override
  _TransferHistoryScreenState createState() => _TransferHistoryScreenState();
}

class _TransferHistoryScreenState extends State<TransferHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _tabs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransferProvider>(context, listen: false).getTodayTransfers();
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      final transferProvider =
          Provider.of<TransferProvider>(context, listen: false);
      DateTime now = DateTime.now();
      DateTime startDate, endDate;

      switch (_tabController.index) {
        case 0: // Day
          startDate = DateTime(now.year, now.month, now.day);
          endDate = startDate
              .add(Duration(days: 1))
              .subtract(Duration(microseconds: 1));
          break;
        case 1: // Week
          startDate = now.subtract(Duration(days: 7));
          endDate = now;
          break;
        case 2: // Month
          startDate = DateTime(now.year, now.month, 1);
          endDate = now;
          break;
        case 3: // Year
          startDate = DateTime(now.year, 1, 1);
          endDate = now;
          break;
        case 4: // Period
          _showDateRangePicker();
          return;
        default:
          return;
      }

      transferProvider.updateDateRange(startDate, endDate);
    }
  }

  void _showDateRangePicker() async {
    final transferProvider =
        Provider.of<TransferProvider>(context, listen: false);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: transferProvider.startDate,
        end: transferProvider.endDate,
      ),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkMode
                ? ColorScheme.dark(
                    primary: AppTheme.folly,
                    onPrimary: AppTheme.antiqueWhite,
                    surface: AppTheme.raisinBlack,
                    onSurface: AppTheme.antiqueWhite,
                  )
                : ColorScheme.light(
                    primary: AppTheme.folly,
                    onPrimary: Colors.white,
                    surface: AppTheme.antiqueWhite,
                    onSurface: AppTheme.raisinBlack,
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    isDarkMode ? AppTheme.antiqueWhite : AppTheme.folly,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      transferProvider.updateDateRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : AppTheme.raisinBlack;
    final cardColor = isDarkMode ? Color(0xFF2C2C2C) : Colors.white;
    final l10n = AppLocalizations.of(context)!;

    _tabs = [
      l10n.dayTab,
      l10n.weekTab,
      l10n.monthTab,
      l10n.yearTab,
      l10n.periodTab,
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.transferHistoryTitle, style: TextStyle(color: textColor)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((String name) => Tab(text: name)).toList(),
          labelColor: AppTheme.folly,
          unselectedLabelColor: isDarkMode ? Colors.white60 : Colors.grey,
          indicatorColor: AppTheme.folly,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<AccountProvider>(
                builder: (context, accountProvider, child) {
                  return Consumer<TransferProvider>(
                    builder: (context, transferProvider, child) {
                      if (transferProvider.transfers.isEmpty) {
                        return Center(
                          child: Text(
                            l10n.noTransfersFound,
                            style: TextStyle(color: textColor, fontSize: 18),
                          ),
                        );
                      }

                      final groupedTransfers =
                          _groupTransfersByDate(transferProvider.transfers);
                      final accounts = accountProvider.accounts;

                      return ListView.builder(
                        itemCount: groupedTransfers.length,
                        itemBuilder: (context, index) {
                          final date = groupedTransfers.keys.elementAt(index);
                          final dateTransfers = groupedTransfers[date]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  DateFormat('MMMM d, y', Localizations.localeOf(context).languageCode).format(date),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ...dateTransfers.map((transfer) =>
                                  _buildTransferTile(transfer, accounts,
                                      isDarkMode, cardColor, textColor, l10n)),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  context.go('/accounts/new_transfer');
                },
                child: Text(l10n.newTransferButton),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: AppTheme.folly,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferTile(TransferModel transfer, List<Account> accounts,
      bool isDarkMode, Color cardColor, Color textColor, AppLocalizations l10n) {
    final sourceAccount = accounts.firstWhere(
      (account) => account.id == transfer.sourceAccountId,
      orElse: () => Account(id: "", name: "", icon: "", balance: 0, color: ""),
    );

    final destinationAccount = accounts.firstWhere(
      (account) => account.id == transfer.destinationAccountId,
      orElse: () => Account(id: "", name: "", icon: "", balance: 0, color: ""),
    );

    String title;
    String subtitle;

    switch (transfer.type) {
      case "deposit":
        title = l10n.depositTitle;
        subtitle = l10n.depositSubtitle(destinationAccount.name);
        break;
      case "adjustment":
        title = l10n.adjustmentTitle;
        subtitle = l10n.adjustmentSubtitle(sourceAccount.name);
        break;
      case "transfer":
        title = l10n.transferTitle;
        subtitle = l10n.transferSubtitle(sourceAccount.name, destinationAccount.name);
        break;
      case "initial":
        title = l10n.initialBalanceTitle;
        subtitle = l10n.initialBalanceSubtitle(destinationAccount.name);
        break;
      default:
        title = l10n.unknownTransferType;
        subtitle = '';
    }

    return Card(
      color: cardColor,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          Icons.account_balance_wallet,
          color: AppTheme.folly,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        trailing: Text(
          NumberFormat.currency(
            symbol: '\$',
            decimalDigits: 2,
            locale: Localizations.localeOf(context).toString(),
          ).format(transfer.amount),
          style: TextStyle(
            color: transfer.amount > 0 ? AppTheme.successGreen : AppTheme.folly,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Map<DateTime, List<TransferModel>> _groupTransfersByDate(
      List<TransferModel> transfers) {
    final groupedTransfers = <DateTime, List<TransferModel>>{};
    for (var transfer in transfers) {
      final date =
          DateTime(transfer.date.year, transfer.date.month, transfer.date.day);
      if (!groupedTransfers.containsKey(date)) {
        groupedTransfers[date] = [];
      }
      groupedTransfers[date]!.add(transfer);
    }
    return groupedTransfers;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}