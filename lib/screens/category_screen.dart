import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';
import 'package:project_9shop_admin/widgets/categories_list_widget.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});
  static const String id = 'category';

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final FirebaseServices _services = FirebaseServices();
  final TextEditingController _catName = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  dynamic image;
  String? fileName;

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
      Fluttertoast.showToast(
        msg: "Huỷ Chọn Ảnh",
        toastLength: Toast.LENGTH_SHORT,
        webPosition: "center",
        webShowClose: false,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  saveImageToDb() async {
    EasyLoading.show();
    var ref = firebase_storage.FirebaseStorage.instance
        .ref('categoryImage/$fileName');

    try {
      String? mimiType = mime(
        basename(fileName!),
      );
      var metaData = firebase_storage.SettableMetadata(contentType: mimiType);
      firebase_storage.TaskSnapshot uploadSnapshot =
          await ref.putData(image, metaData);
      //hình ảnh sẽ được upload lên firebase storage
      // ignore: unused_local_variable
      String downloadURL =
          await uploadSnapshot.ref.getDownloadURL().then((value) {
        if (value.isNotEmpty) {
          //lưu dữ liệu vào firestore
          _services.saveData(
            data: {
              'TenDanhMuc': _catName.text,
              'hinhanh': '$value.png',
              'trangthai': true,
            },
            docName: _catName.text,
            reference: _services.danhmuc,
          ).then((value) {
            //sau khi lưu data thì xoá xạch các dữ liệu đã nhập ở màn hình
            clear();
            Fluttertoast.showToast(
              msg: "Tải danh mục thành công",
              toastLength: Toast.LENGTH_LONG,
              webPosition: "center",
              webShowClose: false,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            EasyLoading.dismiss();
          });
        }
        return value;
      });
    } on FirebaseException catch (e) {
      clear();
      EasyLoading.dismiss();
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  clear() {
    setState(() {
      _catName.clear();
      image = null;
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
              'Danh Mục',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 26,
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
                            ? const Text('Ảnh Danh Mục')
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
                width: 20,
              ),
              SizedBox(
                width: 200,
                child: TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Hãy nhập tên danh mục";
                    }
                    return null;
                  },
                  controller: _catName,
                  decoration: const InputDecoration(
                      label: Text('Nhập tên danh mục'),
                      contentPadding: EdgeInsets.zero),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
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
              image == null
                  ? Container()
                  : ElevatedButton(
                      onPressed: () {
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
          const Divider(
            color: Colors.grey,
          ),
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(10),
            child: const Text(
              'Danh Sách Danh Mục',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          CategoryListWidget(
            reference: _services.danhmuc,
          ),
        ],
      ),
    );
  }
}
