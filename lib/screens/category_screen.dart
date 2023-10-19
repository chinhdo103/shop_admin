import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});
  static const String id = 'category';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.all(10),
          child: const Text(
            'Danh Mục',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 26,
            ),
          ),
        ),
        const Divider(
          color: Colors.grey,
        ),
        Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            Column(
              children: [
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.grey.shade800,
                    ),
                  ),
                  child: Center(child: Text('Ảnh Danh Mục')),
                ),
                ElevatedButton(onPressed: () {}, child: Text('Tải ảnh lên'))
              ],
            ),
            const SizedBox(
              width: 20,
            ),
            const SizedBox(
              width: 200,
              child: TextField(
                decoration: InputDecoration(
                    label: Text('Nhập tên danh mục'),
                    contentPadding: EdgeInsets.zero),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            TextButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                side: MaterialStateProperty.all(
                  BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
              child: Text(
                'Huỷ',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text(
                '  Lưu  ',
              ),
            ),
          ],
        ),
        const Divider(
          color: Colors.grey,
        ),
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.all(10),
          child: const Text(
            'Danh Sách Danh Mục',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
