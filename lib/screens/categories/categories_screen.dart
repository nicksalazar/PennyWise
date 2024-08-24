import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pennywise/models/category_model.dart';
import 'package:pennywise/providers/category_provider.dart';
import 'package:pennywise/utils/icon_utils.dart';
import 'package:pennywise/widgets/my_drawer.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _selectedTab = 'expense';

  void _selectTab(String tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  void _deleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar esta categoría?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                Provider.of<CategoryProvider>(context, listen: false)
                    .deleteCategory(category.id);
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false);
    });
  }

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
      body: Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
        final categories = categoryProvider.categories
            .where((category) => category.type == _selectedTab)
            .toList();
        print("categories ${categories.length}");
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        child: Text('EXPENSES'),
                        onPressed: () => _selectTab('expense'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedTab == 'expense'
                              ? Colors.amber
                              : Colors.white,
                          foregroundColor: _selectedTab == 'expense'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        child: Text('INCOME'),
                        onPressed: () => _selectTab('income'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedTab == 'income'
                              ? Colors.amber
                              : Colors.white,
                          foregroundColor: _selectedTab == 'income'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                padding: EdgeInsets.all(16),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  ...categories.map(
                    (category) => GestureDetector(
                      onLongPress: () => _deleteCategory(category),
                      child: CategoryIcon(
                        color: _hexToColor(category.color),
                        icon: getIconDataByName(category.icon),
                        label: category.name,
                      ),
                    ),
                  ),
                  //add icon categoyy
                  InkWell(
                    onTap: () {
                      context.go('/categories/new_category/$_selectedTab');
                    },
                    child: CategoryIcon(
                      color: Colors.yellow,
                      icon: Icons.add,
                      label: 'add',
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

Color _hexToColor(String hex) {
  try {
    return Color(int.parse(hex.replaceFirst('#', '0xff')));
  } catch (e) {
    // Log the error or handle it as needed
    print('Invalid hex color: $hex');
    // Return a default color (e.g., black) in case of error
    return Color(0xFF000000);
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
          radius: 25,
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
