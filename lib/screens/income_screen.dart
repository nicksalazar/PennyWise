import 'package:flutter/material.dart';
import 'package:habit_harmony/providers/Income_provider.dart';
import 'package:habit_harmony/widgets/expense_add_form.dart';
import 'package:habit_harmony/widgets/income_graphic.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({Key? key}) : super(key: key);

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<IncomeProvider>(context, listen: false).fetchIncomes();
      Provider.of<IncomeProvider>(context, listen: false).fetchAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Use fetchItems from ItemProvider to refresh items
          await Provider.of<IncomeProvider>(context, listen: false)
              .fetchIncomes();
        },
        child:
            Consumer<IncomeProvider>(builder: (context, itemProvider, child) {
          final items = itemProvider.incomes;
          final categories = itemProvider.categories;
          final accounts = itemProvider.accounts;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No hay entradas registradas',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Aquí puedes agregar la lógica para añadir un nuevo ingreso
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddBudgetForm(
                            initialCategory: "income",
                          );
                        },
                      );
                    },
                    child: Text('Añadir ingreso'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
              itemCount: items.length + 1,
              itemBuilder: (context, index) {
                if (index == 0)
                  return IncomeGraphicWidget(
                    incomes: items,
                    categories: categories,
                  );
                final item = items[index - 1];

                return Dismissible(
                  key: Key(item.id),
                  background: Container(
                    color: Colors.amberAccent,
                    alignment: Alignment.centerRight,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    // Temporarily store the dismissed item and its index
                    final dismissedItem = item;
                    final itemProvider =
                        Provider.of<IncomeProvider>(context, listen: false);
                    itemProvider.deleteIncome(dismissedItem.id);

                    // Show a snackbar with an Undo action
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${dismissedItem.description} dismissed'),
                        action: SnackBarAction(
                          label: 'Deshacer',
                          onPressed: () {
                            // Restore the dismissed item
                            itemProvider.addIncome(dismissedItem);
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 6.0,
                          )
                        ]),
                    child: ListTile(
                      title: Text(item.description),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              DateFormat('dd/MM/yyyy HH:mm').format(item.date)),
                          Wrap(
                            spacing: 8.0, // Gap between adjacent chips.
                            runSpacing: 4.0, // Gap between lines.
                            children: [
                              Chip(
                                label: Text(
                                  accounts
                                      .firstWhere((element) =>
                                          element.id == item.accountId)
                                      .name,
                                ),
                                backgroundColor: Colors.lightBlue.shade100,
                              )
                            ],
                          )
                        ],
                      ),
                      trailing: Text("-\S/. ${item.amount.toStringAsFixed(2)}"),
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirmar"),
                          content: const Text(
                              "¿Estás seguro de que deseas eliminar este elemento?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Eliminar"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Cancelar"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              });
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddBudgetForm(
                initialCategory: "income",
              );
            },
          );
        },
        backgroundColor: Colors.deepPurple, // Customize color
        elevation: 5.0, // Customize shadow
        tooltip: 'Add Budget',
        child: const Icon(
          Icons.add,
          size: 24,
          color: Colors.white,
        ), // Adjust icon size as needed
      ),
    );
  }
}
