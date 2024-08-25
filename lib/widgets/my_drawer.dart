import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pennywise/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatefulWidget {
  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //call to provider
    Provider.of<AuthProvider>(context, listen: false).fetchUserInfo();
  }
  @override
  Widget build(BuildContext context) {
    final currentRoute =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    print("current route ${currentRoute}");

    return Drawer(
      child: ListView(
        children: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final userInfo = authProvider.userInfo;
              return DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/icon/app_icon.png'),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black
                              .withOpacity(0.5), // Fondo semitransparente
                        ),
                        child: Center(
                          child: Text(
                            userInfo['name']?[0].toUpperCase() ?? '?',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      userInfo['name'] ?? 'Usuario',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userInfo['email'] ?? 'No email',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
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
