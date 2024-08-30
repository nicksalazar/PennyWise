import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pennywise/models/account_model.dart';
import 'package:pennywise/providers/account_provider.dart';
import 'package:pennywise/providers/category_provider.dart';
import 'package:pennywise/themes/app_theme.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.accountId == null ? 'Add Account' : 'Edit Account'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceField(),
              SizedBox(height: 20),
              _buildAccountNameField(),
              SizedBox(height: 20),
              _buildIconSelector(),
              SizedBox(height: 16),
              _buildColorSelector(),
              SizedBox(height: 20),
              _buildCurrencySelector(),
              SizedBox(height: 20),
              _buildIncludeInTotalSwitch(),
              SizedBox(height: 40),
              if (widget.accountId != null) _buildDeleteButton(),
              SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceField() {
    return TextFormField(
      controller: balanceController,
      decoration: InputDecoration(
        labelText: 'Initial Balance',
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

  Widget _buildAccountNameField() {
    return TextFormField(
      controller: accountNameController,
      decoration: InputDecoration(
        labelText: 'Account Name',
        hintText: 'Enter account name',
        prefixIcon: Icon(Icons.account_circle),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an account name';
        }
        return null;
      },
    );
  }

  Widget _buildIconSelector() {
    final categories = categorizedIcons.entries
        .map((e) => e.value)
        .expand((element) => element)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Icon', style: Theme.of(context).textTheme.titleLarge),
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

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Color', style: Theme.of(context).textTheme.titleLarge),
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

  Widget _buildCurrencySelector() {
    return DropdownButtonFormField<String>(
      value: selectedCurrency,
      decoration: InputDecoration(
        labelText: 'Select Currency',
        prefixIcon: Icon(Icons.monetization_on),
      ),
      onChanged: (String? newValue) {
        setState(() => selectedCurrency = newValue!);
      },
      items: <String>['PEN', 'USD', 'EUR', 'GBP']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildIncludeInTotalSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Include in Total Balance', style: TextStyle(fontSize: 16)),
        Switch(
          value: includeInTotal,
          onChanged: (value) => setState(() => includeInTotal = value),
          activeColor: AppTheme.folly,
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.delete),
      label: Text('Delete Account'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      onPressed: () => _showDeleteConfirmationDialog(),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account'),
          content: Text('Are you sure you want to delete this account?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
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

  Widget _buildSubmitButton() {
    return ElevatedButton(
      child: Text(widget.accountId == null ? 'Add Account' : 'Update Account'),
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
