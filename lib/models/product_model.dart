import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// This is a model and a provider at the same time.
class ProductModel with ChangeNotifier {
  final String? id;
  final String? title;
  final String? description;
  final double? price;
  final String? imageUrl;
  bool isFavorite;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavorites(String token, String userId) async {
    // final url = Uri.https('flutter-course-2a591-default-rtdb.firebaseio.com',
    //     '/products/$id.json', {'auth': token});

    // A directory for each user's favorites.
    final url = Uri.https('flutter-course-2a591-default-rtdb.firebaseio.com',
        '/user-favorites/$userId/$id.json', {'auth': token});
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      // replace patch to put (replace)
      final response = await http.put(url,
          // body: json.encode({
          //   'isFavorite': isFavorite,
          // }),
          body: json.encode(isFavorite) // stand alone value.
          );

      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}
