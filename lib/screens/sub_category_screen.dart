import 'package:flutter/material.dart';

class SubCategoryScreen extends StatelessWidget {
  const SubCategoryScreen({super.key});
  static const String id = 'sub-category';

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(10),
      child: const Text(
        'SubCategory',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 36,
        ),
      ),
    );
  }
}
