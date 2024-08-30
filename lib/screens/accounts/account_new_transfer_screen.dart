import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pennywise/models/transfer_model.dart';
import 'package:pennywise/providers/account_provider.dart';
import 'package:pennywise/providers/transfer_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateTransferScreen extends StatefulWidget {
  @override
  _CreateTransferScreenState createState() => _CreateTransferScreenState();
}

class _CreateTransferScreenState extends State<CreateTransferScreen> {
  String? fromAccount;
  String? toAccount;
  TextEditingController amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TextEditingController commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Transfer'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
      ),
      body: Consumer2<AccountProvider, TransferProvider>(
        builder: (context, accountProvider, transferProvider, child) {
          final accounts = accountProvider.accounts
              .where((account) => account.id != 'total')
              .toList();
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAccountSelector(
                    accounts,
                    'From Account',
                    fromAccount,
                    (newValue) => setState(() {
                      fromAccount = newValue;
                      if (toAccount == newValue) toAccount = null;
                    }),
                    Icons.account_balance,
                  ),
                  SizedBox(height: 16),
                  _buildAccountSelector(
                    accounts,
                    'To Account',
                    toAccount,
                    (newValue) => setState(() {
                      toAccount = newValue;
                      if (fromAccount == newValue) fromAccount = null;
                    }),
                    Icons.account_balance_wallet,
                  ),
                  SizedBox(height: 16),
                  _buildAmountField(),
                  SizedBox(height: 16),
                  _buildDatePicker(),
                  SizedBox(height: 16),
                  _buildCommentField(),
                  SizedBox(height: 24),
                  _buildSubmitButton(
                      context, accountProvider, transferProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountSelector(List<dynamic> accounts, String label,
      String? value, Function(String?) onChanged, IconData icon) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
      value: value,
      onChanged: onChanged,
      items: accounts.map<DropdownMenuItem<String>>((account) {
        return DropdownMenuItem<String>(
          value: account.id,
          child: Text(account.name),
        );
      }).toList(),
      validator: (value) => value == null ? 'Please select an account' : null,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: amountController,
      decoration: InputDecoration(
        labelText: 'Transfer Amount',
        prefixIcon: Icon(Icons.attach_money),
        suffixText: 'PEN',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Transfer Date',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget _buildCommentField() {
    return TextFormField(
      controller: commentController,
      decoration: InputDecoration(
        labelText: 'Comment',
        prefixIcon: Icon(Icons.comment),
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildSubmitButton(BuildContext context,
      AccountProvider accountProvider, TransferProvider transferProvider) {
    return ElevatedButton(
      child: Text('Add Transfer'),
      onPressed: () =>
          _submitTransfer(context, accountProvider, transferProvider),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
      ),
    );
  }

  void _submitTransfer(BuildContext context, AccountProvider accountProvider,
      TransferProvider transferProvider) {
    if (_formKey.currentState!.validate()) {
      transferProvider
          .addTransfer(
        TransferModel(
          id: '',
          sourceAccountId: fromAccount!,
          destinationAccountId: toAccount!,
          amount: double.parse(amountController.text),
          date: selectedDate,
          comment: commentController.text,
          type: 'transfer',
        ),
        accountProvider,
      )
          .then((_) {
        Navigator.pop(context);
      }).catchError((error, stackTrace) {
        _showErrorSnackBar(context, error);
        throw AsyncError(error, stackTrace);
      });
    }
  }

  void _showErrorSnackBar(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          error is StateError
              ? error.message
              : 'An error occurred while processing the transfer',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
