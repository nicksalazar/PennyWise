import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create transfer'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Transfer from account'),
                value: fromAccount,
                onChanged: (String? newValue) {
                  setState(() {
                    fromAccount = newValue;
                  });
                },
                items: <String>['Efectivo', 'Yape', 'BBVA']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
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
                  });
                },
                items: <String>['Efectivo', 'Yape', 'BBVA']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
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
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text("Date: ${selectedDate.toLocal()}".split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
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
                  child: Text('Add'),
                  onPressed: () {
                    // Process the transfer
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
