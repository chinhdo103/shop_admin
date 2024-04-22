import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';
import 'package:project_9shop_admin/widgets/main_categories_list_widget.dart';

class MainCategoryScreen extends StatefulWidget {
  const MainCategoryScreen({super.key});
  static const String id = 'main-category';

  @override
  State<MainCategoryScreen> createState() => _MainCategoryScreenState();
}

class _MainCategoryScreenState extends State<MainCategoryScreen> {
  final FirebaseServices _services = FirebaseServices();
  final TextEditingController _mainTen = TextEditingController();
  Object? _selectedValue;
  final _formKey = GlobalKey<FormState>();
  bool _noCategorySelected = false;
  QuerySnapshot? snapshot;

  Widget _dropDownButton() {
    return DropdownButton(
        value: _selectedValue,
        hint: const Text('Chọn danh mục chính'),
        items: snapshot!.docs.map((e) {
          return DropdownMenuItem<String>(
              value: e['TenDanhMuc'], child: Text(e['TenDanhMuc']));
        }).toList(),
        onChanged: (selectedTenDM) {
          setState(() {
            _selectedValue = selectedTenDM;
            _noCategorySelected = false;
          });
        });
  }

  //trả các ô input và selectec về trạng thái ban đầu
  clear() {
    setState(() {
      _selectedValue = null;
      _mainTen.clear();
    });
    Fluttertoast.showToast(
        msg: "Xoá các thông tin đã nhập thành công",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        textColor: Colors.white,
        // webBgColor: "linear-gradient(to right, #dc1c13, #dc1c13)",
        webPosition: "center",
        webShowClose: false,
        fontSize: 16.0);
  }

  //fix lỗi mỗi lần khi chọn value trong dropdown button thì đều load lại
  @override
  void initState() {
    getDanhSachDanhMuc();
    super.initState();
  }

  getDanhSachDanhMuc() {
    return _services.danhmuc.get().then((QuerySnapshot querySnapshot) {
      setState(() {
        snapshot = querySnapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Danh Mục Chính',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 36,
                ),
              ),
            ),
            const Divider(
              color: Colors.grey,
            ),
            snapshot == null
                ? const Text('Loading..')
                :
                //drop down list in main category
                _dropDownButton(),
            const SizedBox(
              height: 8,
            ),
            if (_noCategorySelected == true)
              const Text(
                'không có danh mục nào được chọn',
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(
              width: 200,
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Hãy nhập tên danh mục chính";
                  }
                  return null;
                },
                controller: _mainTen,
                decoration: const InputDecoration(
                    label: Text('Nhập tên danh mục'),
                    contentPadding: EdgeInsets.zero),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                TextButton(
                  onPressed: clear,
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
                    if (_selectedValue == null) {
                      setState(() {
                        _noCategorySelected = true;
                      });
                      return;
                    }
                    if (_formKey.currentState!.validate()) {
                      EasyLoading.show();
                      _services.saveData(
                        data: {
                          'danhmuc': _selectedValue,
                          'DanhMucChinh': _mainTen.text,
                          'trangthai': true
                        },
                        reference: _services.danhmucchinh,
                        docName: _mainTen.text,
                      ).then((value) {
                        clear();
                        EasyLoading.dismiss();
                        Fluttertoast.showToast(
                            msg: "Đã thêm danh mục chính",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 2,
                            textColor: Colors.white,
                            // webBgColor: "linear-gradient(to right, #dc1c13, #dc1c13)",
                            webPosition: "center",
                            webShowClose: false,
                            fontSize: 16.0);
                      });
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
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Danh Sách Danh Mục Chính',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const MainCategoryListWidget()
          ],
        ),
      ),
    );
  }
}



//màn hình danh mục chính