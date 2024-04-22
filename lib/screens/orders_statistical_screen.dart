import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrdersStatisticalScreen extends StatefulWidget {
  static const String id = 'orders-statistical-screen';

  const OrdersStatisticalScreen({Key? key}) : super(key: key);

  @override
  State<OrdersStatisticalScreen> createState() =>
      _OrdersStatisticalScreenState();
}

class _OrdersStatisticalScreenState extends State<OrdersStatisticalScreen> {
  DateTime selectedDate = DateTime.now();

  double calculateTotalRevenue(List<DocumentSnapshot> orders) {
    return orders
        .map((order) => (order['tongdon'] ?? 0) as double)
        .fold(0, (prev, amount) => prev + amount);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Chọn ngày: ${DateFormat('dd-MM-yyyy').format(selectedDate)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2022),
                    lastDate: DateTime(2025),
                  );

                  if (picked != null && picked != selectedDate) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: const Text('Chọn ngày'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Các đơn hàng trong ngày đã chọn:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('donhang').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Loading indicator while waiting for data
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                // Display error message if there's an error
                return Text('Error: ${snapshot.error}');
              }

              List<DocumentSnapshot> orders =
                  snapshot.data!.docs.where((order) {
                DateTime orderDate = DateTime.parse(order['timestamp']);
                return orderDate.isAfter(selectedDate) &&
                    orderDate
                        .isBefore(selectedDate.add(const Duration(days: 1)));
              }).toList();

              return Column(
                children: [
                  if (orders.isEmpty)
                    // Display a message when there are no orders
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Không có đơn hàng nào được đặt trong ngày được chọn',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order =
                          orders[index].data() as Map<String, dynamic>;
                      final products = order['SanPham'] as List<dynamic>;

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('Đơn hàng ${index + 1}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text('Tên khách hàng: ${order['tennguoidung']}',
                                  style: TextStyle(fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(
                                  'Tổng đơn: ${NumberFormat('#,###,###').format(order['tongdon'])} VND',
                                  style: TextStyle(fontSize: 16)),
                              const SizedBox(height: 8),
                              Text('Sản phẩm trong đơn:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              // Use a ListView.builder for the products
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: products.length,
                                itemBuilder: (context, productIndex) {
                                  final product = products[productIndex];
                                  return ListTile(
                                    title: Text(
                                        'Sản phẩm ${productIndex + 1}: ${product['TenSP']}'),
                                    subtitle: Text(
                                        'Số lượng: ${product['SoLuong']} | Giá: ${NumberFormat('#,###,###').format(product['GiaSP'])} VND'),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  Text(
                    'Tổng doanh thu của ngày: ${NumberFormat('#,###,###').format(calculateTotalRevenue(orders))} VND',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
