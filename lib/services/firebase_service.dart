import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseServices {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  CollectionReference danhmuc =
      FirebaseFirestore.instance.collection('DanhMuc');
  CollectionReference lichsunhap =
      FirebaseFirestore.instance.collection('LichSuNhap');
  CollectionReference danhmucchinh =
      FirebaseFirestore.instance.collection('DanhMucChinh');
  CollectionReference danhmucphu =
      FirebaseFirestore.instance.collection('DanhMucPhu');
  CollectionReference taiKhoan =
      FirebaseFirestore.instance.collection('TaiKhoan');
  CollectionReference sanPham =
      FirebaseFirestore.instance.collection('SanPham');
  CollectionReference homeBanner =
      FirebaseFirestore.instance.collection('homeBanner');
  CollectionReference maGiamGia =
      FirebaseFirestore.instance.collection('MaGiamGia');
  CollectionReference taiKhoanNguoiDung =
      FirebaseFirestore.instance.collection('TaiKhoanNguoiDung');
  CollectionReference nhaKho = FirebaseFirestore.instance.collection('NhaKho');
  Future<int> getProductsBelowQuantity(num threshold) async {
    QuerySnapshot querySnapshot =
        await sanPham.where('SoLuong', isLessThanOrEqualTo: threshold).get();
    return querySnapshot.size;
  }

  Future<int> getProductsAboveQuantity(num threshold) async {
    QuerySnapshot querySnapshot =
        await sanPham.where('SoLuong', isGreaterThan: threshold).get();
    return querySnapshot.size;
  }

  //Hàm save danh mục
  Future<void> saveData(
      {CollectionReference? reference,
      Map<String, dynamic>? data,
      String? docName}) {
    return reference!.doc(docName).set(data);
  }

  Future<void> updateData(
      {CollectionReference? reference,
      Map<String, dynamic>? data,
      String? docName}) {
    return reference!.doc(docName).update(data!);
  }

  Future<void> deleteData({
    CollectionReference? reference,
    String? docName,
  }) async {
    await reference!.doc(docName).delete();
  }

  Future<String> upLoadBannerImageToDb(url) async {
    String downloadUrl = await storage.ref(url).getDownloadURL();
    // ignore: unnecessary_null_comparison
    if (downloadUrl != null) {
      firestore.collection('homeBanner').add({
        'image': downloadUrl,
      });
    }
    return downloadUrl;
  }

  Future<void> deleteCoupon(DocumentSnapshot document) async {
    try {
      await maGiamGia.doc(document.id).delete();
      print('Coupon deleted successfully!');
    } catch (error) {
      print('Error deleting coupon: $error');
      // Add more detailed error handling as needed
    }
  }

  Future<int> getNewSignUpsInDay(DateTime date) async {
    try {
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = startOfDay.add(Duration(days: 1));

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('TaiKhoanNguoiDung')
          .where('timestamp',
              isGreaterThanOrEqualTo: startOfDay, isLessThan: endOfDay)
          .get();

      // Count only the documents created on the same day
      int newSignUpsCount = 0;

      querySnapshot.docs.forEach((DocumentSnapshot document) {
        // Check if the document and its data are not null
        // ignore: unnecessary_null_comparison
        if (document != null && document.data() != null) {
          // Explicitly cast to Map<String, dynamic>
          Map<String, dynamic> documentData =
              document.data() as Map<String, dynamic>;

          // Access timestamp using ['timestamp'] with a null check
          dynamic timestampData = documentData['timestamp'];
          if (timestampData != null && timestampData is Timestamp) {
            Timestamp documentTimestamp = timestampData;

            // Check if the document timestamp is within the desired range
            if (documentTimestamp.toDate().isAfter(startOfDay) &&
                documentTimestamp.toDate().isBefore(endOfDay)) {
              newSignUpsCount++;
            }
          }
        }
      });

      return newSignUpsCount;
    } catch (e) {
      print('Error getting new sign-ups: $e');
      throw e;
    }
  }

  Future<int> getNewOrdersInDay(DateTime date) async {
    try {
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = startOfDay.add(Duration(days: 1));

      String startOfDayString = startOfDay.toUtc().toIso8601String();
      String endOfDayString = endOfDay.toUtc().toIso8601String();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('donhang')
          .where('timestamp',
              isGreaterThanOrEqualTo: startOfDayString,
              isLessThan: endOfDayString)
          .get();

      return querySnapshot.size;
    } catch (e) {
      print('Error getting new orders: $e');
      throw e;
    }
  }

  Future<void> showMyDialog({title, message, context}) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(message),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Đồng Ý'))
            ],
          );
        });
  }

  deleteBannerImagefromDb(id) async {
    homeBanner.doc(id).delete();
  }

  Future<void> cofirmDeleteDialog({title, message, context, id}) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(message),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Huỷ bỏ')),
              TextButton(
                  onPressed: () {
                    deleteBannerImagefromDb(id);
                    Navigator.of(context).pop();
                  },
                  child: Text('Xoá'))
            ],
          );
        });
  }

  Future<void> saveCoupon({
    document,
    title,
    discountRate,
    expiry,
    details,
    active,
  }) async {
    try {
      if (document == null) {
        // Adding a new coupon
        await maGiamGia.doc(title).set({
          'tengiamgia': title,
          '%giamgia': discountRate,
          'ngayhethan': expiry,
          'motagiamgia': details,
          'trangthai': active,
        });
      } else {
        // Updating an existing coupon
        await maGiamGia.doc(document.id).update({
          'tengiamgia': title,
          '%giamgia': discountRate,
          'ngayhethan': expiry,
          'motagiamgia': details,
          'trangthai': active,
        });
      }
      print('Coupon saved successfully!');
    } catch (error) {
      print('Error saving coupon: $error');
      // Add more detailed error handling as needed
    }
  }

  Future<void> saveKhoHang(
      {document, maKhoHang, diaChi, nguoiQuanLy, sdtQuanLy, active}) async {
    try {
      final khoHangRef = nhaKho.doc(maKhoHang);

      // Kiểm tra xem document có tồn tại hay không
      final khoHangDoc = await khoHangRef.get();

      if (khoHangDoc.exists) {
        await khoHangRef.update({
          'MaKhoHang': maKhoHang,
          'DiaChi': diaChi,
          'NguoiQuanLy': nguoiQuanLy,
          'SdtQuanLy': sdtQuanLy,
          'trangthai': active,
        });
      } else {
        await khoHangRef.set({
          'MaKhoHang': maKhoHang,
          'DiaChi': diaChi,
          'NguoiQuanLy': nguoiQuanLy,
          'SdtQuanLy': sdtQuanLy,
          'trangthai': active,
        });
      }

      print('Lưu thành công');
    } catch (e) {
      print('Lỗi khi lưu: $e');
    }
  }

  Future<void> saveProductVitri({
    document,
    maSP,
    tenSP,
    makhoHang,
    active,
  }) async {
    try {
      final sanPhamRef = sanPham.doc(maSP);

      final sanPhamDoc = await sanPhamRef.get();

      if (sanPhamDoc.exists) {
        await sanPhamRef.update({
          'TenSP': tenSP,
          'MaKhoHang': makhoHang,
          'trangthai': active,
        });
      } else {
        await sanPhamRef.set({
          'MaSP': maSP,
          'TenSP': tenSP,
          'MaKhoHang': makhoHang,
          'trangthai': active,
        });
      }

      print('Lưu thành công');
    } catch (e) {
      print('Lỗi khi lưu: $e');
    }
  }

  Future<int> getTotalOrders() async {
    // Thực hiện truy vấn để lấy tổng số lượng đơn hàng
    QuerySnapshot query = await firestore.collection('donhang').get();
    return query.docs.length;
  }

  Future<double> getTotalRevenue() async {
    // Thực hiện truy vấn để lấy tổng doanh thu
    QuerySnapshot query = await firestore.collection('donhang').get();
    double totalRevenue = 0.0;
    for (QueryDocumentSnapshot doc in query.docs) {
      totalRevenue += doc['tongdon']?.toDouble() ?? 0.0;
    }
    return totalRevenue;
  }

  Future<int> getTotalOrdersInDay(DateTime date) async {
    DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    String startOfDayString = startOfDay.toUtc().toIso8601String();
    String endOfDayString = endOfDay.toUtc().toIso8601String();

    QuerySnapshot query = await firestore
        .collection('donhang')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDayString)
        .where('timestamp', isLessThanOrEqualTo: endOfDayString)
        .get();

    return query.docs.length;
  }

  Future<int> getTotalOrdersInMonth(DateTime date) async {
    DateTime startOfMonth = DateTime(date.year, date.month, 1, 0, 0, 0);
    DateTime endOfMonth = DateTime(date.year, date.month + 1, 0, 0, 0, 0);

    String startOfMonthString = startOfMonth.toUtc().toIso8601String();
    String endOfMonthString = endOfMonth.toUtc().toIso8601String();

    QuerySnapshot query = await firestore
        .collection('donhang')
        .where('timestamp', isGreaterThanOrEqualTo: startOfMonthString)
        .where('timestamp', isLessThan: endOfMonthString)
        .get();

    return query.docs.length;
  }

  int _getTimestampFromDate(DateTime date) {
    return date.millisecondsSinceEpoch ~/ 1000;
  }

  Future<List<int>> getDailyOrdersData(DateTime date) async {
    DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    String startOfDayString = startOfDay.toUtc().toIso8601String();
    String endOfDayString = endOfDay.toUtc().toIso8601String();

    QuerySnapshot query = await firestore
        .collection('donhang')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDayString)
        .where('timestamp', isLessThanOrEqualTo: endOfDayString)
        .get();

    List<int> dailyOrdersData = [];

    for (QueryDocumentSnapshot doc in query.docs) {
      dailyOrdersData.add(1); // Add 1 for each order
    }

    return dailyOrdersData;
  }

  Future<double> getTotalRevenueInDay(DateTime selectedDate) async {
    int startTimestamp = _getTimestampFromDate(selectedDate);
    int endTimestamp = startTimestamp + 86399; // 23:59:59

    QuerySnapshot query = await firestore
        .collection('donhang')
        .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
        .where('timestamp', isLessThanOrEqualTo: endTimestamp)
        .get();

    double totalRevenue = 0.0;

    for (QueryDocumentSnapshot doc in query.docs) {
      totalRevenue += doc['tongdon']?.toDouble() ?? 0.0;
    }

    return totalRevenue;
  }

  Future<double> getTotalRevenueInMonth(DateTime selectedDate) async {
    DateTime startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    DateTime endOfMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0, 23, 59, 59);

    QuerySnapshot query = await firestore
        .collection('donhang')
        .where('timestamp',
            isGreaterThanOrEqualTo: startOfMonth.millisecondsSinceEpoch ~/ 1000)
        .where('timestamp',
            isLessThanOrEqualTo: endOfMonth.millisecondsSinceEpoch ~/ 1000)
        .get();

    double totalRevenue = 0.0;

    for (QueryDocumentSnapshot doc in query.docs) {
      totalRevenue += doc['tongdon']?.toDouble() ?? 0.0;
    }

    return totalRevenue;
  }
}
