import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';

class InventoryInputScreen extends StatefulWidget {
  const InventoryInputScreen({super.key});

  @override
  State<InventoryInputScreen> createState() => _InventoryInputScreenState();
}

class Product {
  final String id;
  final String name;
  final int quantity;

  Product({required this.id, required this.name, required this.quantity});
}

class _InventoryInputScreenState extends State<InventoryInputScreen> {
  FirebaseServices _services = FirebaseServices();
  List<Product> products = [];
  Map<String, int> quantityMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nhập Kho'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _services.sanPham.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          products = snapshot.data!.docs.map((document) {
            return Product(
              id: (document.data() as Map<String, dynamic>)['MaSP'],
              name: (document.data() as Map<String, dynamic>)['TenSP'],
              quantity:
                  (document.data() as Map<String, dynamic>)['SoLuong'] ?? 0,
            );
          }).toList();

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(products[index].name),
                subtitle: Text('Số lượng: ${products[index].quantity}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    _showQuantityDialog(context, products[index]);
                  },
                  child: const Text('Nhập số lượng'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _confirmQuantityChanges();
          Navigator.pop(context);
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  Future<void> _showQuantityDialog(
      BuildContext context, Product product) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nhập số lượng cho ${product.name}'),
          content: TextField(
            controller: TextEditingController(
                text: quantityMap[product.id]?.toString() ?? ''),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              quantityMap[product.id] = int.tryParse(value) ?? 0;
            },
            decoration: const InputDecoration(labelText: 'Số lượng'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  void _confirmQuantityChanges() {
    // Iterate through the quantityMap and update quantities for selected products
    for (var entry in quantityMap.entries) {
      _updateQuantity(products.firstWhere((product) => product.id == entry.key),
          entry.value);
      _updateHistory(products.firstWhere((product) => product.id == entry.key),
          entry.value);
    }

    // Clear quantityMap after updating quantities
    quantityMap.clear();
  }

  Future<void> _updateQuantity(Product product, int quantity) async {
    try {
      await _services.sanPham.doc(product.id).update({
        'SoLuong': FieldValue.increment(quantity),
      });
    } catch (e, stackTrace) {
      // Handle the update error
      // ignore: avoid_print
      print('Lỗi khi cập nhật số lượng: $e');
      // ignore: avoid_print
      print(stackTrace);
    }
  }

  Future<void> _updateHistory(Product product, int quantity) async {
    try {
      // Create a timestamp for the current date and time
      Timestamp timestamp = Timestamp.now();

      // Add an entry to the history collection
      await _services.lichsunhap.add({
        'MaSP': product.id,
        'TenSP': product.name,
        'SoLuongNhap': quantity,
        'ThoiGianNhap': timestamp,
      });
    } catch (e, stackTrace) {
      // Handle the history update error
      // ignore: avoid_print
      print('Lỗi khi cập nhật lịch sử nhập hàng: $e');
      // ignore: avoid_print
      print(stackTrace);
    }
  }
}
