import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_9shop_admin/models/accoutuser_model.dart';
import 'package:project_9shop_admin/models/tkadmin_model.dart';
import 'package:project_9shop_admin/others/toast.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';

class AccountUserList extends StatefulWidget {
  const AccountUserList({super.key});

  @override
  State<AccountUserList> createState() => _AccountUserListState();
}

class _AccountUserListState extends State<AccountUserList> {
  final FirebaseServices _services = FirebaseServices();
  void _showUpdateInformationDialog(TaiKhoanNguoiDung taikhoan) {
    TextEditingController hoVaTenController =
        TextEditingController(text: taikhoan.ten ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cập nhật thông tin'),
          content: Column(
            mainAxisSize:
                MainAxisSize.min, // Ensure the Column takes minimum height
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: hoVaTenController,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
              ),
              // Add other form fields as needed
            ],
          ),
          contentPadding:
              const EdgeInsets.fromLTRB(24, 12, 24, 0), // Adjust padding
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Handle the update logic here
                await _updateInformation(
                  taikhoan,
                  hoVaTen: hoVaTenController.text,
                  // Include other form fields as needed
                );

                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateInformation(
    TaiKhoanNguoiDung taikhoan, {
    required String hoVaTen,
    // Add other form fields as needed
  }) async {
    try {
      await _services.updateData(
        data: {
          'HoVaTen': hoVaTen,
          // Update other fields accordingly
        },
        docName: taikhoan.id,
        reference: _services.taiKhoan,
      );

      // Show a success message or handle the update completion as needed
      print('Information updated successfully');
    } catch (e) {
      // Handle errors during the update process
      print('Error updating information: $e');
      // Show an error message or handle the error as needed
    }
  }

  //sửa
  void _showEditInformationDialog1(TaiKhoanNguoiDung taikhoan) {
    TextEditingController hoVaTenController =
        TextEditingController(text: taikhoan.ho ?? '');
    TextEditingController taiKhoanController =
        TextEditingController(text: taikhoan.ten ?? '');
    TextEditingController matKhauController =
        TextEditingController(text: taikhoan.sdt ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sửa thông tin'),
          content: Column(
            mainAxisSize:
                MainAxisSize.min, // Ensure the Column takes minimum height
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: hoVaTenController,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
              ),
              TextFormField(
                controller: taiKhoanController,
                decoration: const InputDecoration(labelText: 'Tài Khoản '),
              ),
              TextFormField(
                controller: matKhauController,
                decoration: const InputDecoration(labelText: 'Mật Khẩu'),
              ),

              // Add other form fields as needed
            ],
          ),
          contentPadding:
              const EdgeInsets.fromLTRB(24, 12, 24, 0), // Adjust padding
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Handle the update logic here
                await _editInformation(
                  taikhoan,
                  hoVaTen: hoVaTenController.text,
                  taiKhoan: taiKhoanController.text,
                  matKhau: matKhauController.text,

                  // Include other form fields as needed
                );

                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editInformation(
    TaiKhoanNguoiDung taikhoan, {
    required String hoVaTen,
    required String taiKhoan,
    required String matKhau,
    // Add other form fields as needed
  }) async {
    try {
      await _services.updateData(
        data: {
          'HoVaTen': hoVaTen,
          'TenTK': taiKhoan,
          'MatKhau': matKhau,
          // Update other fields accordingly
        },
        docName: taikhoan.id,
        reference: _services.taiKhoan,
      );

      // Show a success message or handle the update completion as needed
      HienThiThongBaoDung('Sửa thông tin thành công');
    } catch (e) {
      // Handle errors during the update process
      print('Error updating information: $e');
      // Show an error message or handle the error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    // ignore: no_leading_underscores_for_local_identifiers
    Widget _accountData({int? flex, String? text, Widget? widget}) {
      return Expanded(
        flex: flex!,
        child: Container(
          height: 70,
          decoration:
              BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget ?? Text(text ?? 'Chưa cập nhật'),
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _services.taiKhoanNguoiDung.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.size,
          itemBuilder: (context, index) {
            TaiKhoanNguoiDung taikhoan = TaiKhoanNguoiDung.fromJson(
                snapshot.data!.docs[index].data() as Map<String, dynamic>);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _accountData(flex: 2, text: taikhoan.id),
                _accountData(flex: 2, text: taikhoan.sdt),
                _accountData(flex: 2, text: taikhoan.ho),
                _accountData(flex: 2, text: taikhoan.ten),
                _accountData(flex: 2, text: taikhoan.email),
                _accountData(flex: 3, text: taikhoan.diachi),
                // _accountData(
                //   flex: 2,
                //   widget: ElevatedButton(
                //     style: ButtonStyle(
                //       backgroundColor: MaterialStateProperty.all(
                //         Colors.blue,
                //       ),
                //     ),
                //     onPressed: () {
                //       _showEditInformationDialog1(taikhoan);
                //     },
                //     child: const Text(
                //       'Xem chi tiết / Sửa',
                //       textAlign: TextAlign.center,
                //       style: TextStyle(color: Colors.white),
                //     ),
                //   ),
                // ),
                _accountData(
                  flex: 2,
                  widget: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Xác nhận xoá tài khoản'),
                            content: const Text(
                                'Bạn có chắc muốn xoá tài khoản này không?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await _deleteAccount(taikhoan);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Đồng ý'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Xoá Tài Khoản',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteAccount(TaiKhoanNguoiDung taikhoan) async {
    try {
      await _services.deleteData(
        docName: taikhoan.id,
        reference: _services.taiKhoanNguoiDung,
      );

      HienThiThongBaoDung('Xoá tài khoản thành công');
    } catch (e) {
      print('Error deleting account: $e');
      HienThiThongBaoSai('Xoá tài khoản thất bại');
    }
  }
}
