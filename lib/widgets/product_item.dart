import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';

import '../models/product_model.dart';
import '../utils/app_routes.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({
    super.key,
    // required this.id,
    // required this.title,
    // required this.imageUrl,
  });

  // final String id;
  // final String title;
  // final String imageUrl;

  @override
  Widget build(BuildContext context) {
    // You can comment out product Provider since we already used Consumer.
    // But in this scenario, we use the 'product' in other parts.
    // So, we will set the listen to false and only listens to Consumer when there's an update.
    final product = Provider.of<ProductModel>(context, listen: false);
    final cart = Provider.of<CartProvider>(context, listen: false);
    print('isRebuilt');

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          // Consumer - alternative way of Provider.of
          // It only rebuilds the wrap child widget unlike w/ Provider.of(entire widget tree).
          // You can use child inside Consumer to exclude rebuilding that widget.
          leading: Consumer<ProductModel>(
            builder: (builderContext, value, child) => IconButton(
              icon: product.isFavorite
                  ? const Icon(Icons.favorite)
                  : const Icon(Icons.favorite_border),
              onPressed: () {
                product.toggleFavorites();
              },
              // Take note of referring the correct 'context'.
              // If we used the 'builderContext' then the color would not reflect correctly
              // Used the original BuildContext here.
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          title: Text(
            product.title ?? 'No Title',
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              print('Shopping Add to Cart');
              cart.addItem(
                product.id ?? '0',
                product.price ?? 0,
                product.title ?? 'No Title',
              );

              // ScaffoldMessenger takes the nearest Scaffold. In this case, product_overview.
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Added item to cart!'),
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cart.removeSingleItem(product.id ?? '');
                    },
                  ),
                ),
              );
            },
            color: Theme.of(context).colorScheme.secondary,
          ),
          backgroundColor: Colors.black87,
        ),
        child: GestureDetector(
          onTap: () {
            AppRoutes.goToProductDetailScreen(context, product.id);
          },
          child: Image.network(
            product.imageUrl ?? '',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
