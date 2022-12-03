import 'package:flutter/material.dart';
import 'package:my_shop/provider/product_provider.dart';
import '../provider/cart_provider.dart';
import 'package:my_shop/widgets/badge.dart';
import 'package:provider/provider.dart';
import '../shared/enums.dart';
import '/widgets/products_grid.dart';
import '../utils/app_routes.dart';
import '../widgets/my_drawer.dart';

class ProductOverviewScreen extends StatefulWidget {
  const ProductOverviewScreen({super.key});

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isLoading = false;

  @override
  void initState() {
    // Will not work inside the initState() if listen was not set to false.
    // See 249 fetching data lesson for alternative ways.
    setState(() {
      _isLoading = true;
    });

    Provider.of<ProductProvider>(context, listen: false)
        .fetchAndSetProducts()
        .then((value) {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (itemBuilderContext) {
              return [
                const PopupMenuItem(
                  value: FilterOptions.favorites,
                  child: Text('Only Favorites'),
                ),
                const PopupMenuItem(
                  value: FilterOptions.all,
                  child: Text('Show All'),
                ),
              ];
            },
          ),
          // Wrapped with Consumer since this part was the only needs rebuilding
          Consumer<CartProvider>(
            /// The following logic is for optimization.
            /// The 'child: IconButton' was moved outside the builder -
            /// since it does not need rebuilding.
            /// 'Badge' only needs rebuilding.
            /// 'builderChild' gets the 'child' (outside the builder:) -
            /// and assigned to 'child' (inside the builder)
            builder: (builderContext, value, builderChild) {
              print('Items' + value.itemCount.toString());
              return Badge(
                value: value.itemCount.toString(),
                child: builderChild as Widget,
              );
            },
            // Purpose of this child is to exclude it from rebuilding -
            // even though it's inside the Consumer.
            child: IconButton(
              onPressed: () {
                AppRoutes.goToCartScreen(context);
              },
              icon: const Icon(Icons.shopping_cart),
            ),
          )
        ],
      ),
      drawer: const MyDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(showOnlyFavorites: _showOnlyFavorites),
    );
  }
}
