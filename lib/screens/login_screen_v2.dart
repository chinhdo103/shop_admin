import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_9shop_admin/others/app_colors.dart';
import 'package:project_9shop_admin/others/remember_admin.dart';
import 'package:project_9shop_admin/others/toast.dart';
import 'package:project_9shop_admin/screens/slide_menu_screen.dart';
import 'package:project_9shop_admin/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreenV2 extends StatefulWidget {
  const LoginScreenV2({super.key});

  @override
  State<LoginScreenV2> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<LoginScreenV2> {
  final TextEditingController _taikhoanController = TextEditingController();
  final TextEditingController _matkhauController = TextEditingController();
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();

  late SharedPreferences preferences;

  @override
  void initState() {
    super.initState();
    initPreferences();
    AuthenticationManager.initPreferences();
    if (AuthenticationManager.isUserLoggedIn()) {
      _redirectToMainScreen();
    }
  }

  // Khởi tạo SharedPreferences
  void initPreferences() async {
    preferences = await SharedPreferences.getInstance();
    String? savedUsername = preferences.getString('TenTK');
    if (savedUsername != null) {
      _redirectToMainScreen();
    }
  }

  // Đăng nhập thành công, lưu thông tin đăng nhập và điều hướng đến màn hình chính
  void loginSuccess() {
    AuthenticationManager.loginSuccess(_taikhoanController.text,
        role: 'Quản lý');
    _redirectToMainScreen();
  }

  // Xóa thông tin đăng nhập và điều hướng đến màn hình đăng nhập
  void logout() {
    AuthenticationManager.logout(); // Hiển thị màn hình đăng nhập
  }

  // Điều hướng đến màn hình chính
  void _redirectToMainScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SlideMenu()),
    );
  }

  @override
  Widget build(BuildContext context) {
    //lấy chiều cao và ngang của màng hình
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    //hàm xử lý đăng nhập
    Future<void> xacThucDangNhapAdmin(BuildContext context) async {
      try {
        if (_taikhoanController.text.isEmpty ||
            _matkhauController.text.isEmpty) {
          HienThiThongBaoSai("Hãy nhập tài khoản và mật khẩu");
        } else {
          FirebaseServices services = FirebaseServices();
          var querySnapshot = await services.taiKhoan
              .where('TenTK', isEqualTo: _taikhoanController.text)
              .limit(1)
              .get();

          // Check if any documents match the username
          if (querySnapshot.docs.isNotEmpty) {
            var adminData =
                querySnapshot.docs.first.data() as Map<String, dynamic>;

            var matKhau = adminData['MatKhau'];
            if (matKhau == _matkhauController.text) {
              // Password matches, perform login
              AuthenticationManager.loginSuccess(
                _taikhoanController.text,
                role: adminData['VaiTro'],
              );
              _redirectToMainScreen();

              HienThiThongBaoDung(
                  "Đăng nhập thành công tài khoản : ${adminData['HoVaTen']}");
            } else {
              // Incorrect password
              HienThiThongBaoSai("Tài khoản hoặc mật khẩu không đúng");
            }
          } else {
            // Username not found in 'TaiKhoan' collection
            HienThiThongBaoSai('Tài khoản không tồn tại');
          }
        }
        // Retrieve the document snapshot based on the entered username
      } on FirebaseException catch (e) {
        // Handle login errors, such as invalid email or password
        // ignore: avoid_print
        print('Error: $e');
        // Handle specific exceptions as needed
        if (e.code == 'permission-denied') {
          // Handle permission denied error
        } else {
          // Handle other errors
        }
      } catch (e) {
        // Handle other non-Firebase exceptions
        // ignore: avoid_print
        print('Non-Firebase Error: $e');
      }
    }

    return Scaffold(
      backgroundColor: AppColors.backColor,
      body: SizedBox(
        height: height,
        width: width,
        child: Form(
          key: _formKey, // Assign the key to the Form
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  height: height,
                  color: AppColors.mainBlueColor,
                  child: Center(
                    child: Text(
                      ' (^-^) \n Trang Quản Lí',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.raleway().copyWith(
                        fontSize: 48.0,
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: height,
                  margin: EdgeInsets.symmetric(horizontal: height * 0.12),
                  color: AppColors.backColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: height * 0.145),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: ' Đăng nhập',
                              style: GoogleFonts.raleway().copyWith(
                                fontSize: 25,
                                color: AppColors.blueDarkColor,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text: '\n  để tiếp tục',
                              style: GoogleFonts.raleway().copyWith(
                                fontSize: 20,
                                color: AppColors.blueDarkColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: height * 0.02,
                      ),
                      Text(
                        'Đăng nhập bằng tài khoản admin của bạn đề truy cập vào trang quản lý',
                        style: GoogleFonts.raleway().copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: height * 0.064),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          'Tài Khoản',
                          style: GoogleFonts.raleway().copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blueDarkColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 50,
                        width: width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.whiteColor,
                        ),
                        child: TextFormField(
                          controller: _taikhoanController,
                          onFieldSubmitted: (_) {
                            // No action for username field
                          },
                          style: GoogleFonts.raleway().copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColors.blueDarkColor,
                            fontSize: 12,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.email),
                            ),
                            contentPadding: const EdgeInsets.only(top: 16),
                            hintText: 'Nhập tài khoản email',
                            hintStyle: GoogleFonts.raleway().copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.blueDarkColor.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.014),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          'Mật khẩu',
                          style: GoogleFonts.raleway().copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blueDarkColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 50,
                        width: width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.whiteColor,
                        ),
                        child: TextFormField(
                          controller: _matkhauController,
                          style: GoogleFonts.raleway().copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppColors.blueDarkColor,
                            fontSize: 12,
                          ),
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                              icon: Icon(
                                _isObscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                            prefixIcon: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.password),
                            ),
                            contentPadding: const EdgeInsets.only(top: 16),
                            hintText: 'Nhập mật khẩu',
                            hintStyle: GoogleFonts.raleway().copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.blueDarkColor.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.05,
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            xacThucDangNhapAdmin(context);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 70, vertical: 18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: AppColors.mainBlueColor,
                            ),
                            child: Text(
                              'Đăng nhập',
                              style: GoogleFonts.raleway().copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.whiteColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
