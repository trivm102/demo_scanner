import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreferences {
  static Future<void> setRequestCameraPermission() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('request_camera_permission', 1);
  }

  static Future<int?> getRequestCameraPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('request_camera_permission');
  }
}
