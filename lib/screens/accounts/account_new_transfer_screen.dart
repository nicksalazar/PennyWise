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
        title: Text('Create transfer'),
      ),
      body: Consumer2<AccountProvider, TransferProvider>(
          builder: (context, accountProvider, transferProvider, child) {
        final accounts = accountProvider.accounts;
        final filteredToAccounts = accounts
            .where((account) => account.id != fromAccount)
            .where((account) => account.id != 'total')
            .toList();
        final filteredFromAccounts = accounts
            .where((account) => account.id != toAccount)
            .where((account) => account.id != 'total')
            .toList();
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  decoration:
                      InputDecoration(labelText: 'Transfer from account'),
                  value: fromAccount,
                  onChanged: (String? newValue) {
                    setState(() {
                      fromAccount = newValue;
                      if (toAccount == newValue) {
                        toAccount = null;
                      }
                    });
                  },
                  items: filteredFromAccounts
                      .map<DropdownMenuItem<String>>((account) {
                    return DropdownMenuItem<String>(
                      value: account.id,
                      child: Text(account.name),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Transfer to account'),
                  value: toAccount,
                  onChanged: (String? newValue) {
                    setState(() {
                      toAccount = newValue;
                      if (fromAccount == newValue) {
                        fromAccount = null;
                      }
                    });
                  },
                  items: filteredToAccounts
                      .map<DropdownMenuItem<String>>((account) {
                    return DropdownMenuItem<String>(
                      value: account.id,
                      child: Text(account.name),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Transfer amount',
                    suffixText: 'PEN',
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
                SizedBox(height: 16),
                ListTile(
                  title: Text(
                      "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    print("selected date: $selectedDate");
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2025),
                    );
                    if (picked != null && picked != selectedDate)
                      setState(() {
                        selectedDate = picked;
                      });
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: commentController,
                  decoration: InputDecoration(labelText: 'Comment'),
                  maxLines: 3,
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    child: Text('Add transfer'),
                    onPressed: () {
                      // Process the transfer
                      if (_formKey.currentState!.validate()) {
                        final accountProvider = Provider.of<AccountProvider>(
                          context,
                          listen: false,
                        );
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
                          if (error is StateError &&
                              error.message ==
                                  'No cuentas con saldo suficiente para realizar la transferencia') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  error.message,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  error.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }
                          // Re-throw the error with stack trace
                          throw AsyncError(error, stackTrace);
                        });
                      } else {
                        print("Form is invalid");
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
