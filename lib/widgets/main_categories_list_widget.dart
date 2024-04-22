import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';

class MainCategoryListWidget extends StatefulWidget {
  const MainCategoryListWidget({super.key});

  @override
  State<MainCategoryListWidget> createState() => _MainCategoryListWidgetState();
}

class _MainCategoryListWidgetState extends State<MainCategoryListWidget> {
  final FirebaseServices _services = FirebaseServices();
  Object? _selectedValue;
  QuerySnapshot? snapshot;
  // ignore: non_constant_identifier_names
  void deleteDanhMucChinh(String DanhMucChinh) {
    _services.danhmucchinh
        .where('DanhMucChinh', isEqualTo: DanhMucChinh)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete().then((value) {
          // Xóa thành công, bạn có thể thực hiện các xử lý cần thiết ở đây.
          Fluttertoast.showToast(
              msg: "Xoá danh mục chính thành công",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 2,
              textColor: Colors.white,
              // webBgColor: "linear-gradient(to right, #dc1c13, #dc1c13)",
              webPosition: "center",
              webShowClose: false,
              fontSize: 16.0);
        }).catchError((error) {
          // Xảy ra lỗi khi xóa, xử lý lỗi ở đây nếu cần.
        });
      }
    });
  }

  // ignore: non_constant_identifier_names
  void showDeleteConfirmationDialog(String DanhMucChinh) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa danh mục?"),
          content: Text("Bạn có chắc muốn xóa danh mục '$DanhMucChinh'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                // Xử lý xóa danh mục chính ở đây
                deleteDanhMucChinh(DanhMucChinh);
                Navigator.of(context).pop(); // Đóng hộp thoại sau khi xóa
              },
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  //hiển thị hộp thoại chỉnh sửa
  void showEditDanhMucChinhDialog(DocumentSnapshot danhMucSnapshot) {
    String tenDanhMucChinh = danhMucSnapshot['DanhMucChinh'];
    String danhMuc = danhMucSnapshot['danhmuc'];
    bool trangThai = danhMucSnapshot['trangthai'];

    showDialog(
      context: context,
      builder: (context) {
        String selectedDanhMuc = danhMuc;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Sửa danh mục chính"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: TextEditingController(text: tenDanhMucChinh),
                    decoration:
                        const InputDecoration(labelText: 'Tên danh mục chính'),
                    onChanged: (value) {
                      tenDanhMucChinh = value;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedDanhMuc,
                    items: snapshot!.docs.map((e) {
                      return DropdownMenuItem<String>(
                          value: e['TenDanhMuc'], child: Text(e['TenDanhMuc']));
                    }).toList(),
                    onChanged: (selectedTenDM) {
                      setState(() {
                        selectedDanhMuc = selectedTenDM!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      const Text('Trạng thái:'),
                      const SizedBox(width: 10),
                      Checkbox(
                        value: trangThai,
                        onChanged: (value) {
                          setState(() {
                            trangThai = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Đóng hộp thoại
                  },
                  child: const Text("Hủy"),
                ),
                TextButton(
                  onPressed: () {
                    // Xử lý sửa danh mục chính ở đây
                    editDanhMucChinh(
                      danhMucSnapshot.reference,
                      tenDanhMucChinh,
                      selectedDanhMuc,
                      trangThai,
                    );
                    Navigator.of(context).pop(); // Đóng hộp thoại sau khi sửa
                  },
                  child: const Text("Lưu"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void editDanhMucChinh(DocumentReference danhMucChinhRef,
      String tenDanhMucChinh, String danhMuc, bool trangThai) {
    danhMucChinhRef.update({
      'DanhMucChinh': tenDanhMucChinh,
      'danhmuc': danhMuc,
      'trangthai': trangThai,
    }).then((_) {
      // Sửa thành công, bạn có thể thực hiện các xử lý cần thiết ở đây.
      Fluttertoast.showToast(
          msg: "Sửa danh mục chính thành công",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          textColor: Colors.white,
          // webBgColor: "linear-gradient(to right, #dc1c13, #dc1c13)",
          webPosition: "center",
          webShowClose: false,
          fontSize: 16.0);
    }).catchError((error) {
      // Xảy ra lỗi khi sửa, xử lý lỗi ở đây nếu cần.
    });
  }

  //danh sach danh muc o category screen
  Widget categoryWidget(data) {
    return Card(
      color: Colors.grey.shade400,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(child: Text(data['DanhMucChinh'])),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons
                      .edit), // Thay thế bằng biểu tượng sửa ưa thích của bạn
                  onPressed: () {
                    // Xử lý khi người dùng bấm vào biểu tượng sửa
                    showEditDanhMucChinhDialog(data);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons
                      .delete), // Thay thế bằng biểu tượng xoá ưa thích của bạn
                  onPressed: () {
                    // Xử lý khi người dùng bấm vào biểu tượng xoá
                    showDeleteConfirmationDialog(data['DanhMucChinh']);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropDownButton() {
    return DropdownButton(
        value: _selectedValue,
        hint: const Text('Chọn danh mục'),
        items: snapshot!.docs.map((e) {
          return DropdownMenuItem<String>(
              value: e['TenDanhMuc'], child: Text(e['TenDanhMuc']));
        }).toList(),
        onChanged: (selectedTenDM) {
          setState(() {
            _selectedValue = selectedTenDM;
          });
        });
  }

  @override
  void initState() {
    getDanhSachDanhMucChinh();
    super.initState();
  }

  getDanhSachDanhMucChinh() {
    return _services.danhmuc.get().then((QuerySnapshot querySnapshot) {
      setState(() {
        snapshot = querySnapshot;
      });
    });
  }

  //hiển thị danh sách danh mục slect *
  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers

    return Column(
      children: [
        snapshot == null
            ? const Text('is Loading...')
            : Row(
                children: [
                  _dropDownButton(),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedValue = null;
                      });
                      Fluttertoast.showToast(
                          msg: "Đã hiển thị tất cả danh mục chính",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 2,
                          textColor: Colors.white,
                          // webBgColor: "linear-gradient(to right, #dc1c13, #dc1c13)",
                          webPosition: "center",
                          webShowClose: false,
                          fontSize: 16.0);
                    },
                    child: const Text('Hiển thị tất cả'),
                  ),
                ],
              ),
        const SizedBox(
          height: 10,
        ),
        StreamBuilder<QuerySnapshot>(
          stream: _services.danhmucchinh
              .where('danhmuc', isEqualTo: _selectedValue)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Lỗi xảy ra');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }

            if (snapshot.data!.size == 0) {
              return const Text("Không có danh mục chính nào được thêm vào");
            }
            return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: 5 / 2.5,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                ),
                itemCount: snapshot.data!.size,
                itemBuilder: (context, index) {
                  var data = snapshot.data!.docs[index];
                  return categoryWidget(data);
                });
          },
        ),
      ],
    );
  }
}

//danh sách danh mục chính
