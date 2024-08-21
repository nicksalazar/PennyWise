import 'package:flutter/material.dart';

class ColorSelector extends StatefulWidget {
  final void Function(Color) onColorSelected;

  ColorSelector({required this.onColorSelected});

  @override
  _ColorSelectorState createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  Color? selectedColor;
  int currentPage = 0;

  final List<List<Color>> colors = [
    [
      // First Page Colors
      Colors.green.shade900, Colors.green.shade700, Colors.green.shade500,
      Colors.green.shade300, Colors.green.shade100,
      Colors.blue.shade900, Colors.blue.shade700, Colors.blue.shade500,
      Colors.blue.shade300, Colors.blue.shade100,
      Colors.orange.shade900, Colors.orange.shade700, Colors.orange.shade500,
      Colors.orange.shade300, Colors.orange.shade100,
      Colors.pink.shade900, Colors.pink.shade700, Colors.pink.shade500,
      Colors.pink.shade300, Colors.pink.shade100,
      Colors.teal.shade900, Colors.teal.shade700, Colors.teal.shade500,
      Colors.teal.shade300, Colors.teal.shade100,
    ],
    [
      // Second Page Colors
      Colors.teal.shade900, Colors.teal.shade700, Colors.teal.shade500,
      Colors.teal.shade300, Colors.teal.shade100,
      Colors.red.shade900, Colors.red.shade700, Colors.red.shade500,
      Colors.red.shade300, Colors.red.shade100,
      Colors.purple.shade900, Colors.purple.shade700, Colors.purple.shade500,
      Colors.purple.shade300, Colors.purple.shade100,
      Colors.black, Colors.grey.shade700, Colors.grey.shade500,
      Colors.grey.shade300, Colors.grey.shade100,
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Color'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 400,
            child: PageView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: colors.length,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemBuilder: (context, pageIndex) {
                return GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: colors[pageIndex].length,
                  itemBuilder: (context, colorIndex) {
                    final color = colors[pageIndex][colorIndex];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                        widget.onColorSelected(color);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: selectedColor == color
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(colors.length, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                width: currentPage == index ? 12.0 : 8.0,
                height: currentPage == index ? 12.0 : 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentPage == index ? Colors.green : Colors.grey,
                ),
              );
            }),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (selectedColor != null) {
                // Do something with the selected color
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Select',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
