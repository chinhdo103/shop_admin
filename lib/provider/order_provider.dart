import 'package:flutter/cupertino.dart';

class OrderProvider with ChangeNotifier {
  String? status;
  filterOrder(status) {
    status = status;
    notifyListeners();
  }
}
