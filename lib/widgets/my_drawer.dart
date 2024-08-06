import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_harmony/screens/accounts/account_screen.dart';
import 'package:habit_harmony/screens/categories/categories_screen.dart';
import 'package:habit_harmony/screens/dashboard_screen.dart';
import 'package:habit_harmony/screens/home/home_screen.dart';
import 'package:habit_harmony/screens/home_screen.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1E2923)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/profile.jpg'),
                ),
                SizedBox(height: 8),
                Text('John Doe', style: TextStyle(color: Colors.white)),
                Text(
                  'john.doe@example.com',
                  style: TextStyle(color: Colors.white),
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
            onTap: () {
              // Aquí puedes implementar la lógica de cierre de sesión
              // Por ejemplo:
              // AuthService.logout();
            },
          ),
        ],
      ),
    );
  }
}
