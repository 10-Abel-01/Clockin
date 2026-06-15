import 'package:flutter/material.dart';
import 'package:Clockin/core/themes/app_theme.dart';
import 'package:Clockin/view/pages/login/login_page.dart';
import 'package:Clockin/view/pages/splash/splash_screen.dart';
// import 'package:Clockin/view/pages/shift/shift_page.dart' as shift;
import 'package:Clockin/view/pages/dashboard/menu_item_page/form_menu_item_page/izin_form_page.dart';
import 'package:Clockin/view/pages/dashboard/menu_item_page/form_menu_item_page/lembur_form_page.dart';
import 'package:Clockin/view/pages/dashboard/menu_item_page/izin_page.dart'
    as izin;
import 'package:Clockin/view/pages/dashboard/menu_item_page/lembur_page.dart'
    as lembur;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClockIn App',
      theme: AppTheme.lightTheme,
      initialRoute:
          RouteApp.initial,
      routes: RouteApp.routes,
    );
  }
}

class RouteApp {
  static const String initial = '/';
  // contoh bikin rutenya udah jelas ada disini nih, baca ya nanti!
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/login': (context) => const LoginPage(),
    '/lembur': (context) => const lembur.LemburPage(),
    // '/visit': (context) => const visit.VisitPage(),
    // '/shift': (context) => const shift.ShiftPage(),
    '/izin': (context) => izin.IzinPage(),
    '/izin-form': (context) => IzinFormPage(),
  };
}