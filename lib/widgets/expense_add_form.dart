import 'package:habit_harmony/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:habit_harmony/models/income_model.dart';
import 'package:habit_harmony/models/payment_method_model.dart';
import 'package:habit_harmony/models/reception_method_model.dart';
import 'package:habit_harmony/providers/Income_provider.dart';
import 'package:habit_harmony/providers/expense_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

class AddBudgetForm extends StatefulWidget {
  final String initialCategory;

  AddBudgetForm({Key? key, required this.initialCategory}) : super(key: key);
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
  List<ReceptionMethod> _receptionMethods = [];
  String? _categorySelect;
  String? _paymentMethodSelect;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (widget.initialCategory == "income") {
        await Provider.of<IncomeProvider>(context, listen: false)
            .fetchCategories();
        await Provider.of<IncomeProvider>(context, listen: false)
            .fetchReceptionMethods();
        _categorias =
            Provider.of<IncomeProvider>(context, listen: false).categories;
        _receptionMethods = Provider.of<IncomeProvider>(context, listen: false)
            .receptionMethods;
        if (_categorias.isNotEmpty) {
          _categorySelect = _categorias.first.id;
        }
        if (_receptionMethods.isNotEmpty) {
          _paymentMethodSelect = _receptionMethods.first.id;
        }
      } else {
        await Provider.of<ExpenseProvider>(context, listen: false)
            .fetchCategories();
        await Provider.of<ExpenseProvider>(context, listen: false)
            .fetchPaymentMethods();
        _categorias =
            Provider.of<ExpenseProvider>(context, listen: false).categories;
        _paymentMethods =
            Provider.of<ExpenseProvider>(context, listen: false).paymentMethods;
        if (_categorias.isNotEmpty) {
          _categorySelect = _categorias.first.id;
        }
        if (_paymentMethods.isNotEmpty) {
          _paymentMethodSelect = _paymentMethods.first.id;
        }
      }
      setState(() {});
    });
  }

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
        orElse: () => (Category(id: '', name: '', color: '', type: '')),
      );
      final metodoPago;
      if (widget.initialCategory == "income") {
        metodoPago = _receptionMethods.firstWhere(
            (element) => element.id == _paymentMethodSelect,
            orElse: () => ReceptionMethod(id: '', name: '', color: ''));

        final newItem = Income(
          id: '',
          description: _titleController.text,
          date: _selectedDateTime,
          categoryId: category.id,
          amount: double.parse(_amountController.text),
          receptionMethod: metodoPago.id,
        );

        // Use Provider to add the new budget item
        Provider.of<IncomeProvider>(context, listen: false).addIncome(newItem);
      } else {
        metodoPago = _paymentMethods.firstWhere(
          (element) => element.id == _paymentMethodSelect,
          orElse: () => PaymentMethod(id: '', name: '', color: ''),
        );

        final newItem = Expense(
          id: '',
          description: _titleController.text,
          date: _selectedDateTime,
          categoryId: category.id,
          amount: double.parse(_amountController.text),
          paymentMethodId: metodoPago.id,
        );

        // Use Provider to add the new budget item
        Provider.of<ExpenseProvider>(context, listen: false)
            .addExpense(newItem);
      }

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
    final provider;
    if (widget.initialCategory != "income") {
      provider = Provider.of<ExpenseProvider>(context);
      _paymentMethods = provider.paymentMethods;
    } else {
      provider = Provider.of<IncomeProvider>(context);
      _receptionMethods = provider.receptionMethods;
    }
    _categorias = provider.categories;

    return AlertDialog(
      title: Text("Agregar ${widget.initialCategory}"),
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
                    items: widget.initialCategory != "income"
                        ? _paymentMethods.map((paymentMethod) {
                            return DropdownMenuItem(
                              value: paymentMethod.id,
                              child: Text(paymentMethod.name),
                            );
                          }).toList()
                        : _receptionMethods.map((receptionMethod) {
                            return DropdownMenuItem(
                              value: receptionMethod.id,
                              child: Text(receptionMethod.name),
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
