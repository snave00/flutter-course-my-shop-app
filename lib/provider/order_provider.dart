import 'package:flutter/cupertino.dart';

import '../models/order_item_model.dart';
import '../models/cart_item_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderProvider with ChangeNotifier {
  List<OrderItemModel> _orders = [];

  late String? _authToken;
  late String? _userId;

  set authToken(String value) {
    _authToken = value;
  }

  set userId(String value) {
    _userId = value;
  }

  List<OrderItemModel> get getOrders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItemModel> cartProducts, double total) async {
    final url = Uri.https(
      'flutter-course-2a591-default-rtdb.firebaseio.com',
      '/orders/$_userId.json',
      {'auth': '$_authToken'},
    );
    final timeStamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList()
        }));

    // .inset => inserts product to the top [0] based in the index.
    // .add adds at the bottom of the list.
    _orders.insert(
      0,
      OrderItemModel(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: timeStamp,
        products: cartProducts,
      ),
    );
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.https('flutter-course-2a591-default-rtdb.firebaseio.com',
        '/orders/$_userId.json', {'auth': '$_authToken'});
    final response = await http.get(url);
    final List<OrderItemModel> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>?;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItemModel(
          id: orderId,
          amount: orderData['amount'],
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItemModel(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price'],
                  ))
              .toList(),
          dateTime: DateTime.parse(orderData['dateTime']),
        ),
      );
    });
    // reversed so the latest would be on top.
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }
}
