import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItemModel> _items = {};

  Map<String, CartItemModel> get items {
    return {..._items};
  }

  void addItem(
    String productId,
    double price,
    String title,
  ) {
    if (_items.containsKey(productId)) {
      // If product id already exists, just update quantity.
      _items.update(
          productId,
          (existingCartItem) => CartItemModel(
                id: existingCartItem.id,
                title: existingCartItem.title,
                quantity: (existingCartItem.quantity) + 1,
                price: existingCartItem
                    .price, // need to increase when quantity increased
              ));
    } else {
      // If product id does not exist, add to list.
      _items.putIfAbsent(
          productId,
          () => CartItemModel(
              id: DateTime.now().toString(),
              title: title,
              price: price,
              quantity: 1));
    }
    notifyListeners();
  }

  double get getTotal {
    double total = 0.0;
    _items.forEach(
      (key, value) {
        total += (value.price * value.quantity);
      },
    );
    return total;
  }

  int get itemCount {
    return _items.length;
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }

    if ((_items[productId]!.quantity) > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItemModel(
          id: existingCartItem.id,
          title: existingCartItem.title,
          quantity: existingCartItem.quantity - 1,
          price: existingCartItem.price,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
