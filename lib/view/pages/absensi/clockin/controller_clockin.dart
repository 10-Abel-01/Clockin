import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'package:Clockin/model/model_clockin.dart';
import 'package:Clockin/model/model_visit.dart';
import 'package:Clockin/view/pages/absensi/absensi_page.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:Clockin/utils/logger.dart';
import 'package:Clockin/services/offline_service.dart';

class ClockInController {
  final BuildContext context;

  ClockInController({required this.context});

  // data absensi
  String? idKaryawan;
  LatLng? currentLocation;
  String? selectedAddress;
  XFile? selfieImage;
  String? selectedAbsensiType = 'Office';
  final TextEditingController descriptionController = TextEditingController();

  void updateAbsensiType(String? value, Function setState) {
    setState(() {
      selectedAbsensiType = value;
      if (value == 'Office') {
        descriptionController.clear();
      }
    });
  }

  // util
  final ImagePicker _picker = ImagePicker();
  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;

  Future<void> loadKaryawanId(Function setState) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idKaryawan = prefs.getString('karyawan_id');
    });
  }

  // lokasi
  Future<void> lockLocation(Function setState) async {
    const int maxRetry = 3;
    const double allowedRadiusMeter = 100;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Layanan lokasi tidak aktif')),
      );
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin lokasi ditolak permanen')),
      );
      return;
    }

    Position? position;

    for (int attempt = 1; attempt <= maxRetry; attempt++) {
      try {
        Log.d('Mencoba mendapatkan lokasi (percobaan $attempt)...');
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        break;
      } catch (_) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    // posisi akurasi sedeng
    if (position == null) {
      try {
        Log.d('Mencoba mendapatkan lokasi dengan akurasi sedang...');
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (_) {}
    }

    position ??= await Geolocator.getLastKnownPosition();

    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS belum mendapatkan sinyal. Coba di area terbuka.'),
        ),
      );
      return;
    }

    final newLocation = LatLng(position.latitude, position.longitude);

    setState(() {
      currentLocation = newLocation;
    });

    if (selectedAbsensiType == 'Visit') {
      try {
        final addr = await _reverseGeocode(
          newLocation.latitude,
          newLocation.longitude,
        );
        if (addr != null && addr.isNotEmpty) {
          setState(() {
            selectedAddress = addr;
          });
        } else {
          setState(() {
            selectedAddress =
                '${newLocation.latitude.toStringAsFixed(6)}, ${newLocation.longitude.toStringAsFixed(6)}';
          });
        }
      } catch (e) {
        Log.d('Error reverse geocode: $e');
        setState(() {
          selectedAddress =
              '${newLocation.latitude.toStringAsFixed(6)}, ${newLocation.longitude.toStringAsFixed(6)}';
        });
      }
    }
    Log.d(
      'Lokasi terkunci: Lat ${newLocation.latitude}, Lon ${newLocation.longitude}',
    );
  }

  Future<String?> _reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon',
      );
      final resp = await http.get(
        uri,
        headers: {'User-Agent': 'ClockinApp/1.0'},
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data != null) {
          // Prefer display_name or name
          return data['display_name'] ?? data['name'] ?? null;
        }
      }
    } catch (e) {
      Log.d('Error reverse geocode: $e');
    }
    return null;
  }

  Future<void> openMapsAt(double lat, double lon) async {
    final googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    try {
      final launched = await launchUrlString(
        googleUrl,
        mode: LaunchMode.externalApplication,
      );
      if (launched == false) {
        // fallback to platform default (browser)
        await launchUrlString(googleUrl, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      try {
        await launchUrlString(googleUrl, mode: LaunchMode.platformDefault);
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
        );
      }
    }
  }


  Widget _addressTile(String text, String value, Function setState) {
    return Column(
      children: [
        ListTile(
          title: Text(text),
          onTap: () {
            setState(() => selectedAddress = value);
            Navigator.pop(context);
          },
        ),
        const Divider(),
      ],
    );
  }

  Future<void> initializeFrontCamera() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      return;
    }

    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
  }

  Future<void> captureSelfie() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      final image = await _cameraController!.takePicture();
      selfieImage = image;

      await _cameraController!.dispose();
      _cameraController = null;
    }
  }

  /// Toggle camera: start camera preview on first press, capture on second.
  Future<void> toggleCamera(Function setState) async {
    try {
      if (kIsWeb) {
        // On web just pick from gallery
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) setState(() => selfieImage = image);
        return;
      }

      // If camera not active, initialize and show preview
      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        await initializeFrontCamera();
        setState(() {});
        return;
      }

      // If camera is active, capture and display
      final XFile image = await _cameraController!.takePicture();
      setState(() => selfieImage = image);
      await _cameraController!.dispose();
      _cameraController = null;
    } catch (e) {
      Log.d('Error toggling camera: $e');
      try {
        await _cameraController?.dispose();
      } catch (_) {}
      _cameraController = null;
    }
  }

  Future<void> captureSelfieWithCountdown(Function setState) async {
    try {
      if (kIsWeb) {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) {
          setState(() => selfieImage = image);
        }
      } else {
        if (_cameraController == null ||
            !_cameraController!.value.isInitialized) {
          await initializeFrontCamera();
        }
        for (int i = 3; i > 0; i--) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mengambil gambar dalam $i detik...'),
              duration: Duration(seconds: 1),
            ),
          );
          await Future.delayed(Duration(seconds: 1));
        }

        final XFile image = await _cameraController!.takePicture();
        setState(() => selfieImage = image);

        disposeCamera();
      }
    } catch (e) {
      Log.d('Error capturing selfie: $e');
    }
  }

  void disposeCamera() {
    _cameraController?.dispose();
    _cameraController = null;
  }

  Future<void> submitAbsensi(Function setState) async {
    if (idKaryawan == null || currentLocation == null || selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data terlebih dahulu')),
      );
      return;
    }

    Map<String, dynamic> dataSiapKirim = {
      'tipe': selectedAbsensiType, // office atau visit
      'karyawan_id': idKaryawan,
      'tanggal': DateTime.now().toIso8601String(),
      'jam': TimeOfDay.now().format(context),
      'koordinat': '${currentLocation!.latitude},${currentLocation!.longitude}',
      'foto_path': selfieImage!.path,
      'deskripsi': descriptionController.text,
      'shift_id': '1', // Default shift
    };

    final offlineService = OfflineService();
    bool adaInternet = await offlineService.hasInternet();

    if (adaInternet) {
      try {
        bool sukses = false;
        String pesan = '';

        if (selectedAbsensiType == 'Visit') {
          final visit = VisitModel(
            tanggalVisit: dataSiapKirim['tanggal'],
            jamVisit: dataSiapKirim['jam'],
            koordinatVisit: dataSiapKirim['koordinat'],
            deskripsiVisit: dataSiapKirim['deskripsi'],
            karyawanId: dataSiapKirim['karyawan_id'],
            shiftId: dataSiapKirim['shift_id'],
            fotoVisitPath: dataSiapKirim['foto_path'],
          );
          final result = await visit.submitVisit(context);
          sukses = result.success;
          pesan = result.message;
        } else {
          final absensi = AbsensiModel(
            tanggalHadir: dataSiapKirim['tanggal'],
            jamAbsenMasuk: dataSiapKirim['jam'],
            koordinat: dataSiapKirim['koordinat'],
            tipeAbsensi: dataSiapKirim['tipe'],
            karyawanId: dataSiapKirim['karyawan_id'],
            shiftId: dataSiapKirim['shift_id'],
            fotoAbsensiPath: dataSiapKirim['foto_path'],
            deskripsi:
                dataSiapKirim['deskripsi'].isNotEmpty
                    ? dataSiapKirim['deskripsi']
                    : null,
            visitId: '',
          );
          final result = await absensi.submitAbsensi(context);
          sukses = result.success;
          pesan = result.message;
        }

        if (sukses) {
          _handleSuccess("Absensi Berhasil Terkirim!");
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(pesan)));
        }
      } catch (e) {
        Log.d('Error submit online: $e. Menyimpan offline...');
        await _simpanKeOffline(offlineService, dataSiapKirim);
      }
    } else {
      await _simpanKeOffline(offlineService, dataSiapKirim);
    }
  }

  Future<void> _simpanKeOffline(
    OfflineService service,
    Map<String, dynamic> data,
  ) async {
    await service.simpanAbsenOffline(data);

    // tampilin pesan simpan offline
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text("Sinyal Lemah 📡"),
            content: const Text(
              "Jangan khawatir! Absen kamu sudah disimpan di HP. Data akan dikirim otomatis saat sinyal bagus.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); 
                  _handleSuccess("Tersimpan Offline"); 
                },
                child: const Text("OK, Mengerti"),
              ),
            ],
          ),
    );
  }

  // Helper untuk pindah halaman kalo sukses
  void _handleSuccess(String pesanSnackBar) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = jsonDecode(prefs.getString('user_data') ?? '{}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesanSnackBar), backgroundColor: Colors.green),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AbsensiPage(userData: userData)),
      );
    });
  }

  @override
  void dispose() {
    descriptionController.dispose();
    _cameraController?.dispose();
  }
}
