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
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                Provider.of<CategoryProvider>(context, listen: false)
                    .deleteCategory(category.id);
                Navigator.of(context).pop();
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
    final theme = Theme.of(context);
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text('Categorías'),
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
          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        'GASTOS',
                        'expense',
                        theme,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildTabButton(
                        'INGRESOS',
                        'income',
                        theme,
                      ),
                    ),
                  ],
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
                      (category) => _buildCategoryItem(category, theme),
                    ),
                    _buildAddCategoryItem(theme),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabButton(String label, String tabValue, ThemeData theme) {
    final isSelected = _selectedTab == tabValue;
    return ElevatedButton(
      child: Text(label),
      onPressed: () => _selectTab(tabValue),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? theme.colorScheme.primary : theme.cardColor,
        foregroundColor: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface,
        elevation: isSelected ? 4 : 0,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(Category category, ThemeData theme) {
    return GestureDetector(
      onLongPress: () => _deleteCategory(category),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: CategoryIcon(
          color: _hexToColor(category.color),
          icon: getIconDataByName(category.icon),
          label: category.name,
        ),
      ),
    );
  }

  Widget _buildAddCategoryItem(ThemeData theme) {
    return InkWell(
      onTap: () {
        context.go('/categories/new_category/$_selectedTab');
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: CategoryIcon(
          color: theme.colorScheme.secondary,
          icon: Icons.add,
          label: 'Añadir',
        ),
      ),
    );
  }
}

Color _hexToColor(String hex) {
  try {
    return Color(int.parse(hex.replaceFirst('#', '0xff')));
  } catch (e) {
    print('Color hexadecimal inválido: $hex');
    return Colors.grey; // Color por defecto en caso de error
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
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
