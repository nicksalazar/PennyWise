import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pennywise/utils/icon_utils.dart';

class IconsCatalogScreen extends StatefulWidget {
  @override
  _IconsCatalogState createState() => _IconsCatalogState();
}

class _IconsCatalogState extends State<IconsCatalogScreen> {
  String? _selectedIconName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Icon Catalog'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: categorizedIcons.entries.map((entry) {
            return _buildIconSection(entry.key, entry.value);
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectedIconName != null
            ? () => context.pop(_selectedIconName)
            : null,
        label: Text('Select'),
      ),
    );
  }

  Widget _buildIconSection(String title, List<String> iconNames) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children:
              iconNames.map((iconName) => _buildIconItem(iconName)).toList(),
        ),
      ],
    );
  }

  Widget _buildIconItem(String iconName) {
    final isSelected = _selectedIconName == iconName;
    final iconData = getIconDataByName(iconName);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIconName = iconName;
        });
      },
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Icon(iconData,
            size: 30, color: isSelected ? Colors.white : Colors.black54),
      ),
    );
  }
}
