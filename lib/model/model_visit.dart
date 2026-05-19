import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VisitModel {
  final String tanggalVisit;
  final String jamVisit;
  final String koordinatVisit;
  final String fotoVisitPath;
  final String deskripsiVisit;
  final String karyawanId;
  final String shiftId;

  VisitModel({
    required this.tanggalVisit,
    required this.jamVisit,
    required this.koordinatVisit,
    required this.deskripsiVisit,
    required this.karyawanId,
    required this.shiftId,
    required this.fotoVisitPath,
  });

  Future<VisitResult> submitVisit(BuildContext context) async {
    try {
      final baseUrl = dotenv.env['API_URL'] ?? '';
      final uri = Uri.parse('${baseUrl}api-visit.php');
      final request = http.MultipartRequest('POST', uri);

      request.fields['tanggal_visit'] = tanggalVisit;
      request.fields['jam_visit'] = jamVisit;
      request.fields['koordinat_visit'] = koordinatVisit;
      request.fields['deskripsi_visit'] = deskripsiVisit;
      request.fields['karyawan_id'] = karyawanId;
      request.fields['shift_id'] = shiftId;
      request.files.add(
        await http.MultipartFile.fromPath('foto_visit', fotoVisitPath),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final result = json.decode(responseData);
        return VisitResult(
          success: result['success'],
          message: result['message'] ?? '',
        );
      } else {
        return VisitResult(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return VisitResult(success: false, message: 'Terjadi kesalahan: $e');
    }
  }
}

class VisitResult {
  final bool success;
  final String message;
  VisitResult({required this.success, required this.message});
}
