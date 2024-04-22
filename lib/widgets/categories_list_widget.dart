import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';

class CategoryListWidget extends StatefulWidget {
  final CollectionReference?
      reference; //khởi tạo tham chiếu đến 1 collection trong firebase
  const CategoryListWidget({this.reference, super.key});

  @override
  State<CategoryListWidget> createState() => _CategoryListWidgetState();
}

class _CategoryListWidgetState extends State<CategoryListWidget> {
  final FirebaseServices _services = FirebaseServices();
  Object? _selectedValue;
  QuerySnapshot? snapshot;
  //danh sach danh muc o category screen
  Widget categoryWidget(data) {
    return Card(
      color: Colors.grey.shade400,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              height: 20,
            ),
            SizedBox(
                height: 80, width: 80, child: Image.network(data['hinhanh'])),
            //nếu ở trang danh muc phụ thì hiển thị list danh mục phụ còn ở dm chính thì hiện dm chính
            Text(widget.reference == _services.danhmuc
                ? data['TenDanhMuc']
                : data['TenDanhMucPhu']),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons
                      .edit), // Thay thế bằng biểu tượng sửa ưa thích của bạn
                  onPressed: () {
                    // Xử lý khi người dùng bấm vào biểu tượng sửa
                    // showEditDanhMucChinhDialog(data);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons
                      .delete), // Thay thế bằng biểu tượng xoá ưa thích của bạn
                  onPressed: () {
                    // Xử lý khi người dùng bấm vào biểu tượng xoá
                    if (widget.reference == _services.danhmucphu) {
                      showDeleteConfirmationDialogSub(data['TenDanhMucPhu']);
                    } else {
                      showDeleteConfirmationDialog(data['TenDanhMuc']);
                    }
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
        hint: const Text('Chọn danh mục chính'),
        items: snapshot!.docs.map((e) {
          return DropdownMenuItem<String>(
              value: e['DanhMucChinh'], child: Text(e['DanhMucChinh']));
        }).toList(),
        onChanged: (selectedTenDM) {
          setState(() {
            _selectedValue = selectedTenDM;
          });
        });
  }

  // ignore: non_constant_identifier_names
  void deleteDanhMuc(String TenDanhMuc) {
    _services.danhmuc
        .where('TenDanhMuc', isEqualTo: TenDanhMuc)
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

  void deleteDanhMucPhu(String TenDanhMucPhu) {
    _services.danhmucphu
        .where('TenDanhMucPhu', isEqualTo: TenDanhMucPhu)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete().then((value) {
          // Xóa thành công, bạn có thể thực hiện các xử lý cần thiết ở đây.
          Fluttertoast.showToast(
              msg: "Xoá danh mục phụ thành công",
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
  void showDeleteConfirmationDialog(String TenDanhMuc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa danh mục?"),
          content: Text("Bạn có chắc muốn xóa danh mục '$TenDanhMuc'?"),
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
                deleteDanhMuc(TenDanhMuc);
                Navigator.of(context).pop(); // Đóng hộp thoại sau khi xóa
              },
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  void showDeleteConfirmationDialogSub(String TenDanhMucPhu) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa danh mục phụ ?"),
          content: Text("Bạn có chắc muốn xóa danh mục phụ '$TenDanhMucPhu'?"),
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
                deleteDanhMucPhu(TenDanhMucPhu);
                Navigator.of(context).pop(); // Đóng hộp thoại sau khi xóa
              },
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    getDanhSachDanhMucChinh();
    super.initState();
  }

  getDanhSachDanhMucChinh() {
    return _services.danhmucchinh.get().then((QuerySnapshot querySnapshot) {
      setState(() {
        snapshot = querySnapshot;
      });
    });
  }

  //hiển thị danh sách danh mục slect *
  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (widget.reference == _services.danhmucphu && snapshot != null)
            Row(
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
                          msg: "Đã hiển thị tất cả danh mục phụ",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 2,
                          textColor: Colors.white,
                          // webBgColor: "linear-gradient(to right, #dc1c13, #dc1c13)",
                          webPosition: "center",
                          webShowClose: false,
                          fontSize: 16.0);
                    },
                    child: const Text('Hiển thị tất cả'))
              ],
            ),
          const SizedBox(
            height: 10,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: widget.reference!
                .where('DanhMucChinh', isEqualTo: _selectedValue)
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
                return const Text("Không có danh mục nào được thêm vào");
              }
              return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
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
      ),
    );
  }
}
