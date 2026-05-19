// import 'package:flutter/material.dart';
// import 'package:Clockin/model/model_shift.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:Clockin/view/pages/dashboard/dashboard_page.dart';
// import 'package:Clockin/view/pages/absensi/absensi_page.dart';
// import 'package:Clockin/model/model_shift.dart' as shiftModel;
// import 'package:Clockin/model/model_dashboard.dart' as dashboardModel;
// class ControllerShift {
//   ShiftModel userData;
//   final BuildContext context;
//   final int selectedIndex = 2;

//   ControllerShift({required this.userData, required this.context});

//   /// Load dari SharedPreferences (AMAN)
//   Future<void> loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final stored = prefs.getString('user_data');

//     if (stored != null) {
//       final decoded = jsonDecode(stored);
//       if (decoded is Map<String, dynamic>) {
//         userData = ShiftModel.fromJson(decoded);
//       }
//     }
//   }

//   void onNavTap(int index) {
//     if (index == 0) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => DashboardPage(userData: userData.toJson()),
//         ),
//       );
//     } else if (index == 1) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => AbsensiPage(userData: userData.toJson()),
//         ),
//       );
//     }
//   }
// }
