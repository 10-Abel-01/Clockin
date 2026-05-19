import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class KuotaCuti {
  final String jenisCuti;
  final int totalKuota;
  final int sisaKuota;

  KuotaCuti({
    required this.jenisCuti,
    required this.totalKuota,
    required this.sisaKuota,
  });

  factory KuotaCuti.fromJson(Map<String, dynamic> json) {
    return KuotaCuti(
      jenisCuti: json['jenis_cuti'],
      totalKuota: int.parse(json['total_kuota']),
      sisaKuota: int.parse(json['sisa_kuota']),
    );
  }

  static Future<List<KuotaCuti>> fetchKuotaCuti(String karyawanId) async {
    final baseUrl = dotenv.env['API_URL'] ?? '';
    final response = await http.get(
      Uri.parse('${baseUrl}api-kuota-cuti.php?karyawan_id=$karyawanId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => KuotaCuti.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil kuota cuti');
    }
  }
}