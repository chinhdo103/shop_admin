import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:project_9shop_admin/others/toast.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class AccountAdminWidget extends StatefulWidget {
  const AccountAdminWidget({super.key});

  @override
  State<AccountAdminWidget> createState() => _AccountAdminWidgetState();
}

class _AccountAdminWidgetState extends State<AccountAdminWidget> {
  final FirebaseServices _services = FirebaseServices();
  final TextEditingController _mainTen = TextEditingController();
  final TextEditingController _mainmk = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  QuerySnapshot? snapshot;
  String _selectedRole = 'Quản lý';

  final Uuid uuid = const Uuid();

  String generateRandomDocName() {
    return 'doc_${uuid.v4()}';
  }

  void _clear() {
    _mainTen.clear();
    _mainmk.clear();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(10),
            child: const Text(
              'Quản Lí Tài Khoản Admin',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 36,
              ),
            ),
          ),
          const Divider(
            color: Colors.grey,
          ),
          //drop down list in main category
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            width: 200,
            child: TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Hãy nhập tên tài khoản";
                }
                return null;
              },
              controller: _mainTen,
              decoration: const InputDecoration(
                  label: Text('Nhập tên tài khoản'),
                  contentPadding: EdgeInsets.zero),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 200,
            child: TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Hãy nhập mật khẩu";
                }
                return null;
              },
              controller: _mainmk,
              decoration: const InputDecoration(
                  label: Text('Nhập mật khẩu'),
                  contentPadding: EdgeInsets.zero),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          DropdownButton<String>(
            value: _selectedRole,
            onChanged: (String? newValue) {
              setState(() {
                _selectedRole = newValue!;
              });
            },
            items: <String>['Quản lý', 'Nhân viên']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  _clear();
                },
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
              //nút lưu chỉ hiển thị khi hình ảnh được chọn

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    String randomDocName = generateRandomDocName();
                    EasyLoading.show();
                    _services.saveData(
                      data: {
                        'MaTK': randomDocName,
                        'HoVaTen': null,
                        'TenTK': _mainTen.text,
                        'MatKhau': _mainmk.text,
                        'TrangThai': 'Kích hoạt',
                        'VaiTro': _selectedRole,
                      },
                      reference: _services.taiKhoan,
                      docName: randomDocName,
                    ).then(
                      (value) {
                        EasyLoading.dismiss();
                        HienThiThongBaoDung('Đã thêm tài khoản admin');
                        _clear();
                      },
                    );
                  }
                },
                child: const Text(
                  '  Lưu  ',
                ),
              ),
            ],
          ),
          const Divider(
            color: Colors.grey,
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
