import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:project_9shop_admin/others/remember_admin.dart';
import 'package:project_9shop_admin/screens/account_admin_screen.dart';
import 'package:project_9shop_admin/screens/account_user_screen.dart';
import 'package:project_9shop_admin/screens/banner_screen.dart';
import 'package:project_9shop_admin/screens/category_screen.dart';
import 'package:project_9shop_admin/screens/coupon_screen.dart';
import 'package:project_9shop_admin/screens/dashboard_screen.dart';
import 'package:project_9shop_admin/screens/inventory/inventory_screen.dart';
import 'package:project_9shop_admin/screens/login_screen_v2.dart';
import 'package:project_9shop_admin/screens/main_category_screen.dart';
import 'package:project_9shop_admin/screens/orders_screen.dart';
import 'package:project_9shop_admin/screens/orders_statistical_screen.dart';
import 'package:project_9shop_admin/screens/product_screen.dart';
import 'package:project_9shop_admin/screens/product_store_screen.dart';
import 'package:project_9shop_admin/screens/statistical_scree.dart';
import 'package:project_9shop_admin/screens/storehouse_screen.dart';
import 'package:project_9shop_admin/screens/sub_category_screen.dart';
import 'package:intl/intl.dart'; // Import thư viện intl

class SlideMenu extends StatefulWidget {
  static const String id = 'slide-menu';

  const SlideMenu({super.key});

  @override
  State<SlideMenu> createState() => _SlideMenuState();
}

class _SlideMenuState extends State<SlideMenu> {
  Widget _selectedScreen = const DashBoardScreen();
  final dateTime = DateTime.now();
  bool canAccessScreen(String requiredRole) {
    String? userRole = AuthenticationManager.getRole();
    return userRole == requiredRole;
  }

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
      case AccountAdminScreen.id:
        setState(() {
          _selectedScreen = const AccountAdminScreen();
        });
        break;
      case ProductScreen.id:
        setState(() {
          _selectedScreen = const ProductScreen();
        });
        break;
      case BannerScreen.id:
        setState(() {
          _selectedScreen = const BannerScreen();
        });
        break;
      case CouponScreen.id:
        setState(() {
          _selectedScreen = const CouponScreen();
        });
        break;
      case OrderScreen.id:
        setState(() {
          _selectedScreen = const OrderScreen();
        });
        break;
      case AccountUserScreen.id:
        setState(() {
          _selectedScreen = const AccountUserScreen();
        });
        break;
      case InventoryScreen.id:
        setState(() {
          _selectedScreen = const InventoryScreen();
        });
        break;
      case StoreHouse.id:
        setState(() {
          _selectedScreen = const StoreHouse();
        });
        break;
      case ProductStore.id:
        setState(() {
          _selectedScreen = const ProductStore();
        });
        break;
      case StatisticalScreen.id:
        setState(() {
          _selectedScreen = const StatisticalScreen();
        });
        break;
      case OrdersStatisticalScreen.id:
        setState(() {
          _selectedScreen = const OrdersStatisticalScreen();
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
          actions: [
            IconButton(
                onPressed: () {
                  AuthenticationManager.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreenV2()),
                  );
                },
                icon: const Icon(IconlyLight.logout))
          ]),
      sideBar: SideBar(
        items: [
          const AdminMenuItem(
            title: 'Tổng Quan',
            route: DashBoardScreen.id,
            icon: Icons.dashboard,
          ),
          const AdminMenuItem(
            title: 'Quản Lý Mã Giảm Giá',
            route: CouponScreen.id,
            icon: Icons.card_membership_rounded,
          ),
          const AdminMenuItem(
            title: 'Quản Lý Kho',
            route: InventoryScreen.id,
            icon: Icons.inventory_2_outlined,
          ),
          const AdminMenuItem(
            title: 'Quản Lý Nhà Kho',
            icon: Icons.house,
            children: [
              AdminMenuItem(
                title: 'Nhà kho',
                route: StoreHouse.id,
              ),
              AdminMenuItem(
                title: 'Sản phẩm thuộc nhà kho',
                route: ProductStore.id,
              ),
            ],
          ),
          const AdminMenuItem(
            title: 'Quảng Cáo',
            route: BannerScreen.id,
            icon: Icons.branding_watermark,
          ),
          const AdminMenuItem(
            title: 'Quản Lí Đơn Hàng',
            route: OrderScreen.id,
            icon: Icons.list_alt_sharp,
          ),
          AdminMenuItem(
            title: 'Quản Lí Tài Khoản',
            icon: IconlyLight.user3,
            children: [
              if (canAccessScreen('Quản lý'))
                const AdminMenuItem(
                  title: 'Tài Khoản Admin',
                  route: AccountAdminScreen.id,
                ),
              const AdminMenuItem(
                title: 'Tài Khoản Khách Hàng',
                route: AccountUserScreen.id,
              ),
            ],
          ),
          const AdminMenuItem(
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
          const AdminMenuItem(
            title: 'Sản Phẩm',
            icon: IconlyLight.activity,
            children: [
              AdminMenuItem(
                title: 'Tất cả sản phẩm',
                route: ProductScreen.id,
              ),
            ],
          ),
          const AdminMenuItem(
            title: 'Thống kê',
            icon: Icons.article,
            children: [
              AdminMenuItem(
                title: 'Thống kê tổng quan',
                route: StatisticalScreen.id,
              ),
              AdminMenuItem(
                title: 'Thống kê đơn hàng theo ngày',
                route: OrdersStatisticalScreen.id,
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
              '${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
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
