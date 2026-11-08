import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/signup_screen.dart';
import '../../features/chat/presentation/pages/chat_screen.dart';
import '../../features/chat/presentation/pages/conversations_screen.dart';
import '../../features/company/presentation/pages/activity_library_screen.dart';
import '../../features/company/presentation/pages/department_management_screen.dart';
import '../../features/employees/presentation/pages/employee_details_screen.dart';
import '../../features/employees/presentation/pages/employee_directory_screen.dart';
import '../../features/main_layout/presentation/pages/main_layout_screen.dart';
import '../../features/reports/presentation/pages/reports_screen.dart';
import '../../features/schedules/presentation/pages/schedule_builder_screen.dart';
import 'routes_name.dart';

abstract class AppRoutes {
  static Route<dynamic>? getRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.login:
        return PageTransition(
          type: PageTransitionType.fade,
          child: const LoginScreen(),
          settings: settings,
        );
      case RoutesName.signup:
        return PageTransition(
          type: PageTransitionType.fade,
          child: const SignupScreen(),
          settings: settings,
        );
      case RoutesName.forgotPassword:
        return PageTransition(
          type: PageTransitionType.fade,
          child: const ForgotPasswordScreen(),
          settings: settings,
        );
      case RoutesName.mainLayout:
        return PageTransition(
          type: PageTransitionType.fade,
          child: const MainLayoutScreen(),
          settings: settings,
        );
      case RoutesName.employeeManagement:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          child: const EmployeeDirectoryScreen(),
          settings: settings,
        );
      case RoutesName.employeeDetails:
        final employee = settings.arguments as UserEntity;
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          child: EmployeeDetailsScreen(employee: employee),
          settings: settings,
        );
      case RoutesName.departmentManagement:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          child: const DepartmentManagementScreen(),
          settings: settings,
        );
      case RoutesName.activityLibrary:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          child: const ActivityLibraryScreen(),
          settings: settings,
        );
      case RoutesName.scheduleBuilder:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          child: const ScheduleBuilderScreen(),
          settings: settings,
        );
      case RoutesName.reports:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          child: const ReportsScreen(),
          settings: settings,
        );
      case RoutesName.conversations:
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          child: const ConversationsScreen(),
          settings: settings,
        );
      case RoutesName.chat:
        final peerUser = settings.arguments as UserEntity;
        return PageTransition(
          type: PageTransitionType.rightToLeft,
          child: ChatScreen(peerUser: peerUser),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
