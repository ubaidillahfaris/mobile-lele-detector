import 'package:flutter/material.dart';
import 'package:object_detector_lele/Helper/SharedPreferencesHelper.dart';

class ConfigApp{

  // static String baseUrl = 'http://192.168.18.159:8000';

  static Future<String?> baseUrl() async {
    String? url = await SharedPreferencesHelper.getBaseUrl();
    if (url != null) {
      return 'http://${url}:8000';
    }
  }

  static Map<String, Color> colors = {
    'primary' : Color(0xFF0583F2),
    'secondary' : Color(0xFFF2055C),
    'tersier' : Color(0xFFF25D07),
    'dark_blue' : Color(0xFF034C8C),
  };
}