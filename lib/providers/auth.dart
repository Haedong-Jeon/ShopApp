import 'dart:convert';
import 'package:ShopApp/models/http_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/http_exceptions.dart';

class Auth with ChangeNotifier {
  String _token;
  String _userId;
  DateTime _expiryDate;

  Future<void> _authenticate(
      {@required String email,
      @required String password,
      @required String urlSegment}) async {
    final String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBY1NEmtQpuvgbyuhpun3-SuKS9fk_H2Bg';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(
      {@required String email, @required String password}) async {
    return _authenticate(
        email: email, password: password, urlSegment: 'signUp');
  }

  Future<void> login(
      {@required String email, @required String password}) async {
    return _authenticate(
        email: email, password: password, urlSegment: 'signInWithPassword');
  }
}
