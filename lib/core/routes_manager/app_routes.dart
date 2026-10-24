import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:workforce/core/routes_manager/routes_name.dart';

import '../../faetures/auth/presentation/login_screen.dart';
import '../../faetures/auth/presentation/signup_screen.dart';


abstract class AppRoutes {
  static Route<dynamic>? getRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.login:
        return PageTransition(
          type: PageTransitionType.fade,
          child: LoginScreen(),
          settings: settings,
        );
      case RoutesName.signup:
        return PageTransition(
          type: PageTransitionType.fade,
          child: SignupScreen(),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
