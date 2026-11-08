import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/cach/shared_prefs.dart';
import 'core/di/di.dart';
import 'core/routes_manager/app_routes.dart';
import 'core/utils/theme/app_theme.dart';
import 'core/utils/theme/theme_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/auth_wrapper.dart';
import 'features/attendance/presentation/cubit/attendance_cubit.dart';
import 'features/company/presentation/cubit/company_cubit.dart';
import 'features/employees/presentation/cubit/employee_cubit.dart';
import 'features/reports/presentation/cubit/report_cubit.dart';
import 'features/requests/presentation/cubit/request_cubit.dart';
import 'features/schedules/presentation/cubit/schedule_cubit.dart';

class WorkforceApp extends StatelessWidget {
  const WorkforceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit(SharedPrefs.sharedPrefs)),
        BlocProvider(create: (context) => getIt<AuthCubit>()..checkAuthStatus()),
        BlocProvider(create: (context) => getIt<ScheduleCubit>()),
        BlocProvider(create: (context) => getIt<AttendanceCubit>()),
        BlocProvider(create: (context) => getIt<RequestCubit>()),
        BlocProvider(create: (context) => getIt<CompanyCubit>()),
        BlocProvider(create: (context) => getIt<EmployeeCubit>()),
        BlocProvider(create: (context) => getIt<ReportCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, state) {
          return ScreenUtilInit(
            designSize: const Size(430, 932),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) => MaterialApp(
              title: 'Workforce Pro',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: state,
              home: const AuthWrapper(),
              onGenerateRoute: AppRoutes.getRoute,
            ),
          );
        },
      ),
    );
  }
}
