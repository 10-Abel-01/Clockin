import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Clockin/model/model_profile.dart';
import 'package:Clockin/model/model_jabatan.dart';
import 'package:Clockin/view/pages/dashboard/dashboard_page.dart';
import 'package:Clockin/view/pages/absensi/absensi_page.dart';
import 'package:Clockin/view/pages/profile/profile_page.dart';
import 'package:Clockin/utils/logger.dart';

class ProfileController {
  ProfileModel userData;
  final BuildContext context;
  final int selectedIndex = 2;

  ProfileController({required this.userData, required this.context});

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('user_data');

    if (stored != null) {
      final decoded = jsonDecode(stored);
      if (decoded is Map<String, dynamic>) {
        userData = ProfileModel.fromJson(decoded);
      }
    }
  }

  Future<void> fetchProfileData() async {
    final apiUrl = dotenv.env['API_URL'] ?? '';
    final uri = Uri.parse(
      '$apiUrl/api-profile.php?id_karyawan=${userData.idKaryawan}',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      _showMessage('Server error ${response.statusCode}');
      Log.e('Error fetching profile data: ${response.body}');
      return;
    }

    final result = jsonDecode(response.body);
    if (result['success'] != true || result['data'] == null) {
      _showMessage(result['message'] ?? 'Gagal memuat profil');
      Log.e('Failed to load profile data: ${response.body}');
      return;
    }

    userData = ProfileModel.fromJson(result['data']);

    final jabatanRes = await http.get(
      Uri.parse('$apiUrl/api-jabatan.php?id_karyawan=${userData.idKaryawan}'),
    );

    if (jabatanRes.statusCode == 200) {
      final jabatanJson = jsonDecode(jabatanRes.body);
      Log.d('Jabatan API response: ${jabatanRes.body}');
      if (jabatanJson['success'] == true &&
          jabatanJson['data'] is Map<String, dynamic>) {
        userData = userData.copyWith(
          jabatan: JabatanModel.fromJson(jabatanJson['data']),
        );
      } else {
        Log.e('Failed to load jabatan data: ${jabatanRes.body}');
      }
    } else {
      Log.e('Error fetching jabatan data: ${jabatanRes.body}'
      );
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user_data', jsonEncode(userData.toJson()));
  }

  void onNavTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(userData: userData.toJson()),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AbsensiPage(userData: userData.toJson()),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfilePage(userData: userData)),
      );
    }
  }

  Future<void> logout() async {
    final apiUrl = dotenv.env['API_URL'] ?? '';
    final response = await http.post(
      Uri.parse('${apiUrl}api-logout.php'),
      body: {'id_karyawan': userData.idKaryawan.toString()},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      } else {
        _showMessage(result['message'] ?? 'Logout gagal');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
