import 'package:flutter/material.dart';
import 'package:project_9shop_admin/widgets/account_user_list_widget.dart';

class AccountUserScreen extends StatelessWidget {
  static const String id = 'AccountUserScreen';
  const AccountUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    Widget _rowHeader({int? flex, String? text}) {
      return Expanded(
        flex: flex!,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade700),
              color: Colors.grey.shade500),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            'Danh Sách Tài Khoản Khách Hàng',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              _rowHeader(flex: 2, text: 'Mã khách hàng'),
              _rowHeader(flex: 2, text: 'sdt'),
              _rowHeader(flex: 2, text: 'Họ '),
              _rowHeader(flex: 2, text: 'Tên'),
              _rowHeader(flex: 2, text: 'Tài khoản email'),
              _rowHeader(flex: 3, text: 'Địa chỉ'),
              _rowHeader(flex: 2, text: 'Xoá'),
            ],
          ),
          const AccountUserList(),
        ],
      ),
    );
  }
}
