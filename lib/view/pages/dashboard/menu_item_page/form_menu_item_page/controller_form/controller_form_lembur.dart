import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LemburFormController {
  final BuildContext context;
  final Map<String, dynamic>? initialData;
  final Map<String, String?> selectedItems = {};
  DateTime selectedDate = DateTime.now();
  final TextEditingController deskripsiController = TextEditingController();
  String? uploadedFile;
  String? name;
  String? nik;

  LemburFormController({required this.context, this.initialData}) {
    if (initialData != null) {
      if (initialData!['tanggal_lembur'] != null &&
          initialData!['tanggal_lembur'].toString().isNotEmpty) {
        selectedDate = DateTime.parse(initialData!['tanggal_lembur']);
      }
      if (initialData!['deskripsi_lembur'] != null) {
        deskripsiController.text = initialData!['deskripsi_lembur'].toString();
      }
      if (initialData!['atasan'] != null) {
        selectedItems['Atasan'] = initialData!['atasan'].toString();
      }
    }
  }

  Future<void> loadUserData(Function setState) async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      setState(() {
        name = userData['nama_karyawan'];
        nik = userData['id_karyawan'].toString();
      });
    }
  }

  Future<void> pickDate(Function setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> uploadPdfFile(Function setState) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      final file = File(result.files.single.path!);
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File terlalu besar. Maksimal 5 MB.')),
        );
        return;
      }
      final ext = result.files.single.extension?.toLowerCase() ?? '';
      final allowed = ['pdf', 'jpg', 'jpeg', 'png'];
      if (!allowed.contains(ext)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipe file tidak didukung.')),
        );
        return;
      }

      setState(() {
        uploadedFile = result.files.single.path;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File berhasil dipilih.')));
    }
  }

  Future<void> submitLembur(Function setState) async {
    String? errorMessage;
    if (name == null || nik == null) {
      errorMessage = 'Data karyawan tidak lengkap. Silakan login ulang.';
    } else if (deskripsiController.text.trim().isEmpty) {
      errorMessage = 'Deskripsi lembur wajib diisi.';
    } else if (selectedItems['Atasan'] == null) {
      errorMessage = 'Silakan pilih atasan terlebih dahulu.';
    }
    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Data pengguna tidak ditemukan. Silakan login ulang.',
            ),
          ),
        );
        return;
      }
      final userData = jsonDecode(userDataString);
      final userId = userData['id_karyawan'];
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID karyawan tidak ditemukan. Silakan login ulang.'),
          ),
        );
        return;
      }
      final apiUrl = dotenv.env['API_URL'] ?? '';
      if (apiUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konfigurasi API tidak ditemukan.')),
        );
        return;
      }
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${apiUrl}api-lembur.php'),
      );
      request.fields.addAll({
        'karyawan_id': userId.toString(),
        'tanggal_lembur': "${selectedDate.toLocal()}".split(' ')[0],
        'deskripsi_lembur': deskripsiController.text.trim(),
        'atasan': selectedItems['Atasan']!,
      });
      if (uploadedFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('lampiran', uploadedFile!),
        );
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw FormatException('Empty response received from server');
        }
        try {
          final result = json.decode(response.body);
          if (result['success'] == true) {
            Navigator.pop(context, request.fields);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data lembur berhasil disimpan')),
            );
          } else {
            throw Exception(result['message'] ?? 'Gagal menyimpan data lembur');
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memproses response dari server: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
