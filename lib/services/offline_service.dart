import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineService {
  Future<bool> hasInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false; 
    }
    return true;
  }

  Future<void> simpanAbsenOffline(Map<String, dynamic> dataAbsen) async {
    final prefs = await SharedPreferences.getInstance();

    String dataString = jsonEncode(dataAbsen);

    await prefs.setString('absen_pending', dataString);

    print("Data berhasil disimpan di HP karena sinyal jelek!");
  }

  Future<Map<String, dynamic>?> getAbsenPending() async {
    final prefs = await SharedPreferences.getInstance();
    String? dataString = prefs.getString('absen_pending');

    if (dataString != null) {
      return jsonDecode(dataString);
    }
    return null;
  }

  Future<void> hapusDataOffline() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('absen_pending');
  }
}
