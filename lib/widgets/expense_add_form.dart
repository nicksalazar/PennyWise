import 'package:nick_ai/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:nick_ai/models/metodo_pago_model.dart';
import 'package:nick_ai/providers/expense_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

class AddBudgetForm extends StatefulWidget {
  @override
  _AddBudgetFormState createState() => _AddBudgetFormState();
}

class _AddBudgetFormState extends State<AddBudgetForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  // Definir las opciones de categoría y método de pago
  DateTime _selectedDateTime = DateTime.now();
  List<Category> _categorias = [];
  List<PaymentMethod> _paymentMethods = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).fetchCategories();
      Provider.of<ExpenseProvider>(context, listen: false)
          .fetchPaymentMethods();
    });
  }

  String? _categorySelect = 'f7RnY1x838HG9ER7bR1H';
  String? _paymentMethodSelect = 'zsN4LxkRuuZPczwEvhHW';

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      //get category name
      final category = _categorias.firstWhere(
        (element) => element.id == _categorySelect,
        orElse: () => Category(id: '', name: '', color: ''),
      );

      final metodoPago = _paymentMethods.firstWhere(
        (element) => element.id == _paymentMethodSelect,
        orElse: () => PaymentMethod(id: '', name: '', color: ''),
      );
      // Assuming you have a method to add a budget item
      final newItem = Expense(
        id: '',
        description: _titleController.text,
        date: _selectedDateTime,
        categoryId: category.id,
        amount: double.parse(_amountController.text),
        paymentMethodId: metodoPago.id,
      );

      // Use Provider to add the new budget item
      Provider.of<ExpenseProvider>(context, listen: false).addExpense(newItem);

      // Reset the form and controllers
      _formKey.currentState!.reset();
      _titleController.clear();
      _amountController.clear();

      // Optionally close the dialog or navigate away
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    _categorias = provider.categories;
    _paymentMethods = provider.paymentMethods;

    return AlertDialog(
      title: const Text("Agregar"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Porfavor entra la descripción';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Porfavor entra el monto';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Porfavor ingresa un monto valido';
                  }
                  return null;
                },
              ),
              ListTile(
                title: Text('Fecha y Hora'),
                subtitle: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime)),
                trailing: Icon(Icons.calendar_today),
                
                onTap: () => _selectDateTime(context),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButtonFormField(
                    value: _categorySelect,
                    items: _categorias.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _categorySelect = newValue;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Categoría'),
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButtonFormField(
                    value: _paymentMethodSelect,
                    items: _paymentMethods.map((paymentMethod) {
                      return DropdownMenuItem(
                        value: paymentMethod.id,
                        child: Text(paymentMethod.name),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _paymentMethodSelect = newValue;
                      });
                    },
                    decoration:
                        const InputDecoration(labelText: 'Método de Pago'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Close dialog
          child: Text('Close'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text('Add Budget'),
        ),
      ],
    );
  }
}
