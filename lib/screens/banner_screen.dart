// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:firebase_storage/firebase_storage.dart' as fb;
import 'package:flutter/material.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';
import 'package:project_9shop_admin/widgets/banner_widget.dart';
import 'package:ars_dialog/ars_dialog.dart';

class BannerScreen extends StatefulWidget {
  static const String id = 'BannerScreen';
  const BannerScreen({super.key});

  @override
  State<BannerScreen> createState() => _BannerScreenState();
}

class _BannerScreenState extends State<BannerScreen> {
  bool _visible = false;
  bool _imageSelected = true;
  final FirebaseServices _services = FirebaseServices();
  final _fileNameTextController = TextEditingController();
  String? _url;
  @override
  Widget build(BuildContext context) {
    ProgressDialog progressDialog = ProgressDialog(
      context,
      blur: 2,
      transitionDuration: const Duration(milliseconds: 500),
      backgroundColor: const Color(0xFF84c225).withOpacity(.3),
    );
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.topLeft,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quản lý quảng cáo',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 26),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('Thêm và xoá hình ảnh quảng cáo'),
            const Divider(
              thickness: 5,
            ),
            const BannerWidget(),
            const Divider(
              thickness: 5,
            ),
            Container(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width,
              height: 80,
              child: Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Row(
                  children: [
                    Visibility(
                      visible: _visible,
                      child: SizedBox(
                        child: Row(
                          children: [
                            AbsorbPointer(
                              absorbing: true,
                              child: SizedBox(
                                width: 300,
                                height: 30,
                                child: TextField(
                                  controller: _fileNameTextController,
                                  decoration: const InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      hintText: 'Tải hình ảnh',
                                      border: OutlineInputBorder(),
                                      contentPadding:
                                          EdgeInsets.only(left: 20)),
                                ),
                              ),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.black54),
                              ),
                              onPressed: () {
                                uploadStore();
                              },
                              child: const Text(
                                'Tải hình ảnh',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            AbsorbPointer(
                              absorbing: _imageSelected,
                              child: TextButton(
                                style: ButtonStyle(
                                  backgroundColor: _imageSelected
                                      ? MaterialStateProperty.all<Color>(
                                          Colors.black12)
                                      : MaterialStateProperty.all<Color>(
                                          Colors.black54),
                                ),
                                onPressed: () {
                                  progressDialog.show();
                                  _services
                                      .upLoadBannerImageToDb(_url)
                                      .then((downloadUrl) {
                                    progressDialog.dismiss();
                                    _services.showMyDialog(
                                        title: 'Hình ảnh quảng cáo mới',
                                        message: 'Lưu hình ảnhh thành công',
                                        context: context);
                                  });
                                },
                                child: const Text(
                                  'Lưu hình ảnh',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _visible ? false : true,
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.black54),
                        ),
                        onPressed: () {
                          setState(() {
                            _visible = true;
                          });
                        },
                        child: const Text(
                          'Thêm Quảng Cáo Mới',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void upLoadImage({required Function(html.File file) onSelected}) {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement()
      ..accept = 'image/*';
    uploadInput.click();
    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      final reader = html.FileReader();
      reader.readAsDataUrl(file!);
      reader.onLoadEnd.listen((event) {
        onSelected(file);
      });
    });
  }

  void uploadStore() {
    final dateTime = DateTime.now();
    final path = 'homeBanner/$dateTime';
    upLoadImage(onSelected: (html.File file) {
      setState(() {
        _fileNameTextController.text = file.name;
        _imageSelected = false;
        _url = path;
      });

      fb.FirebaseStorage.instance
          .refFromURL('gs://shop-f6af8.appspot.com')
          .child(path)
          .putBlob(file);
    });
  }
}
