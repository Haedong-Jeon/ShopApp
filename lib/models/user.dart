import 'package:flutter/foundation.dart';

class User {
  String userName;
  static final User _currentUser = User._internal();
  factory User() => _currentUser;
  User._internal();
}
