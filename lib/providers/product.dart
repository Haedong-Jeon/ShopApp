import 'package:ShopApp/models/http_exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imgURL;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imgURL,
    this.isFavorite = false,
  });
  void _setFavValue(bool newStatus) {
    isFavorite = newStatus;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus() async {
    final bool oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final String url =
        'https://flutter-shopapp-9b7b2-default-rtdb.firebaseio.com/products/${id}.json';
    try {
      final response = await http.patch(
        url,
        body: json.encode(
          {
            'isFavorite': isFavorite,
          },
        ),
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(isFavorite);
    }
  }
}
