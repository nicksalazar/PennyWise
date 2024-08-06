import 'package:flutter/material.dart';

class TransferHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Transfers'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Day'),
              Tab(text: 'Week'),
              Tab(text: 'Month'),
              Tab(text: 'Year'),
              Tab(text: 'Period'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TransferList(),
            TransferList(),
            TransferList(),
            TransferList(),
            TransferList(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            // Navigate to create transfer screen
          },
        ),
      ),
    );
  }
}

class TransferList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text('August 4, 2024'),
          subtitle: Text('Yape → Efectivo'),
          trailing: Text('S/.1'),
        ),
        ListTile(
          title: Text('August 4, 2024'),
          subtitle: Text('Efectivo → Yape'),
          trailing: Text('S/.1'),
        ),
      ],
    );
  }
}