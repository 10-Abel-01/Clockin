import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Clockin/view/pages/absensi/absensi_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:Clockin/model/model_dashboard.dart' as dashboardModel;
import 'package:Clockin/view/pages/dashboard/menu_item_page/izin_page.dart';
import 'package:Clockin/view/pages/dashboard/dashboard_page.dart';
import 'package:Clockin/view/pages/absensi/controller_absensi.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:Clockin/utils/logger.dart';

class DashboardController {
  Map<String, dynamic> userData = {};
  String? jadwalShift;
  String? jamShift;
  String? clockIn;
  String? clockOut;
  int totalHadir = 0;
  int totalIzin = 0;
  bool isLoading = true;
  final BuildContext context;
  final Map<String, dynamic> initialUserData;
  double? sisaCuti;
  Timer? _refreshTimer;

  DashboardController({required this.context, required this.initialUserData}) {
    userData = initialUserData;
  }

  Future<void> loadUserData(Function setState) async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      Log.d('Loaded user data from SharedPreferences.');
      setState(() {
        userData = jsonDecode(userDataString);
      });
    } else {
      Log.d('No user data found in SharedPreferences.');
    }
  }

  Future<void> fetchJadwalAndAbsensi(Function setState) async {
    try {
      final jadwalBulanan = await dashboardModel.fetchJadwalBulanan();
      final jadwalShiftVal = jadwalBulanan['jadwal_bulanan'];
      final shiftData = await AbsensiController().fetchShift(jadwalShiftVal);
      final karyawanId = int.parse(userData['id_karyawan'].toString());
      final history = await AbsensiController().fetchHistoryApi(karyawanId);
      final today = DateTime.now();
      // consider both 'tanggal_hadir' (absensi) and 'tanggal' (visit)
      final todayHistory = history.where((item) {
        final rawDate = item['tanggal_hadir'] ?? item['tanggal'] ?? item['tanggal_visit'];
        if (rawDate == null) return false;
        DateTime dt;
        try {
          dt = DateTime.parse(rawDate.toString());
        } catch (_) {
          return false;
        }
        return dt.year == today.year && dt.month == today.month && dt.day == today.day;
      }).toList();
      final lastAbsensi = todayHistory.isNotEmpty ? todayHistory.last : null;
      setState(() {
        jadwalShift = jadwalShiftVal;
        jamShift =
            '${_formatTime(shiftData['jam_masuk_shift'])} - ${_formatTime(shiftData['jam_pulang_shift'])} WIB';
        // prefer absensi times, fallback to visit times
        clockIn = lastAbsensi?['jam_absen_masuk'] ?? lastAbsensi?['jam'] ?? lastAbsensi?['jam_visit'] ?? '-';
        clockOut = lastAbsensi?['jam_absen_keluar'] ?? '-';
        final now = DateTime.now();
        // count unique dates (yyyy-MM-dd) in current month where there's at least one attendance or visit record
        final presenceDates = <String>{};
        for (final item in history) {
          final rawDate = item['tanggal_hadir'] ?? item['tanggal'] ?? item['tanggal_visit'];
          if (rawDate == null) continue;
          DateTime dt;
          try {
            dt = DateTime.parse(rawDate.toString());
          } catch (_) {
            continue;
          }
          if (dt.year != now.year || dt.month != now.month) continue;
          final hasTime = (item['jam_absen_masuk'] != null && item['jam_absen_masuk'].toString().isNotEmpty && item['jam_absen_masuk'] != '-') ||
              (item['jam_absen_keluar'] != null && item['jam_absen_keluar'].toString().isNotEmpty && item['jam_absen_keluar'] != '-') ||
              (item['jam'] != null && item['jam'].toString().isNotEmpty) ||
              (item['jam_visit'] != null && item['jam_visit'].toString().isNotEmpty) ||
              (item['tipe_absensi'] != null && item['tipe_absensi'].toString().toLowerCase() == 'visit');
          if (hasTime) {
            presenceDates.add(DateFormat('yyyy-MM-dd').format(dt));
          }
        }
        totalHadir = presenceDates.length;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching jadwal or absensi: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatTime(String? time) {
    if (time == null) return '-';
    final parsedTime = DateTime.parse('1970-01-01 $time');
    return DateFormat.Hm().format(parsedTime);
  }

  Future<void> fetchSisaCuti(Function setState) async {
    try {
      final karyawanId = userData['id_karyawan'];
      final apiUrl = dotenv.env['API_URL'] ?? '';
      final response = await http.post(
        Uri.parse('$apiUrl/api-kuota-cuti.php'),
        body: {'karyawan_id': karyawanId.toString()},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            sisaCuti = double.tryParse(data['sisa_kuota'].toString());
          });
        } else {
          Log.d('Failed to fetch sisa cuti: ${data['message']}');
        }
      } else {
        Log.d('Failed to fetch sisa cuti: ${response.statusCode}');
      }
    } catch (e) {
      Log.d('Error fetching sisa cuti: $e');
    }
  }

  Future<void> fetchIzinCount(Function setState) async {
    try {
      var karyawanId = userData['id_karyawan'];
      if (karyawanId == null) {
        final prefs = await SharedPreferences.getInstance();
        final userDataString = prefs.getString('user_data');
        if (userDataString != null) {
          final local = jsonDecode(userDataString);
          karyawanId = local['id_karyawan'];
          userData = local;
        }
      }
      if (karyawanId == null) return;
      final apiUrl = dotenv.env['API_URL'] ?? '';
      final response = await http.get(
        Uri.parse('$apiUrl/api-izin.php?karyawan_id=$karyawanId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final nowYear = DateTime.now().year;
          final izinList = List<Map<String, dynamic>>.from(data['data']);
          final izinThisYear = izinList.where((item) {
            final tanggalStr = item['tanggal_izin'] ?? item['tanggal'] ?? '';
            if (tanggalStr == null || tanggalStr.toString().isEmpty) return false;
            try {
              final dt = DateTime.parse(tanggalStr.toString());
              return dt.year == nowYear;
            } catch (e) {
              return false;
            }
          }).length;
          setState(() {
            totalIzin = izinThisYear;
          });
        }
      } else {
        Log.d('Failed to fetch izin count: ${response.statusCode}');
      }
    } catch (e) {
      Log.d('Error fetching izin count: $e');
    }
  }

  void startAutoRefresh(Function setState, {Duration interval = const Duration(seconds: 15)}) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(interval, (_) async {
      try {
        await fetchJadwalAndAbsensi(setState);
        await fetchSisaCuti(setState);
        await fetchIzinCount(setState);
      } catch (_) {
        // ignore periodic errors
      }
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  final int selectedIndex = 0;

  void onNavTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(userData: userData),
        ),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AbsensiPage(userData: userData),
        ),
      );
    }
  }

  void goToNotification() {
    Navigator.pushNamed(context, '/notification');
  }
}
