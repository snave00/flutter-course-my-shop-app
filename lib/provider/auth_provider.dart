import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:my_shop/utils/http_exception.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;

  bool get isAuth {
    // return true if token is not null
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        //isAfter => checks if expiryDate is expired.
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(
    String email,
    String password,
    String urlSegment,
  ) async {
    // Api key should be hidden somewhere secure.
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyD6SzAxlIxkKO6si6sxCuDYRc9llVc_nAs');

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      print('signup1 ${json.decode(response.body)}');
      print('signup2' + response.body);
      print('signup3 ${response.statusCode}');
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        print('signup4 ${response.statusCode}');
        throw HttpException(responseData['error']['message']);
      }

      // If no error
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      // DateTime.now + expiresIn (seconds) = expiry date.
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      notifyListeners();
      print('Expiry Date $_expiryDate');
    } catch (error) {
      print('signup5 $error');
      rethrow;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}
