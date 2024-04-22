import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_9shop_admin/models/tkadmin_model.dart';
import 'package:project_9shop_admin/others/toast.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';

class AccountAdminList extends StatefulWidget {
  const AccountAdminList({super.key});

  @override
  State<AccountAdminList> createState() => _AccountAdminListState();
}

class _AccountAdminListState extends State<AccountAdminList> {
  final FirebaseServices _services = FirebaseServices();

  void _showUpdateInformationDialog(TaiKhoan taikhoan) {
    TextEditingController hoVaTenController =
        TextEditingController(text: taikhoan.hoVaTen ?? '');

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
    TaiKhoan taikhoan, {
    required String hoVaTen,
    // Add other form fields as needed
  }) async {
    try {
      await _services.updateData(
        data: {
          'HoVaTen': hoVaTen,
          // Update other fields accordingly
        },
        docName: taikhoan.maTK,
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
  void _showEditInformationDialog1(TaiKhoan taikhoan) {
    String _selectedRole = taikhoan.vaiTro ?? 'Quản lý'; // Set default value

    TextEditingController hoVaTenController =
        TextEditingController(text: taikhoan.hoVaTen ?? '');
    TextEditingController taiKhoanController =
        TextEditingController(text: taikhoan.tenTK ?? '');
    TextEditingController matKhauController =
        TextEditingController(text: taikhoan.matKhau ?? '');
    TextEditingController trangThaiController =
        TextEditingController(text: taikhoan.trangThai ?? '');

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
              TextFormField(
                controller: trangThaiController,
                decoration: const InputDecoration(labelText: 'Trạng Thái'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Vai trò'),
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
                  trangThai: trangThaiController.text,
                  vaiTro: _selectedRole,
                  // Include other form fields as needed
                );

                // ignore: use_build_context_synchronously
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
    TaiKhoan taikhoan, {
    required String hoVaTen,
    required String taiKhoan,
    required String matKhau,
    required String trangThai,
    required String vaiTro,
  }) async {
    try {
      // Check if the document exists before updating
      DocumentSnapshot documentSnapshot =
          await _services.taiKhoan.doc(taikhoan.maTK).get();

      if (documentSnapshot.exists) {
        // Document exists, proceed with the update
        await _services.updateData(
          data: {
            'HoVaTen': hoVaTen,
            'TenTK': taiKhoan,
            'MatKhau': matKhau,
            'TrangThai': trangThai,
            'VaiTro': vaiTro,
          },
          docName: taikhoan.maTK,
          reference: _services.taiKhoan,
        );

        HienThiThongBaoDung('Sửa thông tin thành công');
      } else {
        // Document doesn't exist, handle accordingly
        print('Document with ID ${taikhoan.maTK} not found.');
        // Show an error message or handle the error as needed
      }
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
          height: 50,
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
      stream: _services.taiKhoan.snapshots(),
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
            TaiKhoan taikhoan = TaiKhoan.fromJson(
                snapshot.data!.docs[index].data() as Map<String, dynamic>);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _accountData(flex: 2, text: taikhoan.hoVaTen),
                _accountData(flex: 3, text: taikhoan.tenTK),
                _accountData(flex: 2, text: taikhoan.matKhau),
                _accountData(flex: 2, text: taikhoan.vaiTro),
                _accountData(flex: 2, text: taikhoan.trangThai),
                _accountData(
                  flex: 2,
                  widget: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        taikhoan.hoVaTen == null ? Colors.red : Colors.blue,
                      ),
                    ),
                    onPressed: () {
                      // Check if 'HoVaTen' is empty
                      if (taikhoan.hoVaTen == null) {
                        _showUpdateInformationDialog(taikhoan);
                      } else {
                        _showEditInformationDialog1(taikhoan);
                      }
                    },
                    child: Text(
                      // Display "Cập nhật thông tin" or "Xem chi tiết" based on the condition
                      taikhoan.hoVaTen == null
                          ? 'Cập nhật'
                          : 'Xem chi tiết / Sửa',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
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
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // User confirmed, delete the account
                                  await _services.deleteData(
                                    docName: taikhoan.maTK,
                                    reference: _services.taiKhoan,
                                  );
                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
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
}
