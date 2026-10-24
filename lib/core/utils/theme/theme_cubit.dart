import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences sharedPreferences;

  ThemeCubit(this.sharedPreferences)
    : super(
        sharedPreferences.getString("theme") == "dark"
            ? ThemeMode.dark
            : ThemeMode.light,
      );
  void toggleTheme() {
    if (state == ThemeMode.dark) {
      sharedPreferences.setString("theme", "light");
      emit(ThemeMode.light);
    } else {
      sharedPreferences.setString("theme", "dark");
      emit(ThemeMode.dark);
    }
  }
}
