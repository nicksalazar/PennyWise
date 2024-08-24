import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pennywise/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    print("current route ${currentRoute}");
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
          _buildListTile(
            context,
            icon: Icons.pie_chart,
            title: 'Home',
            route: '/home',
            currentRoute: currentRoute,
          ),
          _buildListTile(
            context,
            icon: Icons.monetization_on,
            title: 'Accounts',
            route: '/accounts',
            currentRoute: currentRoute,
          ),
          _buildListTile(
            context,
            icon: Icons.category,
            title: 'Categories',
            route: '/categories',
            currentRoute: currentRoute,
          ),
          // _buildListTile(
          //   context,
          //   icon: Icons.settings,
          //   title: 'Settings',
          //   route: '/settings',
          //   currentRoute: currentRoute,
          // ),
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

  Widget _buildListTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String route,
      required String currentRoute}) {
    final isSelected = currentRoute == route;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : null),
      title: Text(
        title,
        style: TextStyle(color: isSelected ? Colors.blue : null),
      ),
      selected: isSelected,
      onTap: () {
        context.go(route);
      },
    );
  }
}
