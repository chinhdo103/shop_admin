import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationManager {
  static SharedPreferences? preferences;

  static void initPreferences() async {
    preferences = await SharedPreferences.getInstance();
  }

  static String? getRole() {
    return preferences?.getString('VaiTro');
  }

  static void loginSuccess(String username, {String? role}) {
    preferences?.setString('TenTK', username);
    preferences?.setString('VaiTro', role!);
  }

  static bool isUserLoggedIn() {
    return preferences?.getString('TenTK') != null;
  }

  static void logout() {
    preferences?.remove('TenTK');
  }
}
