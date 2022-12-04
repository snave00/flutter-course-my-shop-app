import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:my_shop/utils/http_exception.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    // return true if token is not null
    print('AUTH BA: $token');
    print('AUTH BA2: ${token != null}');
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

  String? get userId {
    // add null checks like get Token if necessary.
    return _userId;
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
      _autoLogout();
      print('Expiry Date $_expiryDate');
      notifyListeners();
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

  void logout() {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }

    // Expiry Date - Current Time = Time to Expire
    final timetoExpiry = _expiryDate?.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timetoExpiry ?? 0), logout);
  }
}
