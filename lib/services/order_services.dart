import 'package:cloud_firestore/cloud_firestore.dart';

class OrderServices {
  CollectionReference orders = FirebaseFirestore.instance.collection('donhang');

  updateOrderStatus(documentId, status) {
    var resutl = orders.doc(documentId).update({
      'trangthaidh': status,
    });
    return resutl;
  }
}
