import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:project_9shop_admin/screens/inventory/input_inventory_screen.dart';
import 'package:project_9shop_admin/screens/inventory/inventory_input_screen.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';

class InventoryScreen extends StatefulWidget {
  static const String id = 'inventory-screen';

  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    FirebaseServices _services = FirebaseServices();
    return SizedBox(
      child: StreamBuilder<QuerySnapshot>(
        stream: _services.sanPham.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            EasyLoading.show(status: 'Đang tải dữ liệu...');
            return const CircularProgressIndicator();
          }
          EasyLoading.dismiss();
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
                            builder: (context) => const InventoryInputScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Nhập kho',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                          Colors.green.shade900,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const InventoryHistoryScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Xem lịch sử nhập',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              FittedBox(
                child: DataTable(columns: const <DataColumn>[
                  DataColumn(
                    label: Text('Chú ý'),
                  ),
                  DataColumn(
                    label: Text('Mã sản phẩm'),
                  ),
                  DataColumn(
                    label: Text('Tên sản phẩm'),
                  ),
                  DataColumn(
                    label: Text('Số lượng'),
                  ),
                  DataColumn(
                    label: Text('Trạng thái'),
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
            String maSP =
                (document.data() as Map<String, dynamic>)['MaSP'] ?? '';
            maSP = maSP.length > 7 ? '${maSP.substring(0, 7)}...' : maSP;

            // Extracting the quantity
            int quantity =
                (document.data() as Map<String, dynamic>)['SoLuong'] ?? 0;

            // Determine the background color based on the quantity range
            Color rowColor = _getRowColor(quantity);

// Increment the row index

            return DataRow(
              color: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  // Set the background color based on the quantity
                  return rowColor;
                },
              ),
              cells: [
                DataCell(Text(_getRowStatus(quantity))),
                DataCell(Text(maSP)),
                DataCell(SizedBox(
                  width: 400,
                  child: Text(
                    (document.data() as Map<String, dynamic>)['TenSP'] ?? '',
                  ),
                )),
                DataCell(Text(
                  quantity.toString(),
                )),
                DataCell(Text(
                    (document.data() as Map<String, dynamic>)['trangthai']
                        ? 'Kích Hoạt'
                        : 'Không Kích Hoạt')),
                DataCell(IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.info_outline_rounded)))
              ],
            );
          },
        )
        .whereType<DataRow>()
        .toList();

    return newList;
  }

  Color _getRowColor(int quantity) {
    // Set different colors based on the quantity range
    if (quantity <= 10) {
      return Colors.redAccent; // Red for quantity less than 10
    } else if (quantity <= 30) {
      return Colors.yellowAccent; // Yellow for quantity less than 30
    } else {
      return Colors.transparent; // Transparent for other cases
    }
  }

  String _getRowStatus(int quantity) {
    // Set different colors based on the quantity range
    if (quantity <= 10) {
      return 'Cần nhập hàng'; // Red for quantity less than 10
    } else if (quantity <= 30) {
      return 'Số lượng tồn kho thấp'; // Yellow for quantity less than 30
    } else {
      return 'Số lượng đủ'; // Transparent for other cases
    }
  }
}
