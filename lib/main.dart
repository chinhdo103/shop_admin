import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:project_9shop_admin/screens/category_screen.dart';
import 'package:project_9shop_admin/screens/dashboard_screen.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:project_9shop_admin/screens/main_category_screen.dart';
import 'package:project_9shop_admin/screens/sub_category_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '9Shop Admin',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const SlideMenu(),
    );
  }
}

class SlideMenu extends StatefulWidget {
  static const String id = 'slide-menu';

  const SlideMenu({super.key});

  @override
  State<SlideMenu> createState() => _SlideMenuState();
}

class _SlideMenuState extends State<SlideMenu> {
  Widget _selectedScreen = const DashBoardScreen();
  final dateTime = DateTime.now();
  screenSelector(item) {
    switch (item.route) {
      case DashBoardScreen.id:
        setState(() {
          _selectedScreen = const DashBoardScreen();
        });
        break;
      case CategoryScreen.id:
        setState(() {
          _selectedScreen = const CategoryScreen();
        });
        break;
      case MainCategoryScreen.id:
        setState(() {
          _selectedScreen = const MainCategoryScreen();
        });
        break;
      case SubCategoryScreen.id:
        setState(() {
          _selectedScreen = const SubCategoryScreen();
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Trang Quản Lý 9Shop',
          style: TextStyle(letterSpacing: 1),
        ),
      ),
      sideBar: SideBar(
        items: const [
          AdminMenuItem(
            title: 'Tổng Quan',
            route: DashBoardScreen.id,
            icon: Icons.dashboard,
          ),
          AdminMenuItem(
            title: 'Các Danh Mục',
            icon: IconlyLight.category,
            children: [
              AdminMenuItem(
                title: 'Danh Mục',
                route: CategoryScreen.id,
              ),
              AdminMenuItem(
                title: 'Danh Mục Chính',
                route: MainCategoryScreen.id,
              ),
              AdminMenuItem(
                title: 'Danh Mục Phụ',
                route: SubCategoryScreen.id,
              ),
            ],
          ),
        ],
        selectedRoute: SlideMenu.id,
        onSelected: (item) {
          screenSelector(item);
          // if (item.route != null) {
          //   Navigator.of(context).pushNamed(item.route!);
          // }
        },
        header: Container(
          height: 50,
          width: double.infinity,
          color: const Color(0xff444444),
          child: const Center(
            child: Text(
              'Danh Mục',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
        footer: Container(
          height: 50,
          width: double.infinity,
          color: const Color(0xff444444),
          child: Center(
            child: Text(
              // ignore: unnecessary_string_interpolations
              '${DateTimeFormat.format(DateTime.now(), format: AmericanDateFormats.dayOfWeek)}',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: _selectedScreen,
      ),
    );
  }
}
