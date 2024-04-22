import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticalScreen extends StatefulWidget {
  static const String id = 'statistical-screen';
  const StatisticalScreen({Key? key}) : super(key: key);

  @override
  State<StatisticalScreen> createState() => _StatisticalScreenState();
}

class _StatisticalScreenState extends State<StatisticalScreen> {
  Future<num> calculateTotalRevenue() async {
    try {
      QuerySnapshot orderSnapshot =
          await FirebaseFirestore.instance.collection('donhang').get();

      num totalRevenue = 0;

      for (QueryDocumentSnapshot order in orderSnapshot.docs) {
        totalRevenue += (order['tongdon'] ?? 0) as num;
      }

      return totalRevenue;
    } catch (e) {
      return 0;
    }
  }

  Future<int> calculateTotalOrders() async {
    try {
      QuerySnapshot orderSnapshot =
          await FirebaseFirestore.instance.collection('donhang').get();

      return orderSnapshot.size;
    } catch (e) {
      return 0;
    }
  }

  Future<int> calculateCategoryCount() async {
    try {
      QuerySnapshot categorySnapshot =
          await FirebaseFirestore.instance.collection('DanhMuc').get();

      return categorySnapshot.size;
    } catch (e) {
      return 0;
    }
  }

  Future<int> calculateCategorySubCount() async {
    try {
      QuerySnapshot categorySnapshot =
          await FirebaseFirestore.instance.collection('DanhMucPhu').get();

      return categorySnapshot.size;
    } catch (e) {
      return 0;
    }
  }

  Future<int> calculateCategoryMainCount() async {
    try {
      QuerySnapshot categorySnapshot =
          await FirebaseFirestore.instance.collection('DanhMucChinh').get();

      return categorySnapshot.size;
    } catch (e) {
      return 0;
    }
  }

  Future<int> calculateUserAccount() async {
    try {
      QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
          .collection('TaiKhoanNguoiDung')
          .get();

      return categorySnapshot.size;
    } catch (e) {
      return 0;
    }
  }

  Future<int> calculateProductCount() async {
    try {
      QuerySnapshot productSnapshot =
          await FirebaseFirestore.instance.collection('SanPham').get();
      return productSnapshot.size;
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, num>> calculatePaymentMethodCount() async {
    try {
      QuerySnapshot orderSnapshot =
          await FirebaseFirestore.instance.collection('donhang').get();

      int cardPayments = 0;
      int cashPayments = 0;

      for (QueryDocumentSnapshot order in orderSnapshot.docs) {
        bool paymentMethod = order['cod'] ?? false;

        if (paymentMethod) {
          cardPayments++;
        } else {
          cashPayments++;
        }
      }

      return {'card': cardPayments, 'cash': cashPayments};
    } catch (e) {
      return {'card': 0, 'cash': 0};
    }
  }

  Future<Map<String, int>> calculateOrdersPerDay() async {
    try {
      DateTime now = DateTime.now();
      DateTime startDate = DateTime(now.year, now.month, now.day - 6);
      DateTime endDate = now;

      QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('donhang')
          .where('timestamp', isGreaterThanOrEqualTo: startDate.toString())
          .where('timestamp', isLessThanOrEqualTo: endDate.toString())
          .get();

      Map<String, int> ordersPerDay = {};

      for (QueryDocumentSnapshot order in orderSnapshot.docs) {
        DateTime orderDate = DateTime.parse(order['timestamp']);
        String dayOfWeek = DateFormat('EEEE').format(orderDate);

        // Translate day names to Vietnamese
        switch (dayOfWeek) {
          case 'Monday':
            dayOfWeek = 'Thứ 2';
            break;
          case 'Tuesday':
            dayOfWeek = 'Thứ 3';
            break;
          case 'Wednesday':
            dayOfWeek = 'Thứ 4';
            break;
          case 'Thursday':
            dayOfWeek = 'Thứ 5';
            break;
          case 'Friday':
            dayOfWeek = 'Thứ 6';
            break;
          case 'Saturday':
            dayOfWeek = 'Thứ 7';
            break;
          case 'Sunday':
            dayOfWeek = 'Chủ nhật';
            break;
          default:
            break;
        }

        ordersPerDay.update(
          dayOfWeek,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }

      return ordersPerDay;
    } catch (e) {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          calculateTotalRevenue(),
          calculateCategoryCount(),
          calculateCategoryMainCount(),
          calculateCategorySubCount(),
          calculateProductCount(),
          calculateUserAccount(),
          calculateTotalOrders(),
          calculatePaymentMethodCount(),
          calculateOrdersPerDay(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (snapshot.data != null) {
            num totalRevenue = snapshot.data?[0] as num;
            int categoryCount = snapshot.data?[1] as int;

            int categoryCountMain = snapshot.data?[2] as int;
            int categoryCountSub = snapshot.data?[3] as int;

            int productCount = snapshot.data?[4] as int;

            int productUser = snapshot.data?[5] as int;
            int ordersCount = snapshot.data?[6] as int;

            String formattedTotalRevenue =
                NumberFormat('#,###,###').format(totalRevenue);

            Map<String, num> paymentMethodCount =
                snapshot.data?[7] as Map<String, num>;
            Map<String, int> ordersPerDay =
                snapshot.data?[8] as Map<String, int>;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'THỐNG KÊ TỔNG QUAN',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSquare('Doanh thu', '$formattedTotalRevenue VND'),
                      _buildSquare('Danh mục', '$categoryCount'),
                      _buildSquare('Danh mục chính', '$categoryCountMain'),
                      _buildSquare('Danh mục phụ', '$categoryCountSub'),
                      _buildSquare('Sản phẩm', '$productCount'),
                      _buildSquare('Tài khoản người dùng', '$productUser'),
                      _buildSquare('Tổng số đơn hàng', '$ordersCount'),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPaymentCount(
                          'Thẻ', paymentMethodCount['card']?.toString() ?? '0'),
                      Column(
                        children: [
                          SizedBox(
                            height: 200,
                            width: 200,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.blue,
                                    value: paymentMethodCount['card']
                                            ?.toDouble() ??
                                        0,
                                    title: 'Thẻ',
                                    radius: 50,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.green,
                                    value: paymentMethodCount['cash']
                                            ?.toDouble() ??
                                        0,
                                    title: 'Mặt',
                                    radius: 50,
                                  ),
                                ],
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 0,
                              ),
                            ),
                          ),
                          const Text(
                            'Biểu đồ thể hiện thói quen thanh toán',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      _buildPaymentCount(
                          'Mặt', paymentMethodCount['cash']?.toString() ?? '0'),
                      Column(
                        children: [
                          SizedBox(
                            height: 200,
                            width: 200,
                            child: PieChart(
                              PieChartData(
                                sections: ordersPerDay.keys.map((day) {
                                  int colorIndex =
                                      ordersPerDay.keys.toList().indexOf(day) %
                                          predefinedColors.length;

                                  return PieChartSectionData(
                                    color: predefinedColors[colorIndex],
                                    value: ordersPerDay[day]?.toDouble() ?? 0,
                                    title: day,
                                    radius: 50,
                                  );
                                }).toList(),
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 0,
                              ),
                            ),
                          ),
                          const Text(
                            'Biểu đồ thể hiện số đơn hàng theo từng ngày trong 1 tuần',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Display the contributor's name below the PieChart

                  const SizedBox(
                    height: 20,
                  ),
                  // Display the contributor's name below the PieChart
                ],
              ),
            );
          } else {
            return const Center(child: Text('Data is null'));
          }
        },
      ),
    );
  }

  Widget _buildPaymentCount(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSquare(String title, String value) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> predefinedColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    // Add more colors as needed
  ];
}
