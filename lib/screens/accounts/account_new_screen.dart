import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pennywise/data/currency_data.dart';
import 'package:pennywise/models/account_model.dart';
import 'package:pennywise/providers/account_provider.dart';
import 'package:pennywise/providers/category_provider.dart';
import 'package:pennywise/providers/language_provider.dart';
import 'package:pennywise/themes/app_theme.dart';
import 'package:pennywise/utils/icon_utils.dart';
import 'package:pennywise/widgets/color_selector_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddAccountScreen extends StatefulWidget {
  final String? accountId;

  AddAccountScreen({this.accountId});

  @override
  _AddAccountScreenState createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  String selectedIcon = '';
  Color selectedColor = AppTheme.folly;
  String selectedCurrency = 'PEN';
  bool includeInTotal = true;
  TextEditingController accountNameController = TextEditingController();
  TextEditingController balanceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<Color> colors = [
    AppTheme.folly,
    AppTheme.accentBlue,
    AppTheme.successGreen,
    AppTheme.warningYellow,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(context, listen: false).fetchAccounts();
      Provider.of<CategoryProvider>(context, listen: false);
      //  Provider.of<LanguageProvider>(context, listen: false);
      selectedCurrency = Provider.of<LanguageProvider>(context, listen: false)
          .selectedCurrency;
      if (widget.accountId != null) {
        _loadAccountData();
      }
    });
  }

  void _loadAccountData() {
    final account = Provider.of<AccountProvider>(context, listen: false)
        .getAccountById(widget.accountId!);
    setState(() {
      accountNameController.text = account.name;
      balanceController.text = account.balance.toString();
      selectedIcon = account.icon;
      selectedColor = Color(int.parse(account.color.replaceFirst('#', '0xFF')));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.accountId == null ? l10n.addAccount : l10n.editAccount),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: l10n.back,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceField(l10n),
              SizedBox(height: 20),
              _buildAccountNameField(l10n),
              SizedBox(height: 20),
              _buildIconSelector(l10n),
              SizedBox(height: 16),
              _buildColorSelector(l10n),
              SizedBox(height: 20),
              _buildCurrencySelector(l10n),
              SizedBox(height: 20),
              _buildIncludeInTotalSwitch(l10n),
              SizedBox(height: 40),
              if (widget.accountId != null) _buildDeleteButton(l10n),
              SizedBox(height: 20),
              _buildSubmitButton(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceField(AppLocalizations l10n) {
    return TextFormField(
      controller: balanceController,
      decoration: InputDecoration(
        labelText: l10n.initialBalanceTitle,
        suffixText: selectedCurrency,
        prefixIcon: Icon(Icons.account_balance_wallet),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the initial balance';
        }
        return null;
      },
    );
  }

  Widget _buildAccountNameField(AppLocalizations l10n) {
    return TextFormField(
      controller: accountNameController,
      decoration: InputDecoration(
        labelText: l10n.accountNameInput,
        hintText: l10n.accounthintText,
        prefixIcon: Icon(Icons.account_circle),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.accountNameValidationEmpty;
        }
        return null;
      },
    );
  }

  Widget _buildIconSelector(AppLocalizations l10n) {
    final categories = categorizedIcons.entries
        .map((e) => e.value)
        .expand((element) => element)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.selectIcon, style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            childAspectRatio: 1,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: (categories.length * 0.08).ceil() + 1,
          itemBuilder: (context, index) {
            if (index == (categories.length * 0.08).ceil()) {
              return _buildMoreIconsButton();
            }
            return _buildIconItem(categories[index]);
          },
        ),
      ],
    );
  }

  Widget _buildIconItem(String iconName) {
    final iconData = getIconDataByName(iconName);
    return Tooltip(
      message: iconName,
      child: InkWell(
        onTap: () => setState(() => selectedIcon = iconName),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selectedIcon == iconName ? selectedColor : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            iconData,
            color: selectedIcon == iconName ? Colors.white : Colors.black,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildMoreIconsButton() {
    return InkWell(
      onTap: () async {
        final result = await context.push('/categories/icon_catalog');
        if (result != null && result is String) {
          setState(() => selectedIcon = result);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.more_horiz, size: 30),
      ),
    );
  }

  Widget _buildColorSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.selectColor, style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: colors.map((color) => _buildColorItem(color)).toList()
            ..add(_buildCustomColorButton()),
        ),
      ],
    );
  }

  Widget _buildColorItem(Color color) {
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 40,
        height: 40,
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
  }

  Widget _buildCustomColorButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ColorSelector(
              onColorSelected: (color) => setState(() => selectedColor = color),
            ),
          ),
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey),
        ),
        child: Icon(Icons.add, size: 20),
      ),
    );
  }

  Widget _buildCurrencySelector(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      value: selectedCurrency,
      decoration: InputDecoration(
        labelText: l10n
            .selectCurrency, // Assuming you have this key in your localization files
        prefixIcon: Icon(Icons.monetization_on),
      ),
      onChanged: (String? newValue) {
        setState(() => selectedCurrency = newValue!);
      },
      items: currencies.map<DropdownMenuItem<String>>((currency) {
        return DropdownMenuItem<String>(
          value: currency['code'],
          child: Text(
            '${currency['name'][l10n.localeName]} (${currency['symbol']})',
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIncludeInTotalSwitch(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l10n.includeInTotalBalance, style: TextStyle(fontSize: 16)),
        Switch(
          value: includeInTotal,
          onChanged: (value) => setState(() => includeInTotal = value),
          activeColor: AppTheme.folly,
        ),
      ],
    );
  }

  Widget _buildDeleteButton(AppLocalizations l10n) {
    return ElevatedButton.icon(
      icon: Icon(Icons.delete),
      label: Text(l10n.deleteAccount),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      onPressed: () => _showDeleteConfirmationDialog(l10n),
    );
  }

  void _showDeleteConfirmationDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteAccount),
          content: Text(l10n.deleteAccountPrompt),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(l10n.delete),
              onPressed: () {
                Provider.of<AccountProvider>(context, listen: false)
                    .deleteAccount(widget.accountId!);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return ElevatedButton(
      child: Text(
        widget.accountId == null ? l10n.createAccount : l10n.updateAccount,
      ),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _submitForm(widget.accountId != null);
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }

  Future<void> _submitForm(bool isEdit) async {
    try {
      String hexColor =
          '#${selectedColor.value.toRadixString(16).substring(2)}';
      Account account = Account(
        id: widget.accountId ?? "",
        name: accountNameController.text,
        icon: selectedIcon,
        balance: double.parse(balanceController.text),
        color: hexColor,
      );

      if (isEdit) {
        await Provider.of<AccountProvider>(context, listen: false)
            .editAccount(account);
      } else {
        await Provider.of<AccountProvider>(context, listen: false)
            .addAccount(account);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error ${isEdit ? 'updating' : 'adding'} account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
