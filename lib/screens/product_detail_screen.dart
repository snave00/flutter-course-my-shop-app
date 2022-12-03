import 'package:flutter/material.dart';
import 'package:my_shop/data/products_data.dart';
import 'package:provider/provider.dart';

import '../provider/product_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments as String;
    final product = Provider.of<ProductProvider>(
      context,
      listen: false,
      // About listen property:
      // Default value is true so no need to set to true.
      // Only set this to false if you need the data one time.
      // If true, if the data updates inside the ProductProvider,
      // -then it would rebuild this widget and update the data.
      // If false, if the data update inside the ProductProvider,
      // -then it would remain the same since it was set to false.
    ).findById(productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title ?? 'No Title'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Image.network(
                product.imageUrl ?? '',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '\$${product.price}',
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.secondary,
              ),
              softWrap: true,
            ),
            const SizedBox(height: 10),
            Text(product.description ?? ''),
          ],
        ),
      ),
    );
  }
}
