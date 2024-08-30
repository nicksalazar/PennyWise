import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pennywise/themes/app_theme.dart';
import 'package:pennywise/utils/icon_utils.dart';

class IconsCatalogScreen extends StatefulWidget {
  @override
  _IconsCatalogState createState() => _IconsCatalogState();
}

class _IconsCatalogState extends State<IconsCatalogScreen> {
  String? _selectedIconName;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Icon Catalog'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select an icon for your category',
              style: theme.textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: categorizedIcons.length,
                itemBuilder: (context, index) {
                  final entry = categorizedIcons.entries.elementAt(index);
                  return _buildIconSection(entry.key, entry.value);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectedIconName != null
            ? () => context.pop(_selectedIconName)
            : null,
        label: Text('Select'),
        icon: Icon(Icons.check),
        backgroundColor:
            _selectedIconName != null ? AppTheme.folly : theme.disabledColor,
      ),
    );
  }

  Widget _buildIconSection(String title, List<String> iconNames) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: iconNames.length,
            itemBuilder: (context, index) => _buildIconItem(iconNames[index]),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildIconItem(String iconName) {
    final isSelected = _selectedIconName == iconName;
    final iconData = getIconDataByName(iconName);
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIconName = iconName;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.folly : theme.cardColor,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppTheme.folly.withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 2)
                ]
              : null,
        ),
        child: Icon(
          iconData,
          size: 30,
          color: isSelected ? Colors.white : theme.iconTheme.color,
        ),
      ),
    );
  }
}
