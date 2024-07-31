import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:habit_harmony/models/account_model.dart';
import 'package:habit_harmony/models/transfer_model.dart';
import 'package:habit_harmony/providers/transfer_provider.dart';
import 'package:provider/provider.dart';

class TransferAccountWidget extends StatefulWidget {
  final List<Account> accounts;
  TransferAccountWidget({required this.accounts});
  @override
  _TransferAccountWidgetState createState() => _TransferAccountWidgetState();
}

class _TransferAccountWidgetState extends State<TransferAccountWidget> {
  final _formKey = GlobalKey<FormState>();
  String? _sourceAccount;
  String? _destinationAccount;
  double _amount = 0.0;
  DateTime _selectedDate = DateTime.now();
  String? _comment;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        TransferModel transfer = TransferModel(
          id: '',
          sourceAccountId: _sourceAccount!,
          destinationAccountId: _destinationAccount!,
          amount: _amount,
          date: _selectedDate,
          comment: _comment!,
          type: 'transfer',
        );

        await Provider.of<TransferProvider>(context, listen: false)
            .addTransfer(transfer);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transfer successful'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transfer failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Source Account'),
                      items: widget.accounts
                          .map((account) => DropdownMenuItem(
                                value: account.id,
                                child: Text(account.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _sourceAccount = value;
                        });
                      },
                      validator: (value) => value == null
                          ? 'Please select a source account'
                          : null,
                    ),
                    DropdownButtonFormField<String>(
                      decoration:
                          InputDecoration(labelText: 'Destination Account'),
                      items: widget.accounts
                          .map((account) => DropdownMenuItem(
                                value: account.id,
                                child: Text(account.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _destinationAccount = value;
                        });
                      },
                      validator: (value) => value == null
                          ? 'Please select a destination account'
                          : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.number,
                      initialValue: '0',
                      onChanged: (value) {
                        setState(() {
                          _amount = double.tryParse(value) ?? 0.0;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter an amount'
                          : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Date'),
                      readOnly: true,
                      controller: TextEditingController(
                          text: "${_selectedDate.toLocal()}".split(' ')[0]),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != _selectedDate)
                          setState(() {
                            _selectedDate = picked;
                          });
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select a date'
                          : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Comment'),
                      onChanged: (value) {
                        setState(() {
                          _comment = value;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a comment'
                          : null,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _submit();
                      },
                      child: Text('Transfer'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
