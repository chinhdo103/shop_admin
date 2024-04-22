import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';
import 'package:project_9shop_admin/others/toast.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:project_9shop_admin/widgets/product_widget.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});
  static const String id = 'product-screen';

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final FirebaseServices _services = FirebaseServices();
  final TextEditingController _productName = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _startprice = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  List<String> _selectedColors = []; // Danh sách các màu sắc đã chọn

  final TextEditingController _unit = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  dynamic image;
  String? fileName;
  // ignore: unused_field
  Object? _selectedValue;

  // ignore: unused_field
  bool _noCategorySelected = false;
  QuerySnapshot? snapshot;
  final Uuid uuid = const Uuid();
  String? _selectedCategory;
  String? _selectedMainCategory;
  String? _selectedSubCategory;

  String generateRandomDocName() {
    return 'doc_${uuid.v4()}';
  }

  Widget _dropDownButton() {
    return DropdownButton(
      value: _selectedCategory, // Make sure this is set
      hint: const Text('Chọn danh mục'),
      items: snapshot!.docs.map((e) {
        return DropdownMenuItem<String>(
          value: e['TenDanhMuc'],
          child: Text(e['TenDanhMuc']),
        );
      }).toList(),
      onChanged: (selectedTenDM) {
        setState(() {
          _selectedCategory = selectedTenDM;
          _noCategorySelected = false;
          _selectedMainCategory = null;
        });
      },
    );
  }

  String generateRandomProductCode() {
    Random random = Random();
    int randomNumber = 1000000000 +
        random.nextInt(1000000000); // Generate a random 10-digit number
    return randomNumber.toString();
  }

  Widget _dropDownMainCategoryButton() {
    if (_selectedCategory == null) {
      return DropdownButton(
          hint: const Text('Hãy chọn danh mục'),
          items: null,
          onChanged: (ok) {
            setState(() {});
          }); // Don't show dropdown if no category selected
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _services.danhmucchinh
          .where('danhmuc', isEqualTo: _selectedCategory)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text('Loading..');
        }

        var subcategories = snapshot.data!.docs;

        return DropdownButton(
          value: _selectedMainCategory,
          hint: const Text('Chọn danh mục chính'),
          items: subcategories.map((e) {
            return DropdownMenuItem<String>(
              value: e['DanhMucChinh'],
              child: Text(e['DanhMucChinh']),
            );
          }).toList(),
          onChanged: (selectedDanhMucChinh) {
            setState(() {
              _selectedMainCategory = selectedDanhMucChinh;
              _noCategorySelected = false;
              _selectedSubCategory = null;
            });
          },
        );
      },
    );
  }

  Widget _dropDownSubCategoryButton() {
    if (_selectedMainCategory == null) {
      return DropdownButton(
          hint: const Text('Hãy chọn danh mục chính'),
          items: null,
          onChanged: (ok) {
            setState(() {});
          }); // Don't show dropdown if no category selected
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _services.danhmucphu
          .where('DanhMucChinh', isEqualTo: _selectedMainCategory)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text('Loading..');
        }

        var subcategories = snapshot.data!.docs;

        return DropdownButton(
          value: _selectedSubCategory,
          hint: const Text('Chọn danh mục phụ'),
          items: subcategories.map((e) {
            return DropdownMenuItem<String>(
              value: e['TenDanhMucPhu'],
              child: Text(e['TenDanhMucPhu']),
            );
          }).toList(),
          onChanged: (selectedDanhMucPhu) {
            setState(() {
              _selectedSubCategory = selectedDanhMucPhu;
            });
          },
        );
      },
    );
  }

  //function chọn hình ảnh danh mục
  pickImage() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);
    if (result != null) {
      setState(() {
        image = result.files.first.bytes;
        fileName = result.files.first.name;
      });
    } else {
      HienThiThongBaoDung("Huỷ chọn ảnh");
    }
  }

  saveImageToDb() async {
    EasyLoading.show();
    var ref =
        firebase_storage.FirebaseStorage.instance.ref('productImage/$fileName');

    try {
      String? mimiType = mime(
        basename(fileName!),
      );
      var metaData = firebase_storage.SettableMetadata(contentType: mimiType);
      firebase_storage.TaskSnapshot uploadSnapshot =
          await ref.putData(image, metaData);

      // ignore: unused_local_variable
      String downloadURL =
          await uploadSnapshot.ref.getDownloadURL().then((value) {
        if (value.isNotEmpty) {
          //lưu dữ liệu vào firestore
          String productCode = generateRandomProductCode();

          _services.saveData(
            data: {
              'MaSP': productCode,
              'TenSP': _productName.text,
              'GiaSP': int.tryParse(_price.text) ?? 0,
              'GiaNhapSP': int.tryParse(_startprice.text) ?? 0,
              'MotaSP': _description.text,
              'TenDanhMuc': _selectedCategory,
              'DanhMucChinh': _selectedMainCategory,
              'TenDanhMucPhu': _selectedSubCategory,
              'DonViSP': _unit.text,
              'hinhanh': '$value.png',
              'ngaytao': DateTime.now(),
              'trangthai': true,
              'selectedColors': _selectedColors, // Add selected colors to data
            },
            docName: productCode,
            reference: _services.sanPham,
          ).then((value) {
            //sau khi lưu data thì xoá xạch các dữ liệu đã nhập ở màn hình
            clear();
            HienThiThongBaoDung("Tải lên sản phẩm thành công");
            EasyLoading.dismiss();
          });
        }
        return value;
      });
    } on FirebaseException catch (e) {
      clear();
      EasyLoading.dismiss();
      HienThiThongBaoDung(e.toString());
    }
  }

  clear() {
    setState(() {
      _productName.clear();
      _description.clear();

      _price.clear();

      image = null;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize _selectedCategory to the first category, if available
    getDanhSachDanhMuc().then((_) {
      if (snapshot != null && snapshot!.docs.isNotEmpty) {
        setState(() {
          _selectedCategory = snapshot!.docs[0]['TenDanhMuc'];
        });
      }
    });
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
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(10),
            child: const Text(
              'Quản lý sản phẩm',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 36,
              ),
            ),
          ),
          const Divider(
            color: Colors.grey,
          ),
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Column(
                children: [
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade500,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.grey.shade800,
                      ),
                    ),
                    child: Center(
                        child: image == null
                            ? const Text('Ảnh Sản Phẩm')
                            : Image.memory(image)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: pickImage, child: const Text('Tải ảnh lên'))
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  snapshot == null
                      ? const Text('Loading..')
                      : Row(
                          children: [
                            // First Dropdown - Main Category
                            SizedBox(
                              width: 300,
                              child: _dropDownButton(),
                            ),

                            // Second Dropdown - Sub Category
                            SizedBox(
                              width: 300,
                              child: _dropDownMainCategoryButton(),
                            ),

                            // Third Dropdown - Sub Category
                            SizedBox(
                              width: 300,
                              child: _dropDownSubCategoryButton(),
                            ),
                          ],
                        ),
                  const SizedBox(height: 8),
                  if (_selectedCategory == null)
                    const Text(
                      'không có danh mục nào được chọn',
                      style: TextStyle(color: Colors.red),
                    ),
                  SizedBox(
                    width: 500,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Hãy nhập tên sản phẩm";
                        }
                        return null;
                      },
                      controller: _productName,
                      decoration: const InputDecoration(
                          label: Text('Nhập tên sản phẩm'),
                          contentPadding: EdgeInsets.zero),
                    ),
                  ),
                  SizedBox(
                    width: 500,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Hãy nhập mô tả sản phẩm";
                        }
                        return null;
                      },
                      controller: _description,
                      maxLines:
                          null, // Đặt maxLines thành null để cho phép mở rộng

                      decoration: const InputDecoration(
                          label: Text('Nhập mô tả sản phẩm'),
                          contentPadding: EdgeInsets.zero),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Hãy nhập giá bán sản phẩm";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9]'),
                        ),
                      ],
                      controller: _price,
                      maxLines: null,
                      decoration: const InputDecoration(
                        label: Text('Nhập giá bán sản phẩm'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Hãy nhập giá nhập sản phẩm";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9]'),
                        ),
                      ],
                      controller: _startprice,
                      maxLines: null,
                      decoration: const InputDecoration(
                        label: Text('Nhập giá nhập sản phẩm'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Hãy nhập đơn vị của sản phẩm";
                        }
                        return null;
                      },
                      controller: _unit,
                      maxLines:
                          null, // Đặt maxLines thành null để cho phép mở rộng

                      decoration: const InputDecoration(
                          label: Text('Nhập đơn vị của sản phẩm'),
                          contentPadding: EdgeInsets.zero),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      controller: _colorController,
                      maxLines:
                          null, // Đặt maxLines thành null để cho phép mở rộng

                      decoration: const InputDecoration(
                          label: Text('Nhập màu sắc của sản phẩm'),
                          contentPadding: EdgeInsets.zero),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        String color = _colorController.text.trim();
                        if (color.isNotEmpty) {
                          _selectedColors.add(color);
                          _colorController
                              .clear(); // Xóa nội dung của TextFormField sau khi thêm màu sắc
                        }
                      });
                    },
                    child: const Text('Thêm màu sắc'),
                  ),
                  SizedBox(
                    height: 100,
                    width: 1000,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: _selectedColors.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          height: 100,
                          width: 100,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      _selectedColors[index],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: IconButton(
                                      iconSize: 11.0,
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          _selectedColors.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                          side: MaterialStateProperty.all(
                            BorderSide(color: Theme.of(context).primaryColor),
                          ),
                        ),
                        child: Text(
                          'Huỷ',
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      //nút lưu chỉ hiển thị khi hình ảnh được chọn
                      if (image != null)
                        ElevatedButton(
                          onPressed: () {
                            if (_selectedCategory == null) {
                              setState(() {
                                _noCategorySelected = true;
                              });
                              return;
                            }
                            if (_formKey.currentState!.validate()) {
                              saveImageToDb();
                            }
                          },
                          child: const Text(
                            '  Lưu  ',
                          ),
                        ),
                    ],
                  ),
                ],
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
              'Danh Sách Sản Phẩm',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ProductWidget(
            reference: _services.sanPham,
          ),
        ],
      ),
    );
  }
}
