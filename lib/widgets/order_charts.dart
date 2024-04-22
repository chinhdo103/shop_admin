import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class OrderChart extends StatelessWidget {
  final List<int> orderData; // Dữ liệu số đơn hàng

  const OrderChart({Key? key, required this.orderData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          minX: 0,
          maxX: orderData.length.toDouble() - 1,
          minY: 0,
          maxY: orderData.reduce(
                  (value, element) => value > element ? value : element) +
              5,
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(orderData.length, (index) {
                return FlSpot(index.toDouble(), orderData[index].toDouble());
              }),
              isCurved: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
