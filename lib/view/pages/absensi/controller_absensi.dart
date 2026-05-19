import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:Clockin/model/model_clockout.dart';

class AbsensiController extends ChangeNotifier {
  String? jadwalBulan;
  String? jadwalShift;
  String? jamShift;
  bool isLoading = true;
  List<Map<String, dynamic>> history = [];
  int totalIzinCount = 0;
  int totalIzinHari = 0;
  Timer? _refreshTimer;

  Future<void> fetchJadwalAndShift() async {
    try {
      final jadwalBulanan = await fetchJadwalBulanan();
      final shiftData = await fetchShift(jadwalBulanan['jadwal_bulanan']);
      jadwalBulan = '${jadwalBulanan['bulan']} ${jadwalBulanan['tahun']}';
      jadwalShift = jadwalBulanan['jadwal_bulanan'];
      jamShift =
          '${_formatTime(shiftData['jam_masuk_shift'])} - ${_formatTime(shiftData['jam_pulang_shift'])} WIB';
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchHistory(int karyawanId) async {
    try {
      final fetchedHistory = await fetchHistoryApi(karyawanId);
      history = fetchedHistory;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Start periodic refresh to keep history and izin summary up-to-date.
  void startAutoRefresh(int karyawanId, {Duration interval = const Duration(seconds: 15)}) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(interval, (_) async {
      try {
        await fetchHistory(karyawanId);
        await fetchIzinSummary(karyawanId);
        await fetchJadwalAndShift();
      } catch (_) {
        // ignore errors on periodic refresh
      }
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  String _formatTime(String time) {
    final parsedTime = DateTime.parse('1970-01-01 $time');
    return DateFormat.Hm().format(parsedTime);
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

  Future<Map<String, dynamic>> fetchShift(String jadwalShift) async {
    final baseUrl = dotenv.env['API_URL'] ?? '';
    final response = await http.get(Uri.parse('${baseUrl}api-shift.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        final shift = data['data'].firstWhere(
          (shift) => shift['jadwal'] == jadwalShift,
          orElse: () => null,
        );
        if (shift != null) {
          return shift;
        } else {
          throw Exception('Shift tidak ditemukan untuk jadwal: $jadwalShift');
        }
      } else {
        throw Exception('Shift data tidak ditemukan');
      }
    } else {
      throw Exception('Failed to load shift data');
    }
  }

  Future<List<Map<String, dynamic>>> fetchHistoryApi(int karyawanId) async {
    final baseUrl = dotenv.env['API_URL'] ?? '';
    final response = await http.get(
      Uri.parse('${baseUrl}api-history-absen.php?karyawan_id=$karyawanId'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('History absensi tidak ditemukan');
      }
    } else {
      throw Exception('Failed to load history absensi');
    }
  }

  Future<void> fetchIzinSummary(int karyawanId) async {
    try {
      final baseUrl = dotenv.env['API_URL'] ?? '';
      final response = await http.get(
        Uri.parse('${baseUrl}api-izin.php?karyawan_id=$karyawanId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final list = List<Map<String, dynamic>>.from(data['data']);
          totalIzinCount = list.length;
          totalIzinHari = list.fold<int>(0, (sum, item) {
            final lama = int.tryParse(item['lama_izin']?.toString() ?? '0') ?? 0;
            return sum + lama;
          });
        } else {
          totalIzinCount = 0;
          totalIzinHari = 0;
        }
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  String calculateDuration(String clockIn, String clockOut) {
    DateTime? parseTimeFlexible(String input) {
      if (input == null) return null;
      // try HH:mm:ss
      try {
        return DateFormat.Hms().parse(input);
      } catch (_) {}
      // try HH:mm
      try {
        return DateFormat.Hm().parse(input);
      } catch (_) {}
      // try full DateTime parse
      try {
        return DateTime.parse(input);
      } catch (_) {}
      return null;
    }

    final clockInTime = parseTimeFlexible(clockIn);
    final clockOutTime = parseTimeFlexible(clockOut);
    if (clockInTime == null || clockOutTime == null) return '-';
    final duration = clockOutTime.difference(clockInTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return minutes > 30 ? '${hours + 1} JAM' : '$hours JAM';
  }

  Future<bool> handleClockOut(BuildContext context, int karyawanId) async {
    try {
      final response = await ModelClockOut.sendClockOut(karyawanId);
      if (response['success'] == true) {
        await fetchHistory(karyawanId);
        return true;
      } else {
        throw Exception(response['message'] ?? 'Clock Out gagal');
      }
    } catch (e) {
      rethrow;
    }
  }
}
