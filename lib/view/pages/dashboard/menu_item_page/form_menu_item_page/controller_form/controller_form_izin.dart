import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class IzinFormController {
  final BuildContext context;
  final Map<String, dynamic>? initialData;
  final Map<String, String?> selectedItems = {};
  DateTime selectedDate = DateTime.now();
  final TextEditingController deskripsiController = TextEditingController();
  String? uploadedFile;

  IzinFormController({required this.context, this.initialData}) {
    if (initialData != null) {
      selectedItems['Jenis Izin'] = initialData!['jenis_izin'];
      selectedItems['Jenis Permintaan'] = initialData!['lama_izin'];
      selectedDate = DateTime.parse(initialData!['tanggal_izin']);
      deskripsiController.text = initialData!['deskripsi_izin'];
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
      // ensure extension is allowed (defensive)
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

  Future<void> submitIzin(Function setState) async {
    if (selectedItems['Jenis Izin'] == null ||
        selectedItems['Jenis Permintaan'] == null ||
        deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua data sebelum mengirim.'),
        ),
      );
      return;
    }
    if (selectedItems['Jenis Permintaan'] != 'Sehari Penuh' &&
        selectedItems['Jenis Permintaan'] != 'Setengah Hari') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jenis Permintaan tidak valid.')),
      );
      return;
    }
    final izinData = {
      'jenis_izin': selectedItems['Jenis Izin'],
      'lama_izin': selectedItems['Jenis Permintaan'],
      'tanggal_izin': "${selectedDate.toLocal()}".split(' ')[0],
      'deskripsi_izin': deskripsiController.text,
    };
    if (initialData != null) {
      izinData['id_izin'] = initialData!['id_izin'].toString();
    }
    if (initialData != null) {
      Navigator.pop(context, izinData);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      final userData = userDataString != null ? jsonDecode(userDataString) : {};
      final userId = userData['id_karyawan'];
      final apiUrl = dotenv.env['API_URL'] ?? '';
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiUrl/api-izin.php'),
      );
      request.fields['jenis_izin'] = selectedItems['Jenis Izin'] ?? '';
      request.fields['lama_izin'] = selectedItems['Jenis Permintaan'] ?? '';
      request.fields['tanggal_izin'] =
          "${selectedDate.toLocal()}".split(' ')[0];
      request.fields['deskripsi_izin'] = deskripsiController.text;
      request.fields['karyawan_id'] = userId.toString();
      if (uploadedFile != null) {
        final file = File(uploadedFile!);
        if (await file.exists()) {
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();
          final multipartFile = http.MultipartFile(
            'pelengkap_izin',
            stream,
            length,
            filename: file.path.split(Platform.pathSeparator).last,
          );
          request.files.add(multipartFile);
        }
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        try {
          final result = json.decode(response.body);
          if (result['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data berhasil disimpan.'),
                duration: Duration(seconds: 2),
              ),
            );
            await Future.delayed(const Duration(milliseconds: 1500));
            Navigator.pop(context, izinData);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal mengirim izin: ${result['message']}'),
              ),
            );
          }
        } catch (e) {
          print("Response Error: ${response.body}");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }
}
