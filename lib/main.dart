import 'dart:html';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:project_9shop_admin/provider/order_provider.dart';
import 'package:project_9shop_admin/screens/login_screen_v2.dart';
import 'package:provider/provider.dart';
import 'dart:ui_web' as uiWeb;

void main() async {
  uiWeb.platformViewRegistry.registerViewFactory(
      'example', (_) => DivElement()..innerText = 'Hello, HTML!');
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDw-EGpjos50SaaB2KBu_84BVkYSMpcU2A",
          authDomain: "shop-f6af8.firebaseapp.com",
          projectId: "shop-f6af8",
          storageBucket: "shop-f6af8.appspot.com",
          messagingSenderId: "1025357011797",
          appId: "1:1025357011797:web:2ecf4910ee564e71db6ddc",
          measurementId: "G-B5BZRVX178"));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => OrderProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class DefaultFirebaseOptions {}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse},
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreenV2(),
      builder: EasyLoading.init(),
    );
  }
}
