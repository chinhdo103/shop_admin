import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';

class DashBoardScreen extends StatefulWidget {
  static const String id = 'dashboard';

  const DashBoardScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  final FirebaseServices _firebaseService = FirebaseServices();
  late DateTime _selectedDate;
  List<int> dailyOrdersData = [];
  int productsBelow10 = 0;
  int productsBelow30 = 0;
  int productsAbove30 = 0;
  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadDailyOrdersData();
    _loadProductStatistics();
  }

  Future<void> _loadProductStatistics() async {
    int below30 = await _firebaseService.getProductsBelowQuantity(30);
    int above30 = await _firebaseService.getProductsAboveQuantity(30);

    setState(() {
      productsBelow30 = below30;
      productsAbove30 = above30;
    });
  }

  void _loadDailyOrdersData() async {
    List<int> data = await _firebaseService.getDailyOrdersData(_selectedDate);
    setState(() {
      dailyOrdersData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trang tổng quan',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: _buildDashboardItem(
                  'Tổng số đơn hàng',
                  () async => await _firebaseService.getTotalOrders(),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildDashboardItem(
                  'Tổng doanh thu',
                  () async => await _firebaseService.getTotalRevenue(),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildDashboardItem(
                  'Lượt đơn hàng mới trong ngày',
                  () async =>
                      await _firebaseService.getNewOrdersInDay(DateTime.now()),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildDashboardItem(
                  'Số đơn trong tháng',
                  () async => await _firebaseService
                      .getTotalOrdersInMonth(_selectedDate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20), // Adjust the spacing between the rows
          Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: _buildDashboardItem(
                  'Sản phẩm có số lượng tồn kho dưới 30',
                  () async => productsBelow30,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildDashboardItem(
                  'Sản phẩm có số lượng tồn kho trên 30',
                  () async => productsAbove30,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDashboardItem(String title, Future<dynamic> Function() getData) {
    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<dynamic>(
              future: getData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final formattedData = formatData(snapshot.data);

                  return Text(
                    formattedData,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String formatData(dynamic data) {
    // Format the data here using NumberFormat or any other formatting logic
    // For example, if data is a numeric value, you can format it as follows:
    return NumberFormat('#,###,###').format(data);
  }
}
