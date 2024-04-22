import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_9shop_admin/screens/addedit_productstrore.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';

class ProductStore extends StatefulWidget {
  static const String id = 'product-store';
  const ProductStore({super.key});

  @override
  State<ProductStore> createState() => _ProductStoreState();
}

class _ProductStoreState extends State<ProductStore> {
  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    final FirebaseServices _services = FirebaseServices();

    return SizedBox(
      child: StreamBuilder<QuerySnapshot>(
        stream: _services.sanPham.orderBy('TenDanhMuc').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          return Column(
            children: [
              FittedBox(
                child: DataTable(columns: const <DataColumn>[
                  DataColumn(
                    label: Text('Mã SP'),
                  ),
                  DataColumn(
                    label: Text('Tên Sản Phẩm'),
                  ),
                  DataColumn(
                    label: Text('Nhóm danh mục'),
                  ),
                  DataColumn(
                    label: Text('Nhà kho'),
                  ),
                  DataColumn(
                    label: Text('Sửa/Xem chi tiết'),
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
            // ignore: unnecessary_null_comparison
            if (document != null) {
              String maSP =
                  (document.data() as Map<String, dynamic>)['MaSP'] ?? '';
              maSP = maSP.length > 11
                  ? '${maSP.substring(0, 11)}...'
                  : maSP; // chỉ hiển thị 5 ký tự đầu tiên

              return DataRow(
                cells: [
                  DataCell(Text(maSP)),
                  DataCell(Text(
                      (document.data() as Map<String, dynamic>)['TenSP'] ??
                          '')),
                  DataCell(Text(
                      (document.data() as Map<String, dynamic>)['TenDanhMuc'] ??
                          '')),
                  DataCell(Text(
                      (document.data() as Map<String, dynamic>)['MaKhoHang'] ??
                          '')),
                  DataCell(IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditStoreProductScreen(
                              document: document,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.info_outline_rounded)))
                ],
              );
            }
            return null;
          },
        )
        .whereType<DataRow>()
        .toList();

    return newList;
  }
}
