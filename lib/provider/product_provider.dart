import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  Map<String, dynamic>? productData = {};
  getFormData({String? tenSanPham, int? giaGoc, int? giaDaGiam}) {
    if (tenSanPham != null) {
      productData!['tenSanPham'] = tenSanPham;
    }
    if (giaGoc != null) {
      productData!['giaGoc'] = giaGoc;
    }
    if (giaDaGiam != null) {
      productData!['giaDaGiam'] = giaDaGiam;
    }
    notifyListeners();
  }
}
