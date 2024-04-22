import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';

class AddEditCouponScreen extends StatefulWidget {
  static const String id = 'add-edit-coupon-screen';
  final DocumentSnapshot? document;

  const AddEditCouponScreen({super.key, required this.document});

  @override
  State<AddEditCouponScreen> createState() => _AddEditCouponScreenState();
}

class _AddEditCouponScreenState extends State<AddEditCouponScreen> {
  final _formKey = GlobalKey<FormState>();
  FirebaseServices _services = FirebaseServices();
  DateTime _selectedDate = DateTime.now();
  var dateText = TextEditingController();
  var titleText = TextEditingController();
  var phantramgiamgia = TextEditingController();
  var mota = TextEditingController();

  bool _active = false;

  _selectDate(context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        String formattedText = DateFormat('dd-MM-yyyy').format(_selectedDate);
        dateText.text = formattedText;
      });
    }
  }

  @override
  void initState() {
    if (widget.document != null) {
      final data = widget.document!.data() as Map<String, dynamic>;

      setState(() {
        titleText.text = data['tengiamgia'] ?? '';
        phantramgiamgia.text = (data['%giamgia'] ?? 0).toString();
        mota.text = data['motagiamgia'] ?? '';

        final ngayhethan = data['ngayhethan'];
        dateText.text =
            ngayhethan != null ? ngayhethan.toDate().toString() : '';

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
              controller: titleText,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Nhập tên mã giảm giá';
                }
                return null;
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                labelText: 'Tên mã giảm giá',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            TextFormField(
              controller: phantramgiamgia,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Nhập % giảm giá';
                }
                return null;
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                labelText: 'Nhập % mã giảm giá',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            TextFormField(
              controller: dateText,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Nhập ngày hết hạn mã giảm giá';
                }
                return null;
              },
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  labelText: 'Ngày hết hạn mã giảm giá',
                  labelStyle: const TextStyle(color: Colors.grey),
                  suffixIcon: InkWell(
                      onTap: () {
                        _selectDate(context);
                      },
                      child: Icon(Icons.date_range_outlined))),
            ),
            TextFormField(
              controller: mota,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Nhập mô tả mã giảm giá';
                }
                return null;
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                labelText: 'Mô tả mã giảm giá',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            SwitchListTile(
              activeColor: Theme.of(context).primaryColor,
              contentPadding: EdgeInsets.zero,
              title: const Text('Kích hoạt mã giảm giá'),
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
                            .saveCoupon(
                          document: widget.document,
                          title: titleText.text,
                          details: mota.text,
                          discountRate: int.parse(phantramgiamgia.text),
                          expiry: _selectedDate,
                          active: _active,
                        )
                            .then((value) {
                          setState(() {
                            titleText.clear();
                            mota.clear();
                            phantramgiamgia.clear();
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
