import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/cach/shared_prefs.dart';
import 'core/routes_manager/app_routes.dart';
import 'core/routes_manager/routes_name.dart';
import 'core/utils/theme/app_theme.dart';
import 'core/utils/theme/theme_cubit.dart';

class WorkforceApp extends StatelessWidget {
  const WorkforceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(SharedPrefs.sharedPrefs),
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
              initialRoute: RoutesName.login,
              onGenerateRoute: AppRoutes.getRoute,
            ),
          );
        },
      ),
    );
  }
}
