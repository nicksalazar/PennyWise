import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:habit_harmony/models/hydration_model.dart';
import 'package:habit_harmony/providers/hydration_provider.dart';
import 'package:provider/provider.dart';

class HydrationScreen extends StatefulWidget {
  const HydrationScreen({Key? key}) : super(key: key);

  @override
  _HydrationScreenState createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => {
        Provider.of<HydrationProvider>(context, listen: false)
            .fetchDrinkEntries(),
        Provider.of<HydrationProvider>(context, listen: false)
            .fetchDrinkEntriesByRange(
          DateTime.now().subtract(Duration(days: 7)),
          DateTime.now(),
        ),
      },
    );
    //fetch drink by range
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<HydrationProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi Nick',
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Vamos a Hidratarnos',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 24),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total consumido',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Editar Meta >',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${provider.totalWaterConsumed.toStringAsFixed(0)}/${provider.dailyGoal} ml',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: provider.totalWaterConsumed /
                                  provider.dailyGoal,
                              backgroundColor: Colors.blue[100],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${(provider.dailyGoal - provider.totalWaterConsumed).toStringAsFixed(0)} ml left to complete your goal.',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'This week details',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    WeeklyProgressList(),
                    SizedBox(
                      height: 24,
                    ),
                    Row(
                      children: [
                        //day now here after recent drinks
                        Text(
                          'Recent Drinks (' +
                              DateFormat('E').format(DateTime.now()) +
                              ")",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        Text(
                          'See all >',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    RecentDrinksGrid(drinks: provider.drinks),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDrinkDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showAddDrinkDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return AddDrinkForm();
      },
    );
  }
}

class WeeklyProgressList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // here fetch by range
    final provider = Provider.of<HydrationProvider>(context);
    final weeklyDrinks = provider.drinks_per_week;
    final weeklyTotal =
        weeklyDrinks.fold(0, (sum, drink) => sum + drink.amount);
    final weeklyGoal = provider.dailyGoal * 7;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total: $weeklyTotal ml'),
            Text('Goal: $weeklyGoal ml'),
          ],
        ),
        SizedBox(height: 16),
        ...List.generate(
          7,
          (index) {
            final day = DateTime.now().subtract(Duration(days: 6 - index));
            final dayDrinks = weeklyDrinks
                .where((drink) =>
                    drink.date.day == day.day &&
                    drink.date.month == day.month &&
                    drink.date.year == day.year)
                .toList();
            final dayTotal =
                dayDrinks.fold(0, (sum, drink) => sum + drink.amount);
            return WeeklyProgressItem(
              day: DateFormat('E').format(day),
              amount: dayTotal,
              goal: 2000,
            );
          },
        ),
      ],
    );
  }
}

class WeeklyProgressItem extends StatelessWidget {
  final String day;
  final int amount;
  final int goal;

  const WeeklyProgressItem({
    Key? key,
    required this.day,
    required this.amount,
    required this.goal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day, style: TextStyle(color: Colors.grey[600])),
          SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: amount / goal,
                  backgroundColor: Colors.blue[100],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              SizedBox(width: 8),
              Text('$amount/$goal ml'),
            ],
          ),
        ],
      ),
    );
  }
}

class RecentDrinksGrid extends StatelessWidget {
  final List<HydrationModel> drinks;

  const RecentDrinksGrid({Key? key, required this.drinks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: drinks.length,
      itemBuilder: (context, index) {
        return DrinkGridItem(drink: drinks[index]);
      },
    );
  }
}

class DrinkGridItem extends StatelessWidget {
  final HydrationModel drink;

  const DrinkGridItem({Key? key, required this.drink}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String iconPath;
    switch (drink.type.toLowerCase()) {
      case 'agua':
        iconPath = 'assets/icons/water_icon.svg';
        break;
      case 'gaseosa':
        iconPath = 'assets/icons/soda_icon.svg';
      case 'té':
        iconPath = 'assets/icons/tea_icon.svg';
      case 'café':
        iconPath = 'assets/icons/coffee_icon.svg';
      case 'refresco':
        iconPath = 'assets/icons/soda_icon.svg';
      case 'cerveza':
        iconPath = 'assets/icons/beer_icon.svg';
        break;
      // Add more cases for other drink types
      default:
        iconPath = 'assets/icons/water_icon.svg';
    }

    return InkWell(
      onLongPress: () {
        //show dialog alert from delete or not when is press yes archive the item
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Delete Drink'),
              content: Text('Are you sure you want to delete this drink?'),
              actions: <Widget>[
                ElevatedButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Delete'),
                  onPressed: () {
                    Provider.of<HydrationProvider>(context, listen: false)
                        .deleteDrinkEntry(drink.id);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              height: 40,
              width: 40,
            ),
            SizedBox(height: 8),
            Text('${drink.amount} ml'),
            Text(drink.type,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

// Keep your existing AddDrinkForm class here

class AddDrinkForm extends StatelessWidget {
  final List<Map<String, String>> drinks = [
    {'name': 'Agua', 'icon': 'assets/icons/water_icon.svg'},
    {'name': 'Café', 'icon': 'assets/icons/coffee_icon.svg'},
    {'name': 'Té', 'icon': 'assets/icons/tea_icon.svg'},
    {'name': 'Cerveza', 'icon': 'assets/icons/beer_icon.svg'},
    {'name': 'Gaseosa', 'icon': 'assets/icons/soda_icon.svg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SELECT DRINK',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: drinks.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // Create a TextEditingController to capture the input
                      TextEditingController quantityController =
                          TextEditingController(text: "600");
                      return AlertDialog(
                        title: Text('Enter Quantity'),
                        content: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter quantity in ml',
                          ),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          ElevatedButton(
                            child: Text('OK'),
                            onPressed: () {
                              final amount = int.parse(quantityController.text);
                              final drink = HydrationModel(
                                amount: amount,
                                date: DateTime.now(),
                                description: drinks[index]['name']!,
                                type: drinks[index]['name']!,
                              );
                              Provider.of<HydrationProvider>(context,
                                      listen: false)
                                  .addDrinkEntry(drink);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  ),
                },
                child: Column(
                  children: [
                    SvgPicture.asset(
                      drinks[index]['icon']!,
                      height: 50,
                      width: 50,
                    ),
                    SizedBox(height: 8),
                    Text(drinks[index]['name']!),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
