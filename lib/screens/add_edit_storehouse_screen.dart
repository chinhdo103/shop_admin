import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';

class AddEditStoreHouseScreen extends StatefulWidget {
  final DocumentSnapshot? document;

  static const String id = 'add-edit-store-house-screen';
  const AddEditStoreHouseScreen({super.key, this.document});

  @override
  State<AddEditStoreHouseScreen> createState() =>
      _AddEditStoreHouseScreenState();
}

class _AddEditStoreHouseScreenState extends State<AddEditStoreHouseScreen> {
  final _formKey = GlobalKey<FormState>();
  FirebaseServices _services = FirebaseServices();
  var maKhoHang = TextEditingController();
  var diaChi = TextEditingController();
  var nguoiQuanLy = TextEditingController();
  var sdtQuanLy = TextEditingController();

  bool _active = true;

  @override
  void initState() {
    if (widget.document != null) {
      final data = widget.document!.data() as Map<String, dynamic>;

      setState(() {
        maKhoHang.text = data['MaKhoHang'] ?? '';
        diaChi.text = data['DiaChi'] ?? '';
        nguoiQuanLy.text = data['NguoiQuanLy'] ?? '';
        sdtQuanLy.text = data['SdtQuanLy'] ?? '';
        _active = data['trangthai'] ?? false;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              controller: maKhoHang,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Nhập mã kho hàng';
                }
                return null;
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                labelText: 'Mã kho hàng',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            TextFormField(
              controller: diaChi,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Nhập địa chỉ kho hàng';
                }
                return null;
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                labelText: 'Địa chỉ kho hàng',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            TextFormField(
              controller: nguoiQuanLy,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Nhập họ và tên người quản lý';
                }
                return null;
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                labelText: 'Họ và tên người quản lý',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            TextFormField(
              controller: sdtQuanLy,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Nhập số điện thoại người quản lý';
                }
                return null;
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                labelText: 'Số điện thoại người quản lý',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            SwitchListTile(
              activeColor: Theme.of(context).primaryColor,
              contentPadding: EdgeInsets.zero,
              title: const Text('Trạng thái nhà kho'),
              value: _active,
              onChanged: (bool newValue) {
                setState(
                  () {
                    _active = !_active;
                  },
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                            Colors.blue.shade900)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        EasyLoading.show(status: 'Đang lưu...');
                        _services
                            .saveKhoHang(
                          document: widget.document,
                          maKhoHang: maKhoHang.text,
                          diaChi: diaChi.text,
                          nguoiQuanLy: nguoiQuanLy.text,
                          sdtQuanLy: sdtQuanLy.text,
                          active: _active,
                        )
                            .then((value) {
                          setState(() {
                            maKhoHang.clear();
                            diaChi.clear();
                            nguoiQuanLy.clear();
                            sdtQuanLy.clear();
                            _active = false;
                          });
                          EasyLoading.showSuccess('Lưu mã giảm giá thành công');
                          Navigator.pop(context);
                        });
                      }
                    },
                    child: const Text(
                      'Lưu mã giảm giá',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
