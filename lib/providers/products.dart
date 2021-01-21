import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './product.dart';
import '../models/http_exceptions.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  final String authToken;
  final String userId;
  Products(this.authToken, this._items, this.userId) {
    print('${this.authToken}과 ${this._items}로 초기화');
  }
  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts([bool filterdByUser = false]) async {
    final filterString =
        filterdByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    String url =
        'https://flutter-shopapp-9b7b2-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractedData == null) {
        return;
      }
      url =
          'https://flutter-shopapp-9b7b2-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';

      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      extractedData.forEach((productId, productData) {
        loadedProducts.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          isFavorite:
              favoriteData == null ? false : favoriteData[productId] ?? false,
          imgURL: productData['imgURL'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://flutter-shopapp-9b7b2-default-rtdb.firebaseio.com/products.json?auth=$authToken';

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imgURL': product.imgURL,
          'price': product.price,
          'creatorId': userId,
        }),
      );
      final Product newProduct = Product(
        title: product.title,
        imgURL: product.imgURL,
        description: product.description,
        price: product.price,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      print(response.body);
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final targetIndex = _items.indexWhere((item) => item.id == id);
    if (targetIndex >= 0) {
      final url =
          'https://flutter-shopapp-9b7b2-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
      try {
        await http.patch(
          url,
          body: json.encode(
            {
              'title': newProduct.title,
              'description': newProduct.description,
              'imgURL': newProduct.imgURL,
              'price': newProduct.price,
            },
          ),
        );
        _items[targetIndex] = newProduct;

        notifyListeners();
      } catch (error) {
        throw (error);
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-shopapp-9b7b2-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final index = _items.indexWhere((product) => product.id == id);
    Product savedProduct = _items[index];
    _items.removeWhere((item) => item.id == id);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(index, savedProduct);
      notifyListeners();
      throw HttpException('could not delete product!');
    }
    savedProduct = null;
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }
}
