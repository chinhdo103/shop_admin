import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:intl/intl.dart';
import 'package:project_9shop_admin/provider/order_provider.dart';
import 'package:project_9shop_admin/services/order_services.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class OrderScreen extends StatefulWidget {
  static const String id = 'orders-screen';
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final OrderServices _orderServices = OrderServices();

  int tag = 0;
  List<String> options = [
    'Tất cả đơn hàng',
    'Chờ xác nhận',
    'Đã thanh toán',
    'Đã từ chối',
    'Đã hủy đơn',
    'Đã xác nhận',
    'Đang vận chuyển',
  ];

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('vi_VN', null);
    Color getOrderStatusColor(DocumentSnapshot document) {
      String trangThaiDH =
          (document.data() as Map<String, dynamic>)['trangthaidh'];

      if (trangThaiDH == 'Đã từ chối') {
        return Colors.red;
      } else if (trangThaiDH == 'Đã xác nhận') {
        return Colors.blueGrey;
      } else if (trangThaiDH == 'Đã thanh toán') {
        return Colors.green; // Set the color to green for paid orders
      } else if (trangThaiDH == 'Đã hủy đơn') {
        return Colors.deepPurpleAccent;
      } else {
        return Colors.orange;
      }
    }

    String _convertChunkToVietnameseWords(int chunk, String unit) {
      final words = <String>[];

      final ones = [
        'không',
        'một',
        'hai',
        'ba',
        'bốn',
        'năm',
        'sáu',
        'bảy',
        'tám',
        'chín'
      ];
      final tens = [
        '',
        'mười',
        'hai mươi',
        'ba mươi',
        'bốn mươi',
        'năm mươi',
        'sáu mươi',
        'bảy mươi',
        'tám mươi',
        'chín mươi'
      ];

      final hundred = chunk ~/ 100;
      final remainder = chunk % 100;

      if (hundred > 0) {
        words.add('${ones[hundred]} trăm');
      }

      if (remainder > 0) {
        if (remainder < 10) {
          words.add(ones[remainder]);
        } else if (remainder < 20) {
          words.add('mười ${ones[remainder % 10]}');
        } else {
          words.add('${tens[remainder ~/ 10]} ${ones[remainder % 10]}');
        }
      }

      if (unit.isNotEmpty) {
        words.add(unit);
      }

      return words.join(' ');
    }

    String convertNumberToVietnameseWords(int number) {
      final units = ['', 'nghìn', 'triệu', 'tỷ'];
      final words = <String>[];

      for (int i = 0; number > 0; i++) {
        final chunk = number % 1000;
        if (chunk != 0) {
          words.insert(0, _convertChunkToVietnameseWords(chunk, units[i]));
        }
        number ~/= 1000;
      }

      return words.isEmpty ? 'không đồng' : words.join(' ');
    }

    List<pw.TableRow> buildProductItem(
        Map<String, dynamic> product, pw.Font ttf) {
      final int quantity = product['SoLuong'];
      final int price = product['GiaSP'];
      final int total = product['TongGia'];
      final int discount = product['giamgia'] ?? 0;

      return [
        pw.TableRow(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                product['TenSP'] ?? '',
                style: pw.TextStyle(
                  font: ttf,
                ),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(quantity.toString()),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                '${NumberFormat('#,###,###').format(price)} VND',
                style: pw.TextStyle(
                  font: ttf,
                ),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                '${NumberFormat('#,###,###').format(total)} VND',
                style: pw.TextStyle(
                  font: ttf,
                ),
              ),
            ),
            if (discount > 0)
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '${NumberFormat('#,###,###').format(discount)} VND',
                  style: pw.TextStyle(
                    font: ttf,
                  ),
                ),
              ),
          ],
        ),
      ];
    }

    Future<void> generatePdf(DocumentSnapshot document) async {
      final pdf = pw.Document();
      final font = await rootBundle.load("assets/fonts/OpenSans-Light.ttf");
      final ttf = pw.Font.ttf(font);

      try {
        pdf.addPage(
          pw.Page(build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '9Shop - Hóa đơn mua hàng',
                  style: pw.TextStyle(
                    fontSize: 20,
                    font: ttf,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Địa chỉ : 55 Đường số 48, Phường Hiệp Bình Chánh, Quận Thủ Đức, TP.HCM',
                  style: pw.TextStyle(
                    fontSize: 12,
                    font: ttf,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),

                pw.Text(
                  'Hotline: 1900.89.98.89 - SĐT:0329.587.081',
                  style: pw.TextStyle(
                    fontSize: 12,
                    font: ttf,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),

                pw.Text(
                  'Ngày in hóa đơn: ${DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(DateTime.now())}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    font: ttf,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Divider(),

                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Tên sản phẩm',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                            ),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Số lượng',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                            ),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Đơn giá',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                            ),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Tổng giá',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              font: ttf,
                            ),
                          ),
                        ),
                      ],
                    ),
                    for (var product
                        in (document.data() as Map<String, dynamic>)['SanPham'])
                      ...buildProductItem(product, ttf),
                  ],
                ),

                pw.Divider(),
                // Total amount
                pw.Text(
                  'VAT: ${NumberFormat('#,###,###').format((document.data() as Map<String, dynamic>)['vat'])} VND',
                  style: pw.TextStyle(
                    fontSize: 14,
                    font: ttf,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Phí vận chuyển: ${NumberFormat('#,###,###').format((document.data() as Map<String, dynamic>)['phivanchuyen'])} VND',
                  style: pw.TextStyle(
                    fontSize: 14,
                    font: ttf,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10), // Add some space
                pw.Text(
                  'Tổng tiền: ${NumberFormat('#,###,###').format((document.data() as Map<String, dynamic>)['tongdon'])} VND',
                  style: pw.TextStyle(
                    fontSize: 14,
                    font: ttf,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),

                pw.Text(
                  'Bằng chữ: ${convertNumberToVietnameseWords((document.data() as Map<String, dynamic>)['tongdon'])} đồng',
                  style: pw.TextStyle(
                    fontSize: 14,
                    font: ttf,
                    fontWeight:
                        pw.FontWeight.normal, // Adjust the fontWeight as needed
                  ),
                ),
                pw.SizedBox(height: 30),

                pw.Center(
                  child: pw.Text(
                    'Cảm ơn và hẹn gặp lại',
                    style: pw.TextStyle(
                      fontSize: 14,
                      font: ttf,
                      fontWeight: pw
                          .FontWeight.normal, // Adjust the fontWeight as needed
                    ),
                  ),
                )
              ],
            );
          }),
        );

        final Uint8List pdfBytes = await pdf.save();

        // Use try-catch for error handling
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes,
        );
      } catch (e) {
        // Handle any errors during PDF generation
        return;
      }
    }

    // ignore: no_leading_underscores_for_local_identifiers
    var _orderProvider = Provider.of<OrderProvider>(context);

    return Column(
      children: [
        SizedBox(
          height: 56,
          width: MediaQuery.of(context).size.width,
          child: ChipsChoice<int>.single(
            choiceStyle: const C2ChipStyle(
                borderRadius: BorderRadius.all(Radius.circular(3))),
            value: tag,
            onChanged: (val) {
              if (val == 0) {
                setState(() {
                  _orderProvider.status = null;
                });
              }
              setState(() {
                tag = val;
                _orderProvider.status = (options[val]);
              });
            },
            choiceItems: C2Choice.listFrom<int, String>(
              source: options,
              value: (i, v) => i,
              label: (i, v) => v,
            ),
          ),
        ),
        SizedBox(
          child: StreamBuilder<QuerySnapshot>(
            stream: _orderServices.orders
                .where('trangthaidh',
                    isEqualTo: tag > 0 ? _orderProvider.status : null)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.size == 0) {
                return Center(
                  child: Center(
                    child: Text(
                      tag > 0
                          ? 'Không có đơn hàng ${options[tag]}'
                          : 'Chưa có đơn hàng nào!',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  return Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        ListTile(
                          horizontalTitleGap: 0,
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 14,
                            child: Icon(
                              CupertinoIcons.square_list,
                              size: 18,
                              color: getOrderStatusColor(document),
                            ),
                          ),
                          title: Text(
                            (document.data()
                                as Map<String, dynamic>)['trangthaidh'],
                            style: TextStyle(
                                fontSize: 12,
                                color: getOrderStatusColor(document),
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                'Vào ${DateFormat('dd MMMM y', 'vi').format(DateTime.parse((document.data() as Map<String, dynamic>)['timestamp']))}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                (document.data() as Map<String, dynamic>)[
                                        'tennguoidung'] ??
                                    'Tên người dùng trống',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  (document.data()
                                              as Map<String, dynamic>)['cod'] ==
                                          true
                                      ? 'Thanh toán khi nhận hàng'
                                      : 'Thanh toán qua thẻ',
                                  style: const TextStyle(
                                    fontSize: 12,
                                  )),
                              Text(
                                'Tổng đơn : ${NumberFormat('#,###,###').format((document.data() as Map<String, dynamic>)['tongdon'])}',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        ExpansionTile(
                          title: const Text(
                            'Chi tiết đơn hàng',
                            style: TextStyle(fontSize: 10, color: Colors.black),
                          ),
                          subtitle: const Text(
                            'Xem chi tiết đơn hàng',
                            style: TextStyle(fontSize: 12, color: Colors.black),
                          ),
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Image.network((document.data()
                                            as Map<String, dynamic>)['SanPham']
                                        [index]['hinhanh']),
                                  ),
                                  title: Text(
                                      (document.data() as Map<String, dynamic>)[
                                          'SanPham'][index]['TenSP'],
                                      style: const TextStyle(fontSize: 12)),
                                  subtitle: Text(
                                      '${(document.data() as Map<String, dynamic>)['SanPham'][index]['SoLuong']} x ${NumberFormat('#,###,###').format((document.data() as Map<String, dynamic>)['SanPham'][index]['GiaSP'])} = ${NumberFormat('#,###,###').format((document.data() as Map<String, dynamic>)['SanPham'][index]['TongGia'])}',
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                );
                              },
                              itemCount: (document.data()
                                      as Map<String, dynamic>)['SanPham']
                                  .length,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 12, right: 12, top: 8, bottom: 8),
                              child: Card(
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      if (int.parse((document.data() as Map<
                                              String, dynamic>)['giamgia']) >
                                          0)
                                        SizedBox(
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Giảm giá : ',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    NumberFormat('#,###,###')
                                                        .format(
                                                      int.parse((document.data()
                                                                  as Map<String,
                                                                      dynamic>)[
                                                              'giamgia'] ??
                                                          '0'),
                                                    ),
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Mã giảm giá : ',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    (document.data() as Map<
                                                        String,
                                                        dynamic>)['magiamgia'],
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            'Phí vận chuyển : ',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            NumberFormat('#,###,###').format(
                                              (document.data() as Map<String,
                                                          dynamic>)[
                                                      'phivanchuyen'] ??
                                                  '0',
                                            ),
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        const Divider(
                          height: 3,
                          color: Colors.grey,
                        ),
                        (document.data()
                                    as Map<String, dynamic>)['trangthaidh'] ==
                                'Đã xác nhận'
                            ? Container(
                                color: Colors.grey[300],
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            TextButton(
                                              style: const ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStatePropertyAll<
                                                              Color>(
                                                          Colors.orange)),
                                              onPressed: () {
                                                // ignore: avoid_print
                                                print('Giao hàng');
                                              },
                                              child: const Text(
                                                'Chấp nhận',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 50,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            TextButton(
                                              style: const ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStatePropertyAll<
                                                              Color>(
                                                          Colors.blueAccent)),
                                              onPressed: () {
                                                generatePdf(document);
                                              },
                                              child: const Text(
                                                'In hoá đơn',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Container(
                                color: Colors.grey[300],
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      AbsorbPointer(
                                        absorbing: (document.data() as Map<
                                                    String,
                                                    dynamic>)['trangthaidh'] ==
                                                'Đã hủy đơn'
                                            ? true
                                            : false,
                                        child: TextButton(
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStatePropertyAll<
                                                      Color>((document.data()
                                                                  as Map<String,
                                                                      dynamic>)[
                                                              'trangthaidh'] ==
                                                          'Đã hủy đơn'
                                                      ? Colors.grey
                                                      : Colors.blue.shade900)),
                                          onPressed: () {
                                            showDialog('Xác nhận đơn hàng',
                                                'Đã xác nhận', document.id);
                                          },
                                          child: const Text(
                                            'Chấp nhận',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      AbsorbPointer(
                                        absorbing: (document.data() as Map<
                                                            String, dynamic>)[
                                                        'trangthaidh'] ==
                                                    'Đã từ chối' ||
                                                (document.data() as Map<String,
                                                            dynamic>)[
                                                        'trangthaidh'] ==
                                                    'Đã hủy đơn'
                                            ? true
                                            : false,
                                        child: TextButton(
                                          style: ButtonStyle(
                                              backgroundColor: (document.data()
                                                                  as Map<String,
                                                                      dynamic>)[
                                                              'trangthaidh'] ==
                                                          'Đã từ chối' ||
                                                      (document.data() as Map<
                                                                  String,
                                                                  dynamic>)[
                                                              'trangthaidh'] ==
                                                          'Đã hủy đơn'
                                                  ? const MaterialStatePropertyAll<Color>(
                                                      Colors.grey)
                                                  : const MaterialStatePropertyAll<Color>(
                                                      Colors.red)),
                                          onPressed: () {
                                            showDialog('Từ chối đơn hàng',
                                                'Đã từ chối', document.id);
                                          },
                                          child: const Text(
                                            'Từ chối',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        const Divider(
                          height: 3,
                          color: Colors.grey,
                        )
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  showDialog(title, status, documentId) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: const Text('Xác nhận lại lựa chọn'),
            actions: [
              TextButton(
                onPressed: () {
                  EasyLoading.show(status: 'Đang cập nhật...');
                  status == 'Đã xác nhận'
                      ? _orderServices
                          .updateOrderStatus(documentId, status)
                          .then((value) {
                          EasyLoading.showSuccess(
                              'Cập nhật đơn hàng thành công');
                        })
                      : _orderServices
                          .updateOrderStatus(documentId, status)
                          .then((value) {
                          EasyLoading.showSuccess(
                              'Cập nhật đơn hàng thành công');
                        });
                  Navigator.pop(context);
                },
                child: Text(
                  'Đồng ý',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Huỷ',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        });
  }
}
