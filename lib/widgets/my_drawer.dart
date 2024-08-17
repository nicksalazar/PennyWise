import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_harmony/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Ensure that user data is loaded
    final user = authProvider.user;

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/icon/app_icon.png'),
                ),
                SizedBox(height: 8),
                Text(
                  user?.displayName ?? 'Nick Salazar',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                Text(
                  user?.email ?? 'example@gmail.com',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.pie_chart),
            title: Text('Home'),
            onTap: () {
              context.go('/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.monetization_on),
            title: Text('Accounts'),
            onTap: () {
              context.go('/accounts');
            },
          ),
          ListTile(
            leading: Icon(Icons.category),
            title: Text('Categories'),
            onTap: () {
              context.go('/categories');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // Asumiendo que tienes una ruta '/settings'
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              await Provider.of<AuthProvider>(context, listen: false).signOut();
              context.go('/auth/login');
            },
          ),
        ],
      ),
    );
  }
}
