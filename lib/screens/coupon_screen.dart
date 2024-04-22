import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_9shop_admin/screens/add_edit_coupon_screen.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';
import 'package:intl/date_symbol_data_local.dart';

class CouponScreen extends StatelessWidget {
  static const String id = 'coupon-screen';
  const CouponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseServices _services = FirebaseServices();
    initializeDateFormatting('vi_VN', null);

    return SizedBox(
      child: StreamBuilder<QuerySnapshot>(
        stream: _services.maGiamGia.where('trangthai').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(
                              Colors.blue.shade900)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddEditCouponScreen(
                              document: null,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Thêm mã giảm giá mới',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              FittedBox(
                child: DataTable(columns: const <DataColumn>[
                  DataColumn(
                    label: Text('Tên mã giảm giá'),
                  ),
                  DataColumn(
                    label: Text('% giảm giá'),
                  ),
                  DataColumn(
                    label: Text('Trạng thái'),
                  ),
                  DataColumn(
                    label: Text('Ngày hết hạn'),
                  ),
                  DataColumn(
                    label: Text('Sửa/Xem chi tiết'),
                  ),
                  DataColumn(
                    label: Text('Xóa'),
                  ),
                ], rows: _couponList(snapshot.data, context)),
              )
            ],
          );
        },
      ),
    );
  }

  List<DataRow> _couponList(QuerySnapshot? snapshot, context) {
    List<DataRow> newList = snapshot!.docs
        .map<DataRow?>(
          (DocumentSnapshot document) {
            var date = (document.data() as Map<String, dynamic>)['ngayhethan'];
            var expiry =
                DateFormat.yMMMd('vi_VN').add_jm().format(date.toDate());
            return DataRow(
              cells: [
                DataCell(Text(
                    (document.data() as Map<String, dynamic>)['tengiamgia'])),
                DataCell(Text(
                    '${(document.data() as Map<String, dynamic>)['%giamgia'].toString()}%')),
                DataCell(Text(
                    (document.data() as Map<String, dynamic>)['trangthai']
                        ? 'Kích Hoạt'
                        : 'Không Kích Hoạt')),
                DataCell(Text(expiry.toString())),
                DataCell(IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditCouponScreen(
                            document: document,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline_rounded))),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, document);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        )
        .whereType<DataRow>()
        .toList();

    return newList;
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, DocumentSnapshot document) async {
    FirebaseServices _services = FirebaseServices();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa mã giảm giá này?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _services.deleteCoupon(document); // Delete the coupon
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}
