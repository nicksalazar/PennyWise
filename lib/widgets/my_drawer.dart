import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pennywise/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
                      backgroundImage: AssetImage(
                        'assets/icon/app_icon.png',
                      ),
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
            title: l10n.myDrawerHome,
            route: '/home',
            currentRoute: currentRoute,
          ),
          _buildListTile(
            context,
            icon: Icons.monetization_on,
            title: l10n.myDrawerAccounts,
            route: '/accounts',
            currentRoute: currentRoute,
          ),
          _buildListTile(
            context,
            icon: Icons.category,
            title: l10n.myDrawerCategories,
            route: '/categories',
            currentRoute: currentRoute,
          ),
          _buildListTile(
            context,
            icon: Icons.settings,
            title: l10n.myDrawerSettings,
            route: '/settings',
            currentRoute: currentRoute,
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text(l10n.myDrawerLogout),
            onTap: () async {
              await Provider.of<AuthProvider>(context, listen: false)
                  .signOut()
                  .then(
                    (value) => GoRouter.of(context).go('/auth/logout'),
                  );
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
