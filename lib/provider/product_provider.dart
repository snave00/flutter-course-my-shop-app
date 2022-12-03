import 'dart:convert';
import 'package:flutter/material.dart';
// import '../data/products_data.dart';
import 'package:my_shop/models/product_model.dart';
import 'package:http/http.dart' as http;
import '../utils/http_exception.dart';

class ProductProvider with ChangeNotifier {
  late String? _authToken;

  set authToken(String value) {
    _authToken = value;
  }

  // List<ProductModel> _items = loadedProducts;
  List<ProductModel> _items = [];

  List<ProductModel> get getItems {
    // returns a copy of _items.
    return [..._items];
  }

  List<ProductModel> get getFavoritesOnly {
    return _items.where((element) => element.isFavorite).toList();
  }

  //** USING FUTURE WITH .then() **/
  // set to Future in order to set loading.
  Future<void> addProduct(ProductModel productModel) {
    // How to HTTP Request
    final url = Uri.https(
        'flutter-course-2a591-default-rtdb.firebaseio.com', '/products.json');
    return http
        .post(
      url,
      body: json.encode({
        'title': productModel.title,
        'description': productModel.description,
        'price': productModel.price,
        'imageUrl': productModel.imageUrl,
        'isFavorite': productModel.isFavorite,
      }),
    )
        .then((response) {
      // Will run after the post is done.
      print(response.body);
      print('Response Code: ${response.statusCode}');
      // Add locally
      _items.add(ProductModel(
        id: DateTime.now().toString(),
        title: productModel.title,
        description: productModel.description,
        price: productModel.price,
        imageUrl: productModel.imageUrl,
      ));
      notifyListeners();
    }).catchError((error) {
      // catches the error in post and then.
      // This catch error does not executed if I purposedly changed the /products.json
      // to 'products'. It returns a response code of 405 somehow. Unlike in the lecture.
      // Response code should be handled by future Evanson.
      print('Error po: ' + error);

      // in this case, we throw the error to trigger the error again
      // it passed the error in 'edit_product_screen' 'add product' who called this function
      throw error;
    });
  }

  //** ALTERNATIVE WAY OF USING FUTURE WITH async **/
  Future<void> addProduct2(ProductModel productModel) async {
    // All code inside automatically gets wrapped into FUTURE when using async
    final url = Uri.https('flutter-course-2a591-default-rtdb.firebaseio.com',
        '/products.json', {'auth': '$_authToken'});

    // await - it tells dart that it wait for this to finish before executing
    // the next block of code (no need to use 'then'. It's an invisible 'then')
    // final response -> since post is FUTURE, it will return a value which we can store in a variable.

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': productModel.title,
          'description': productModel.description,
          'price': productModel.price,
          'imageUrl': productModel.imageUrl,
          'isFavorite': productModel.isFavorite,
        }),
      );

      // Will run after the await post is done (invisible .then).
      print('Response Body: ${response.body}');
      print('Response Code: ${response.statusCode}');

      // Add locally
      _items.add(ProductModel(
        id: json.decode(
            response.body)['name'], // gets the name parameter in response body
        title: productModel.title,
        description: productModel.description,
        price: productModel.price,
        imageUrl: productModel.imageUrl,
      ));

      notifyListeners();
    } catch (error) {
      // This catch error does not executed if I purposedly changed the /products.json
      // to 'products'. It returns a response code of 405 somehow. Unlike in the lecture.
      // Response code should be handled by future Evanson.
      print('addProduct2 error: $error');

      // in this case, we throw the error to trigger the error again
      // it passed the error in 'edit_product_screen' 'add product' who called this function
      rethrow;
    }
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.https('flutter-course-2a591-default-rtdb.firebaseio.com',
        '/products.json', {'auth': '$_authToken'});
    // final url = Uri.parse(
    //     'https://flutter-course-2a591-default-rtdb.firebaseio.com');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;
      // final extractedData2 = jsonDecode(response.body); // alternative way
      print('FETCH PRODUCT: $extractedData');
      // print('FETCH PRODUCT2: $extractedData2');
      if (extractedData == null) {
        return;
      }

      final List<ProductModel> loadedProducts = [];

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          ProductModel(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavorite: prodData['isFavorite'],
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String productId, ProductModel newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == productId);
    if (prodIndex >= 0) {
      final url = Uri.https('flutter-course-2a591-default-rtdb.firebaseio.com',
          '/products/$productId.json');
      try {
        await http.patch(
          url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }),
        );

        _items[prodIndex] = newProduct;
        notifyListeners();
      } catch (error) {
        print('updateProduct: $error');
      }
    }
  }

  Future<void> deleteProduct(String productId) async {
    final url = Uri.https('flutter-course-2a591-default-rtdb.firebaseio.com',
        '/products/$productId.json');
    final existingProductIndex =
        _items.indexWhere((element) => element.id == productId);
    ProductModel? existingProduct = _items[existingProductIndex]; // backup

    // _items.removeWhere((element) => element.id == productId);
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      // re insert if deleting failed.
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }

  ProductModel findById(String id) {
    return getItems.firstWhere((element) => element.id == id);
  }
}
