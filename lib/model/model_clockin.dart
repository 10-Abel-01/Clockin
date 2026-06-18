// pake banyak import karna multipart/sekaligus access
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AbsensiModel {
  final String tanggalHadir;
  final String jamAbsenMasuk;
  final String koordinat;
  String tipeAbsensi;
  final String fotoAbsensiPath;
  final String shiftId;
  final String visitId;
  final String karyawanId;
  final String? deskripsi;

  // konstruktor untuk menerima semua data absensi
  AbsensiModel({
    required this.tanggalHadir,
    required this.jamAbsenMasuk,
    required this.koordinat,
    required this.tipeAbsensi,
    required this.fotoAbsensiPath,
    required this.shiftId,
    required this.visitId,
    required this.karyawanId,
    this.deskripsi,
  });
  
  // metode untuk mengirim data absensi ke server
  Future<AbsensiResult> submitAbsensi(BuildContext context) async {
    try {
      final baseUrl = dotenv.env['API_URL'] ?? '';
      final uri = Uri.parse('${baseUrl}api-absensi.php');
      final request = http.MultipartRequest('POST', uri);

      request.fields['tanggal_hadir'] = tanggalHadir;
      request.fields['jam_absen_masuk'] = jamAbsenMasuk;
      request.fields['koordinat'] = koordinat;
      request.fields['tipe_absensi'] = tipeAbsensi;
      request.fields['karyawan_id'] = karyawanId;
      request.fields['shift_id'] = shiftId;
      if (deskripsi != null) {
        request.fields['deskripsi'] = deskripsi!;
      }
      request.files.add(
        await http.MultipartFile.fromPath('foto_absensi', fotoAbsensiPath),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final result = json.decode(responseData);
        return AbsensiResult(
          success: result['success'],
          message: result['message'] ?? '',
        );
      } else {
        return AbsensiResult(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AbsensiResult(success: false, message: 'Terjadi kesalahan: $e');
    }
  }
}

class AbsensiResult {
  final bool success;
  final String message;
  AbsensiResult({required this.success, required this.message});
}
