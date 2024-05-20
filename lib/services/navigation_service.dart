import 'package:fire_base_flutter_chat/pages/home_page.dart';
import 'package:fire_base_flutter_chat/pages/login_page.dart';
import 'package:fire_base_flutter_chat/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class NavigationService {
  late GlobalKey<NavigatorState> _navigatorKey;

  final Map<String, Widget Function(BuildContext)> _routes = {
    "/login": (context) => LoginPage(),
    "/home": (context) => HomePage(),
    "/register": (context) => RegisterPage(),
  };

  Map<String, Widget Function(BuildContext)> get routes => _routes;
  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;
  NavigationService() {
    _navigatorKey = GlobalKey<NavigatorState>();
  }

  void pushNamed(String routeName) {
    _navigatorKey.currentState?.pushNamed(routeName);
  }

  void push(MaterialPageRoute route) {
    _navigatorKey.currentState?.push(route);
  }

  void pushReplacementNamed(String routeName) {
    _navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  void goBack() {
    _navigatorKey.currentState?.pop();
  }
}
