import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project_9shop_admin/others/toast.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';

class ProductWidget extends StatefulWidget {
  final CollectionReference?
      reference; //khởi tạo tham chiếu đến 1 collection trong firebase
  const ProductWidget({this.reference, super.key});

  @override
  State<ProductWidget> createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  final FirebaseServices _services = FirebaseServices();
  Object? _selectedValue;

  QuerySnapshot? snapshot;
  Widget productWidget(data) {
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
            Text(data['TenSP'] ?? ''),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons
                      .edit), // Thay thế bằng biểu tượng sửa ưa thích của bạn
                  onPressed: () {
                    showEditProductDialog(data);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons
                      .delete), // Thay thế bằng biểu tượng xoá ưa thích của bạn
                  onPressed: () {
                    // Xử lý khi người dùng bấm vào biểu tượng xoá

                    showDeleteConfirmationDialog(data['MaSP']);
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
        hint: const Text('Chọn danh mục phụ'),
        items: snapshot!.docs.map((e) {
          return DropdownMenuItem<String>(
              value: e['TenDanhMucPhu'], child: Text(e['TenDanhMucPhu']));
        }).toList(),
        onChanged: (selectedTenDM) {
          setState(() {
            _selectedValue = selectedTenDM;
          });
        });
  }

  // ignore: non_constant_identifier_names
  void deleteSanPham(String MaSP) {
    _services.sanPham
        .where('MaSP', isEqualTo: MaSP)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete().then((value) {
          // Xóa thành công, bạn có thể thực hiện các xử lý cần thiết ở đây.
          HienThiThongBaoDung('Xoá sản phẩm thành công');
        }).catchError((error) {
          // Xảy ra lỗi khi xóa, xử lý lỗi ở đây nếu cần.
        });
      }
    });
  }

  // ignore: non_constant_identifier_names
  void showDeleteConfirmationDialog(String MaSP) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa danh mục?"),
          content: Text("Bạn có chắc muốn xóa danh mục '$MaSP'?"),
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
                deleteSanPham(MaSP);
                Navigator.of(context).pop(); // Đóng hộp thoại sau khi xóa
              },
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  void showEditProductDialog(DocumentSnapshot productData) {
    Map<String, dynamic> data = productData.data() as Map<String, dynamic>;
    TextEditingController tenSPController =
        TextEditingController(text: data['TenSP'] ?? '');
    TextEditingController giaSPController =
        TextEditingController(text: data['GiaSP'].toString());
    TextEditingController gianhapSPController =
        TextEditingController(text: data['GiaNhapSP'].toString());
    TextEditingController motaSPController =
        TextEditingController(text: data['MotaSP']);
    TextEditingController hinhanhController =
        TextEditingController(text: data['hinhanh']);

    // Use null-aware operator to provide default values
    bool trangthai = data['trangthai'] ?? false;
    bool spNoiBat = data['SPnoibat'] ?? false;
    bool spBanChay = data['SPbanchay'] ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Chỉnh sửa sản phẩm"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: tenSPController,
                  decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                ),
                TextFormField(
                  controller: giaSPController,
                  decoration: const InputDecoration(labelText: 'Giá sản phẩm'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: gianhapSPController,
                  decoration:
                      const InputDecoration(labelText: 'Giá nhập sản phẩm'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: motaSPController,
                  decoration:
                      const InputDecoration(labelText: 'Mô tả sản phẩm'),
                  maxLines: 3,
                ),
                TextFormField(
                  controller: hinhanhController,
                  decoration: const InputDecoration(labelText: 'Link hình ảnh'),
                ),
                CheckboxListTile(
                  title: const Text('Trạng thái'),
                  value: trangthai,
                  onChanged: (value) {
                    setState(() {
                      trangthai = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Sản phẩm nổi bật'),
                  value: spNoiBat,
                  onChanged: (value) {
                    setState(() {
                      spNoiBat = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Sản phẩm bán chạy'),
                  value: spBanChay,
                  onChanged: (value) {
                    setState(() {
                      spBanChay = value!;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng hộp thoại
                },
                child: const Text("Hủy"),
              ),
              TextButton(
                onPressed: () {
                  // Xử lý cập nhật thông tin sản phẩm ở đây
                  updateProduct(
                    productData['MaSP'],
                    tenSPController.text,
                    double.parse(giaSPController.text),
                    double.parse(gianhapSPController.text),
                    motaSPController.text,
                    hinhanhController.text,
                    trangthai,
                    spNoiBat,
                    spBanChay,
                  );
                  Navigator.of(context)
                      .pop(); // Đóng hộp thoại sau khi cập nhật
                },
                child: const Text("Lưu"),
              ),
            ],
          );
        });
      },
    );
  }

  // Function to update product information
  void updateProduct(
    String maSP,
    String tenSP,
    double giaSP,
    double gianhapSP,
    String motaSP,
    String hinhanh,
    bool trangthai,
    bool spNoiBat,
    bool spBanChay,
  ) {
    _services.sanPham.doc(maSP).update({
      'TenSP': tenSP,
      'GiaSP': giaSP,
      'GiaNhapSP': gianhapSP,
      'MotaSP': motaSP,
      'hinhanh': hinhanh,
      'trangthai': trangthai,
      'SPnoibat': spNoiBat,
      'SPbanchay': spBanChay,
    }).then((value) {
      HienThiThongBaoDung('Cập nhật sản phẩm thành công');
    }).catchError((error) {
      // Xử lý lỗi nếu cần
    });
  }

  @override
  void initState() {
    getDanhSachDanhMucPhu();

    super.initState();
  }

  getDanhSachDanhMucPhu() {
    return _services.danhmucphu.get().then((QuerySnapshot querySnapshot) {
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
                              msg: "Đã hiển thị tất cả sản phẩm",
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
            stream: _services.sanPham
                .where('TenDanhMucPhu', isEqualTo: _selectedValue)
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
                return const Text("Không có sản phẩm nào thuộc danh mục này");
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
                    return productWidget(data);
                  });
            },
          ),
        ],
      ),
    );
  }
}
