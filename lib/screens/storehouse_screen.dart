import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_9shop_admin/screens/add_edit_storehouse_screen.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';

class StoreHouse extends StatefulWidget {
  static const String id = 'store-house';
  const StoreHouse({super.key});

  @override
  State<StoreHouse> createState() => _StoreHouseState();
}

class _StoreHouseState extends State<StoreHouse> {
  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    FirebaseServices _services = FirebaseServices();

    return SizedBox(
      child: StreamBuilder<QuerySnapshot>(
        stream: _services.nhaKho.snapshots(),
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
                            builder: (context) =>
                                const AddEditStoreHouseScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Thêm nhà kho mới',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              FittedBox(
                child: DataTable(columns: const <DataColumn>[
                  DataColumn(
                    label: Text('Mã nhà kho'),
                  ),
                  DataColumn(
                    label: Text('Địa chỉ nhà kho'),
                  ),
                  DataColumn(
                    label: Text('Tên người quản lý'),
                  ),
                  DataColumn(
                    label: Text('Số điện thoại quản lý'),
                  ),
                  DataColumn(
                    label: Text('Trạng thái nhà kho'),
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
              return DataRow(
                cells: [
                  DataCell(Text(
                      (document.data() as Map<String, dynamic>)['MaKhoHang'] ??
                          '')),
                  DataCell(Text(
                      (document.data() as Map<String, dynamic>)['DiaChi'] ??
                          '')),
                  DataCell(Text((document.data()
                          as Map<String, dynamic>)['NguoiQuanLy'] ??
                      '')),
                  DataCell(Text(
                      (document.data() as Map<String, dynamic>)['SdtQuanLy'] ??
                          '')),
                  DataCell(Text(
                      (document.data() as Map<String, dynamic>)['trangthai']
                          ? 'Kích Hoạt'
                          : 'Không Kích Hoạt')),
                  DataCell(IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditStoreHouseScreen(
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
