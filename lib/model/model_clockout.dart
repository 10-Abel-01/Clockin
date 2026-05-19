import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ModelClockOut {
  static Future<Map<String, dynamic>> sendClockOut(int karyawanId) async {
    final baseUrl = dotenv.env['API_URL'] ?? '';
    final response = await http.post(
      Uri.parse('${baseUrl}api-absensi-keluar.php'),
      body: {'karyawan_id': karyawanId.toString()},
    );
   if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to send Clock Out');
    }
  }
}
