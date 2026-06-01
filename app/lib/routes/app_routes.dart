import 'package:flutter/material.dart';
import '../features/auth/screens/phone_input_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    "/": (context) => const PhoneInputScreen(),
  };
}
