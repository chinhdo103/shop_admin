import 'package:flutter/material.dart';

class MainCategoryScreen extends StatelessWidget {
  const MainCategoryScreen({super.key});
  static const String id = 'main-category';

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(10),
      child: const Text(
        'MainCategory',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 36,
        ),
      ),
    );
  }
}
