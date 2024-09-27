import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pennywise/models/category_model.dart';
import 'package:pennywise/providers/category_provider.dart';
import 'package:pennywise/utils/icon_utils.dart';
import 'package:pennywise/widgets/my_drawer.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  void _deleteCategory(Category category, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.confirmDeletion),
          content: Text(l10n.deleteCategoryConfirmation),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(l10n.delete),
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text(l10n.categories),
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
                        l10n.expenses,
                        'expense',
                        theme,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildTabButton(
                        l10n.income,
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
                      (category) => _buildCategoryItem(category, theme, l10n),
                    ),
                    _buildAddCategoryItem(theme, l10n),
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

  Widget _buildCategoryItem(
      Category category, ThemeData theme, AppLocalizations l10n) {
    return GestureDetector(
      onLongPress: () => _deleteCategory(category, l10n),
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

  Widget _buildAddCategoryItem(ThemeData theme, AppLocalizations l10n) {
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
          label: l10n.add,
        ),
      ),
    );
  }
}

Color _hexToColor(String hex) {
  try {
    return Color(int.parse(hex.replaceFirst('#', '0xff')));
  } catch (e) {
    return Colors.grey; // Color por defecto en caso de error
  }
}

class CategoryIcon extends StatefulWidget {
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
  State<CategoryIcon> createState() => _CategoryIconState();
}

class _CategoryIconState extends State<CategoryIcon> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..repeat(reverse: true);

    _animationController.addListener(() {
      _scrollController.jumpTo(_animationController.value *
          _scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: widget.color,
          radius: 25,
          child: Icon(widget.icon, color: Colors.white, size: 30),
        ),
        SizedBox(height: 8),
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ],
    );
  }
}
