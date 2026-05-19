import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'form_menu_item_page/lembur_form_page.dart';
import '../../../components/custom_bottom_nav.dart';
import 'package:Clockin/view/pages/dashboard/dashboard_page.dart';
import 'package:Clockin/view/pages/absensi/absensi_page.dart';
import 'package:Clockin/view/pages/profile/profile_page.dart';
import 'package:Clockin/model/model_profile.dart';
import 'package:Clockin/utils/logger.dart';

class LemburController {
  List<Map<String, dynamic>> lemburList = [];
  int currentIndex = 1;
  Map<String, dynamic> userData = {};
  final BuildContext context;

  LemburController({required this.context});

  Future<void> loadUserData(Function setState) async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      setState(() {
        userData = jsonDecode(userDataString);
      });
    }
  }

  Future<void> loadLemburData(Function setState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        final userDataLocal = jsonDecode(userDataString);
        final karyawanId = userDataLocal['id_karyawan'];
        final apiUrl = dotenv.env['API_URL'] ?? '';
        final response = await http.get(
          Uri.parse('${apiUrl}api-lembur.php?karyawan_id=$karyawanId'),
        );
        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          if (result['success'] == true) {
            setState(() {
              lemburList = List<Map<String, dynamic>>.from(result['data']);
            });
          } else {
            Log.d('Failed to load lembur: ${result['message']}');
          }
        } else {
          Log.d('Failed to load lembur: ${response.statusCode}');
        }
      }
    } catch (e) {
      Log.d('Error loading lembur data: $e');
    }
  }

  Future<void> navigateToLemburForm({
    Map<String, dynamic>? initialData,
    Function? setState,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LemburFormPage(initialData: initialData),
      ),
    );
    if (result != null && setState != null) {
      loadLemburData(setState);
    }
  }

  Future<void> editLembur(int index, Function setState) async {
    final lembur = lemburList[index];
    final updatedLembur = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LemburFormPage(initialData: lembur),
      ),
    );
    if (updatedLembur != null) {
      try {
        final apiUrl = dotenv.env['API_URL'] ?? '';
        final response = await http.put(
          Uri.parse('${apiUrl}api-lembur.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id_lembur': lembur['id_lembur'].toString(),
            'tanggal_lembur': updatedLembur['tanggal_lembur'],
            'deskripsi_lembur': updatedLembur['deskripsi_lembur'],
            'atasan': updatedLembur['atasan'],
          }),
        );
        final result = json.decode(response.body);
        if (result['success'] == true) {
          loadLemburData(setState);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data lembur berhasil diperbarui.')),
          );
        } else {
          throw Exception(result['message']);
        }
      } catch (e) {
        Log.d('Error updating lembur: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memperbarui lembur: $e')));
      }
    }
  }

  Future<void> deleteLembur(int index, Function setState) async {
    try {
      final lembur = lemburList[index];
      final apiUrl = dotenv.env['API_URL'] ?? '';
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Konfirmasi'),
              content: const Text(
                'Apakah Anda yakin ingin menghapus lembur ini?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Hapus'),
                ),
              ],
            ),
      );
      if (shouldDelete != true) return;
      final response = await http.post(
        Uri.parse('${apiUrl}api-lembur.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          '_method': 'DELETE',
          'id_lembur': lembur['id_lembur'].toString(),
        }),
      );
      final result = json.decode(response.body);
      if (result['success'] == true) {
        setState(() {
          lemburList.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data lembur berhasil dihapus.')),
        );
        loadLemburData(setState);
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      Log.d('Error deleting lembur: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus lembur: $e')));
    }
  }

  String formatDate(String date) {
    final dateTime = DateTime.parse(date);
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  void onNavTap(int idx, Function setState) {
    currentIndex = idx;
    if (idx == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(userData: userData),
        ),
      );
    } else if (idx == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AbsensiPage(userData: userData),
        ),
      );
    } else if (idx == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  ProfilePage(userData: ProfileModel.fromJson(userData)),
        ),
      );
    }
  }
}
