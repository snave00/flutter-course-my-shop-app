import 'package:flutter/material.dart';
import 'package:my_shop/provider/product_provider.dart';
import '../utils/app_routes.dart';
import 'package:provider/provider.dart';

class UserProductItem extends StatelessWidget {
  const UserProductItem({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.title,
  });

  final String id;
  final String imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    // ScaffoldMessenger.of(context) does not work inside FUTURE/async.
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(title),
        trailing: FittedBox(
          // width: 100,
          child: Row(
            children: [
              IconButton(
                  onPressed: () {
                    AppRoutes.goToEditProductScreen(context: context, id: id);
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                  )),
              IconButton(
                  onPressed: () async {
                    try {
                      await Provider.of<ProductProvider>(context, listen: false)
                          .deleteProduct(id);
                    } catch (error) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Deleting Failed'),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).errorColor,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
