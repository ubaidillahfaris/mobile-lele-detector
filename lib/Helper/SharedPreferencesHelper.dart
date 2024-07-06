import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _keyBaseUrl = "baseUrl";

  static Future<void> saveBaseUrl(String baseUrl) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBaseUrl, baseUrl);
  }

  static Future<String?> getBaseUrl() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBaseUrl);
  }
}