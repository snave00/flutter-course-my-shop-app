import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/product_provider.dart';
import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  const ProductsGrid({super.key, required this.showOnlyFavorites});

  final bool showOnlyFavorites;

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductProvider>(context);
    final products = showOnlyFavorites
        ? productsData.getFavoritesOnly
        : productsData.getItems;

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        return ChangeNotifierProvider.value(
          value:
              products[index], // Use this for lists that recycles to avoid bugs
          // create: (context) => products[index], // Use this for creating new instances.
          child: ProductItem(
            key: ValueKey(products[index].id),
            // id: products[index].id ?? 'No Id',
            // title: products[index].title ?? 'No Title',
            // imageUrl: products[index].imageUrl ?? 'No Image',
            // will not use passed arguments anymore since we used a provider.
          ),
        );
      },
      itemCount: products.length,
    );
  }
}
