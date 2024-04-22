import 'package:flutter/material.dart';
import 'package:project_9shop_admin/provider/product_provider.dart';
import 'package:provider/provider.dart';

class GeneralTab extends StatefulWidget {
  static const String id = "general-tab";
  const GeneralTab({super.key});

  @override
  State<GeneralTab> createState() => _GeneralTabState();
}

class _GeneralTabState extends State<GeneralTab> {
  Widget _fromField(
      {String? label,
      TextInputType? inputType,
      void Function(String)? onChanged}) {
    return TextFormField(
      keyboardType: inputType,
      decoration: InputDecoration(
        label: Text(label!),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return label;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _provider = Provider.of<ProductProvider>(context);
    return Consumer<ProductProvider>(builder: (context, provider, child) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          _fromField(
            label: 'Nhập tên sản phẩm',
            inputType: TextInputType.name,
            onChanged: (value) {
              //save
              provider.getFormData(tenSanPham: value);
            },
          ),
          ElevatedButton(
            onPressed: () {
              print(_provider.productData!['tenSanPham']);
            },
            child: Text('data'),
          )
        ]),
      );
    });
  }
}
