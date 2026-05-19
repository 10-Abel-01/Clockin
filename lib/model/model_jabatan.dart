import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class JabatanModel {
  final String idJabatan;
  final String namaJabatan;

  JabatanModel({required this.idJabatan, required this.namaJabatan});

  factory JabatanModel.fromJson(Map<String, dynamic> json) {
    return JabatanModel(
      idJabatan: json['id_jabatan']?.toString() ?? '',
      namaJabatan: json['nama_jabatan']?.toString() ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {'id_jabatan': idJabatan, 'nama_jabatan': namaJabatan};
  }
}
