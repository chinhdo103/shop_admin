import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void HienThiThongBaoDung(String thongbao) {
  Fluttertoast.showToast(
    msg: thongbao,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 2,
    textColor: Colors.white,
    // webBgColor: "linear-gradient(to right, #dc1c13, #dc1c13)",
    webPosition: "center",
    webShowClose: false,
    fontSize: 16.0,
  );
}

void HienThiThongBaoSai(String thongbao) {
  Fluttertoast.showToast(
    msg: thongbao,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 2,
    textColor: Colors.white,
    webBgColor: "linear-gradient(to right, #dc1c13, #dc1c13)",
    webPosition: "center",
    webShowClose: false,
    fontSize: 16.0,
  );
}
