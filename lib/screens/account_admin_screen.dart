import 'package:flutter/material.dart';
import 'package:project_9shop_admin/widgets/account_admin_list_widget.dart';
import 'package:project_9shop_admin/widgets/account_admin_widget.dart';

class AccountAdminScreen extends StatelessWidget {
  static const String id = 'AccountAdminScreen';
  const AccountAdminScreen({super.key});

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
          ));
    }

    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const AccountAdminWidget(),
          const Text(
            'Danh Sách Tài Khoản',
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
              _rowHeader(flex: 2, text: 'Họ và tên'),
              _rowHeader(flex: 3, text: 'Tài khoản'),
              _rowHeader(flex: 2, text: 'Mật khẩu'),
              _rowHeader(flex: 2, text: 'Vai trò'),
              _rowHeader(flex: 2, text: 'Trang thái'),
              _rowHeader(flex: 2, text: 'Hành động'),
              _rowHeader(flex: 2, text: 'Xoá'),
            ],
          ),
          const AccountAdminList()
        ],
      ),
    );
  }
}
