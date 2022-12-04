import 'package:flutter/material.dart';
import 'package:my_shop/utils/app_routes.dart';
import '../provider/auth_provider.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  Widget _buildListTile(
    BuildContext context,
    Function onTap,
    IconData icon,
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: () => onTap(),
        leading: Icon(icon),
        title: Text(
          title,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 80,
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            color: Theme.of(context).colorScheme.primary,
            alignment: Alignment.bottomLeft,
            child: const Text(
              'Hello friend!',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          _buildListTile(
            context,
            () {
              AppRoutes.goToProductOverviewScreen(context);
            },
            Icons.shop,
            'Shop',
          ),
          const Divider(),
          _buildListTile(
            context,
            () {
              AppRoutes.goToOrderScreen(context);
            },
            Icons.card_giftcard,
            'Orders',
          ),
          const Divider(),
          _buildListTile(
            context,
            () {
              AppRoutes.goToUserProductScreen(context);
            },
            Icons.edit,
            'Manage Products',
          ),
          const Divider(),
          _buildListTile(
            context,
            () {
              // Close drawer
              Navigator.of(context).pop();
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            Icons.logout,
            'Logout',
          ),
        ],
      ),
    );
  }
}
