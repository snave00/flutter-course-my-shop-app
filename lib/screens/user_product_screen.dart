import 'package:flutter/material.dart';
import 'package:my_shop/utils/app_routes.dart';
import '../widgets/my_drawer.dart';
import '../widgets/user_product_item.dart';
import '../provider/product_provider.dart';
import 'package:provider/provider.dart';

class UserProductScreen extends StatelessWidget {
  const UserProductScreen({super.key});

  Future<void> _refreshProducts(BuildContext context) async {
    Provider.of<ProductProvider>(context, listen: false).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
              onPressed: () {
                AppRoutes.goToEditProductScreen(context: context);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      drawer: const MyDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Consumer<ProductProvider>(
          builder: (builderContext, value, child) {
            return ListView.builder(
              itemCount: value.getItems.length,
              itemBuilder: (context, index) => Column(
                children: [
                  UserProductItem(
                    id: value.getItems[index].id ?? '',
                    imageUrl: value.getItems[index].imageUrl ?? '',
                    title: value.getItems[index].title ?? '',
                  ),
                  const Divider(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
