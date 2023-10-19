import 'package:flutter/material.dart';

class DashBoardScreen extends StatelessWidget {
  static const String id = 'dashboard';
  const DashBoardScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(10),
      child: const Text(
        'Dashboard ok',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 36,
        ),
      ),
    );
  }
}
