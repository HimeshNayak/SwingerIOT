import 'package:shared_preferences/shared_preferences.dart';

class User {
  String? userName, email, uid, type;
  User() {
    getUserDetails();
  }
  Future<void> getUserDetails() async {
    await SharedPreferences.getInstance().then((_prefs) {
      userName = _prefs.getString('userName');
      email = _prefs.getString('email');
      uid = _prefs.getString('uid');
      type = _prefs.getString('type') ?? 'LOGIN';
    });
    return;
  }

  Future<String?> getType() async {
    return type;
  }
}
