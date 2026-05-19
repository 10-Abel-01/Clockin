import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

String _formatTanggal(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '';
  try {
    final date = DateTime.parse(dateStr);
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
  } catch (e) {
    return dateStr;
  }
}

Future<Map<String, dynamic>> fetchJadwalBulanan() async {
  final baseUrl = dotenv.env['API_URL'] ?? '';
  final response = await http.get(
    Uri.parse('${baseUrl}api-jadwal-bulanan.php'),
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['success'] == true &&
        data['data'] != null &&
        data['data'].isNotEmpty) {
      return data['data'][0];
    } else {
      throw Exception('Jadwal bulanan tidak ditemukan');
    }
  } else {
    throw Exception('Failed to load jadwal bulanan');
  }
}
