import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:Clockin/view/pages/dashboard/dashboard_page.dart';
import 'package:Clockin/view/pages/absensi/absensi_page.dart';
import 'package:Clockin/view/pages/profile/profile_page.dart';
import 'package:Clockin/model/model_profile.dart';
import 'form_menu_item_page/izin_form_page.dart';
import 'package:Clockin/utils/logger.dart';

class IzinController {
  List<Map<String, dynamic>> izinList = [];
  int currentIndex = 1;
  Map<String, dynamic> userData = {};
  List<String> statusList = ["Pending", "Disetujui", "Ditolak"];
  List<Color> statusColor = [
    Color(0xFFFFC107),
    Color(0xFF00C853),
    Color(0xFFD32F2F),
  ];
  List<Color> statusTextColor = [Colors.black, Colors.white, Colors.white];
  List<String> statusKey = ["Pending", "Disetujui", "Ditolak"];
  List<IconData> statusIcon = [
    Icons.expand_more,
    Icons.expand_less,
    Icons.expand_more,
  ];
  List<bool> expanded = [];
  final BuildContext context;

  IzinController({required this.context});

  Future<void> loadUserData(Function setState) async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      setState(() {
        userData = jsonDecode(userDataString);
      });
      Log.d('User data loaded: $userData');
    } else {
      Log.d('No user data found in SharedPreferences.');
    }
  }

  Future<void> loadIzinData(Function setState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        final userDataLocal = jsonDecode(userDataString);
        final karyawanId = userDataLocal['id_karyawan'];
        final apiUrl = dotenv.env['API_URL'] ?? '';
        final response = await http.get(
          Uri.parse('$apiUrl/api-izin.php?karyawan_id=$karyawanId'),
        );
        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          if (result['success'] == true) {
            setState(() {
              izinList = List<Map<String, dynamic>>.from(result['data']);
            });
          } else {
            Log.d('Failed to load izin: ${result['message']}');
          }
        } else {
          Log.d('Failed to load izin: ${response.statusCode}');
        }
      }
    } catch (e) {
      Log.d('Error loading izin data: $e');
    }
  }

  Future<void> deleteIzin(int index, Function setState) async {
    try {
      final izin = izinList[index];
      final apiUrl = dotenv.env['API_URL'] ?? '';
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Konfirmasi'),
              content: const Text(
                'Apakah Anda yakin ingin menghapus izin ini?',
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
      final response = await http.delete(
        Uri.parse('${apiUrl}api-izin.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_izin': izin['id_izin'].toString(),
        }),
      );
      final result = json.decode(response.body);
      if (result['success'] == true) {
        setState(() {
          izinList.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data izin berhasil dihapus.')),
        );
        await loadIzinData(setState);
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      Log.d('Error deleting izin: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus izin: $e')));
    }
  }

  Future<void> editIzin(int index, Function setState) async {
    final updatedIzin = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IzinFormPage(initialData: izinList[index]),
      ),
    );
    if (updatedIzin != null) {
      try {
        final apiUrl = dotenv.env['API_URL'] ?? '';
        final Map<String, String> requestData = {
          'id_izin': izinList[index]['id_izin'].toString(),
          'jenis_izin': updatedIzin['jenis_izin'],
          'lama_izin': updatedIzin['lama_izin'],
          'tanggal_izin': updatedIzin['tanggal_izin'],
          'deskripsi_izin': updatedIzin['deskripsi_izin'],
        };
        final response = await http.put(
          Uri.parse('${apiUrl}api-izin.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );
        final result = json.decode(response.body);
        if (result['success'] == true) {
          setState(() {
            izinList[index] = {
              ...updatedIzin,
              'id_izin': izinList[index]['id_izin'],
            };
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data izin berhasil diperbarui.')),
          );
        } else {
          throw Exception(result['message']);
        }
      } catch (e) {
        Log.d('Error updating izin: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memperbarui izin: $e')));
      }
    }
  }

  void onNavTap(int idx, Function setState) {
    currentIndex = idx;
    if (idx == 0) {
      if (userData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data pengguna tidak ditemukan.')),
        );
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(userData: userData),
        ),
      );
    } else if (idx == 1) {
      if (userData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data pengguna tidak ditemukan.')),
        );
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AbsensiPage(userData: userData),
        ),
      );
    } else if (idx == 2) {
      if (userData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data pengguna tidak ditemukan.')),
        );
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => ProfilePage(
                userData: ProfileModel(
                  idKaryawan: userData['id_karyawan'] ?? 0,
                  namaKaryawan: userData['nama_karyawan'] ?? '',
                  jenisKelamin: userData['jenis_kelamin'] ?? '',
                  tanggalLahir: userData['tanggal_lahir'] ?? '',
                  fotoProfil: userData['foto_profil'] ?? '',
                  noTelp: userData['no_telp'] ?? '',
                  email: userData['email'] ?? '',
                  bank: userData['bank'],
                  rekening: userData['rekening'],
                ),
              ),
        ),
      );
    }
  }

  String formatTanggal(String? tanggal) {
    if (tanggal == null) return '-';
    try {
      final tgl = DateTime.parse(tanggal);
      final bulan = [
        '',
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
      return '${tgl.day} ${bulan[tgl.month]} ${tgl.year}';
    } catch (e) {
      return tanggal;
    }
  }
}
