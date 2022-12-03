import 'package:flutter/material.dart';
import 'package:my_shop/utils/app_routes.dart';
import '../widgets/my_drawer.dart';
import '../widgets/user_product_item.dart';
import '../provider/product_provider.dart';
import 'package:provider/provider.dart';

class UserProductScreen extends StatefulWidget {
  const UserProductScreen({super.key});

  @override
  State<UserProductScreen> createState() => _UserProductScreenState();
}

class _UserProductScreenState extends State<UserProductScreen> {
  late Future _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _refreshProducts(context);
  }

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductProvider>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    print('rebuilding...');
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
      body: FutureBuilder(
        future: _productsFuture,
        builder: (builderContext, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.done:
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text('An error has occured'),
                );
              } else {
                return RefreshIndicator(
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
                );
              }
          }
        },
      ),
    );
  }
}
