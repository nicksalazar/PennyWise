import 'package:flutter/material.dart';
import 'package:habit_harmony/screens/categories/categories_icons_catalog_screen.dart';

class NewCategoryScreen extends StatefulWidget {
  @override
  _NewCategoryScreenState createState() => _NewCategoryScreenState();
}

class _NewCategoryScreenState extends State<NewCategoryScreen> {
  bool isExpense = true;
  Color selectedColor = Colors.pink;

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Category Name',
                hintText: 'Enter a category name',
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Radio(
                  value: true,
                  groupValue: isExpense,
                  onChanged: (bool? value) {
                    setState(() {
                      isExpense = value!;
                    });
                  },
                ),
                Text('Expenses'),
                Radio(
                  value: false,
                  groupValue: isExpense,
                  onChanged: (bool? value) {
                    setState(() {
                      isExpense = value!;
                    });
                  },
                ),
                Text('Income'),
              ],
            ),
            SizedBox(height: 16),
            Text('Planned outlay'),
            TextField(
              decoration: InputDecoration(
                hintText: 'PEN per month',
                suffixText: 'PEN per month',
              ),
            ),
            SizedBox(height: 16),
            Text('Icons'),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              children: [
                IconButton(icon: Icon(Icons.receipt), onPressed: () {}),
                IconButton(icon: Icon(Icons.flight), onPressed: () {}),
                IconButton(icon: Icon(Icons.local_offer), onPressed: () {}),
                IconButton(icon: Icon(Icons.pets), onPressed: () {}),
                IconButton(icon: Icon(Icons.tv), onPressed: () {}),
                IconButton(icon: Icon(Icons.restaurant), onPressed: () {}),
                IconButton(icon: Icon(Icons.build), onPressed: () {}),
                IconButton(
                    icon: Icon(Icons.local_laundry_service), onPressed: () {}),
                IconButton(icon: Icon(Icons.beach_access), onPressed: () {}),
                IconButton(icon: Icon(Icons.videogame_asset), onPressed: () {}),
                IconButton(icon: Icon(Icons.directions_car), onPressed: () {}),
                IconButton(icon: Icon(Icons.local_hospital), onPressed: () {}),
                IconButton(icon: Icon(Icons.book), onPressed: () {}),
                IconButton(icon: Icon(Icons.person), onPressed: () {}),
                IconButton(icon: Icon(Icons.directions_run), onPressed: () {}),
                //floating button add
                FloatingActionButton(
                  backgroundColor: Colors.orange,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IconsCatalog()),
                    );
                  },
                  child: Icon(Icons.add),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text('Color'),
            Wrap(
              spacing: 8,
              children: [
                ColorButton(
                    color: Colors.pink,
                    isSelected: selectedColor == Colors.pink,
                    onTap: () => setColor(Colors.pink)),
                ColorButton(
                    color: Colors.blue,
                    isSelected: selectedColor == Colors.blue,
                    onTap: () => setColor(Colors.blue)),
                ColorButton(
                    color: Colors.yellow,
                    isSelected: selectedColor == Colors.yellow,
                    onTap: () => setColor(Colors.yellow)),
                ColorButton(
                    color: Colors.green,
                    isSelected: selectedColor == Colors.green,
                    onTap: () => setColor(Colors.green)),
                ColorButton(
                    color: Colors.red,
                    isSelected: selectedColor == Colors.red,
                    onTap: () => setColor(Colors.red)),
                ColorButton(
                    color: Colors.cyan,
                    isSelected: selectedColor == Colors.cyan,
                    onTap: () => setColor(Colors.cyan)),
                ColorButton(
                    color: Colors.grey,
                    isSelected: selectedColor == Colors.grey,
                    onTap: () => setColor(Colors.grey)),
              ],
            ),
            //rectangle button with rounder yellow
            SizedBox(
              height: 16,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void setColor(Color color) {
    setState(() {
      selectedColor = color;
    });
  }
}

class ColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const ColorButton({
    Key? key,
    required this.color,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
      ),
    );
  }
}
