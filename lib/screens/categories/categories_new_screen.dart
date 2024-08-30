import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pennywise/models/category_model.dart';
import 'package:pennywise/providers/category_provider.dart';
import 'package:pennywise/themes/app_theme.dart';
import 'package:pennywise/utils/icon_utils.dart';
import 'package:provider/provider.dart';
import '../../widgets/color_selector_widget.dart';

class NewCategoryScreen extends StatefulWidget {
  final String categoryType;

  NewCategoryScreen({required this.categoryType});
  @override
  _NewCategoryScreenState createState() => _NewCategoryScreenState();
}

class _NewCategoryScreenState extends State<NewCategoryScreen> {
  bool isExpense = true;
  String _name = '';
  String _selectedIcon = 'help';
  Color _selectedColor = AppTheme.folly;
  final _formKey = GlobalKey<FormState>();

  final List<Color> colors = [
    AppTheme.folly,
    AppTheme.accentBlue,
    AppTheme.successGreen,
    AppTheme.warningYellow,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    isExpense = widget.categoryType == 'expense';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = categorizedIcons.entries
        .map((e) => e.value)
        .expand((element) => element)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Category'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'Enter a category name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              SizedBox(height: 24),
              Text('Category Type', style: theme.textTheme.titleLarge),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.remove_circle_outline),
                      label: Text('Expense'),
                      onPressed: () => setState(() => isExpense = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isExpense
                            ? AppTheme.folly
                            : theme.colorScheme.surface,
                        foregroundColor: isExpense
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.add_circle_outline),
                      label: Text('Income'),
                      onPressed: () => setState(() => isExpense = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isExpense
                            ? AppTheme.successGreen
                            : theme.colorScheme.surface,
                        foregroundColor: !isExpense
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text('Icon', style: theme.textTheme.titleLarge),
              SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: (categories.length * 0.2).ceil() + 1,
                itemBuilder: (context, index) {
                  if (index == (categories.length * 0.2).ceil()) {
                    return _buildIconButton(
                      onTap: () async {
                        final result =
                            await context.push('/categories/icon_catalog');
                        if (result != null && result is String) {
                          setState(() => _selectedIcon = result);
                        }
                      },
                      icon: Icons.more_horiz,
                      isSelected: false,
                    );
                  }

                  final iconName = categories[index];
                  final iconData = getIconDataByName(iconName);
                  return _buildIconButton(
                    onTap: () => setState(() => _selectedIcon = iconName),
                    icon: iconData,
                    isSelected: _selectedIcon == iconName,
                  );
                },
              ),
              SizedBox(height: 24),
              Text('Color', style: theme.textTheme.titleLarge),
              SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    colors.map((color) => _buildColorButton(color)).toList()
                      ..add(_buildCustomColorButton()),
              ),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.folly,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(
                    'Create Category',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
      {required VoidCallback onTap,
      required IconData icon,
      required bool isSelected}) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: isSelected ? _selectedColor : Colors.grey[300],
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.black,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedColor.value == color.value
                ? Colors.black
                : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomColorButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ColorSelector(
              onColorSelected: (color) =>
                  setState(() => _selectedColor = color),
            ),
          ),
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey),
        ),
        child: Icon(Icons.add, size: 20),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newCategory = Category(
        id: '',
        name: _name,
        icon: _selectedIcon,
        color:
            '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
        type: isExpense ? 'expense' : 'income',
      );
      Provider.of<CategoryProvider>(context, listen: false)
          .addCategory(newCategory);
      context.pop();
    }
  }
}
