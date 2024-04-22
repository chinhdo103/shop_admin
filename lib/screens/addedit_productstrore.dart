import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';

class AddEditStoreProductScreen extends StatefulWidget {
  final DocumentSnapshot? document;

  static const String id = 'add-edit-store-procudut-house-screen';
  const AddEditStoreProductScreen({super.key, this.document});

  @override
  State<AddEditStoreProductScreen> createState() =>
      _AddEditStoreProductScreenState();
}

class _AddEditStoreProductScreenState extends State<AddEditStoreProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseServices _services = FirebaseServices();
  var maKhoHang = TextEditingController();
  var tenSP = TextEditingController();
  var maSP = TextEditingController();

  Object? _selectedValue;
  // ignore: unused_field
  bool _noCategorySelected = false;
  QuerySnapshot? snapshot;
  bool _active = true;
  Widget _dropDownButton() {
    return FutureBuilder(
      future: getDanhSachNhakho(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error loading data');
        } else {
          return DropdownButton(
            value: _selectedValue,
            hint: const Text('Chọn nhà kho chính'),
            items: (snapshot.data as QuerySnapshot).docs.map((e) {
              return DropdownMenuItem<String>(
                value: e['MaKhoHang'],
                child: Text(e['MaKhoHang']),
              );
            }).toList(),
            onChanged: (selectedValue) {
              setState(() {
                _selectedValue = selectedValue;
                _noCategorySelected = false;
              });
            },
          );
        }
      },
    );
  }

  @override
  void initState() {
    if (widget.document != null) {
      final data = widget.document!.data() as Map<String, dynamic>;

      setState(() {
        maKhoHang.text = data['MaKhoHang'] ?? '';
        tenSP.text = data['TenSP'] ?? '';
        maSP.text = data['MaSP'] ?? '';
        _active = data['trangthai'] ?? false;
      });
    }

    super.initState();
  }

  Future<QuerySnapshot> getDanhSachNhakho() async {
    return _services.nhaKho.get();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _dropDownButton(),
            TextFormField(
              controller: maSP,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Mã SP';
                }
                return null;
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                labelText: 'Mã SP',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            TextFormField(
              controller: tenSP,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Tên sản phẩm';
                }
                return null;
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                labelText: 'Tên sản phẩm',
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
                        Colors.blue.shade900,
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        EasyLoading.show(status: 'Đang lưu...');
                        _services
                            .saveProductVitri(
                          document: widget.document,
                          maSP: maSP.text,
                          tenSP: tenSP.text,
                          makhoHang: _selectedValue,
                          active: _active,
                        )
                            .then((value) {
                          setState(() {
                            maKhoHang.clear();
                            _active = false;
                          });
                          EasyLoading.showSuccess('Lưu sản phẩm thành công');
                          Navigator.pop(context);
                        });
                      }
                    },
                    child: const Text(
                      'Lưu sản phẩm',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
