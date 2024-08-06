import 'package:flutter/material.dart';
import 'package:habit_harmony/screens/categories/categories_new_screen.dart';
import 'package:habit_harmony/widgets/my_drawer.dart';

class CategoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text('Categories'),
        actions: [
          IconButton(
            icon: Icon(Icons.fullscreen),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    child: Text('EXPENSES'),
                    onPressed: () {},
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    child: Text('INCOME'),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              children: [
                CategoryIcon(
                    color: Colors.red, icon: Icons.favorite, label: 'Health'),
                CategoryIcon(
                    color: Colors.green,
                    icon: Icons.account_balance_wallet,
                    label: 'Leisure'),
                CategoryIcon(
                    color: Colors.blue, icon: Icons.home, label: 'Home'),
                CategoryIcon(
                    color: Colors.yellow,
                    icon: Icons.restaurant,
                    label: 'Cafe'),
                CategoryIcon(
                    color: Colors.pink, icon: Icons.school, label: 'Education'),
                CategoryIcon(
                    color: Colors.lightGreen,
                    icon: Icons.card_giftcard,
                    label: 'Gifts'),
                CategoryIcon(
                    color: Colors.lightBlue,
                    icon: Icons.shopping_cart,
                    label: 'Groceries'),
                CategoryIcon(
                    color: Colors.red,
                    icon: Icons.family_restroom,
                    label: 'Family'),
                CategoryIcon(
                    color: Colors.green,
                    icon: Icons.fitness_center,
                    label: 'Workout'),
                CategoryIcon(
                    color: Colors.blue,
                    icon: Icons.directions_bus,
                    label: 'Transportation'),
                CategoryIcon(
                    color: Colors.red, icon: Icons.help, label: 'Other'),
                CategoryIcon(
                    color: Colors.green,
                    icon: Icons.sports_soccer,
                    label: 'Sport'),
                CategoryIcon(
                    color: Colors.pink,
                    icon: Icons.directions_bike,
                    label: 'Bike'),
                CategoryIcon(
                    color: Colors.orange,
                    icon: Icons.fastfood,
                    label: 'Comida afuera'),
                CategoryIcon(
                    color: Colors.purple,
                    icon: Icons.videogame_asset,
                    label: 'Streaming'),
                CategoryIcon(
                    color: Colors.green,
                    icon: Icons.trending_up,
                    label: 'Debt'),
                CategoryIcon(
                    color: Colors.yellow,
                    icon: Icons.content_cut,
                    label: 'Haircut'),
                CategoryIcon(
                    color: Colors.pink,
                    icon: Icons.local_bar,
                    label: 'Entertainment'),
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return NewCategoryScreen();
                    }));
                  },
                  child: CategoryIcon(
                    color: Colors.orange,
                    icon: Icons.add,
                    label: 'Create',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryIcon extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const CategoryIcon({
    Key? key,
    required this.color,
    required this.icon,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
