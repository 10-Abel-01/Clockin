import 'package:flutter/material.dart';
import 'controller_clockin.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import 'package:camera/camera.dart';

class ClockInPage extends StatefulWidget {
  const ClockInPage({super.key});

  @override
  State<ClockInPage> createState() => _ClockInPageState();
}

class _ClockInPageState extends State<ClockInPage> {
  late ClockInController controller;

  @override
  void initState() {
    super.initState();
    controller = ClockInController(context: context);
    controller.loadKaryawanId(setState);
  }

  void _showSelfieCaptureModal() {
    // Deprecated: camera now toggles directly from main page button
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0056B5),
      appBar: AppBar(
        backgroundColor: Color(0xFF0056B5),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Absensi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
            bottom: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Map container
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: FlutterMap(
                    key: ValueKey(controller.currentLocation),
                    options: MapOptions(
                      center:
                          controller.currentLocation ??
                          LatLng(-6.2, 106.816666),
                      zoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.zynovaworks.clockin',
                      ),
                      if (controller.currentLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: controller.currentLocation!,
                              width: 48,
                              height: 48,
                              builder:
                                  (ctx) => GestureDetector(
                                    onTap: () {
                                      final lat =
                                          controller.currentLocation!.latitude;
                                      final lon =
                                          controller.currentLocation!.longitude;
                                      controller.openMapsAt(lat, lon);
                                    },
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 36,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Tombol "Kunci Maps" (selalu tampil)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.lockLocation(setState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0056B5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Kunci Maps',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Live preview or captured selfie
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Builder(
                    builder: (context) {
                      // If there's a captured image, show it
                      if (controller.selfieImage != null) {
                        return Image.file(
                          File(controller.selfieImage!.path),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      }

                      // If camera controller active and initialized, show preview
                      if (controller.cameraController != null &&
                          controller.cameraController!.value.isInitialized) {
                        return CameraPreview(controller.cameraController!);
                      }

                      // default placeholder
                      return const Center(
                        child: Icon(
                          Icons.person,
                          size: 150,
                          color: Colors.black54,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: controller.selectedAbsensiType,
                items: const [
                  DropdownMenuItem(value: 'Office', child: Text('Office')),
                  DropdownMenuItem(value: 'Visit', child: Text('Visit')),
                ],
                onChanged: (value) {
                  setState(() {
                    controller.selectedAbsensiType = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Tipe Absensi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Description field
              TextFormField(
                enabled: controller.selectedAbsensiType == 'Visit',
                controller: controller.descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // tombol kamera & kirim
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await controller.toggleCamera(setState);
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0056B5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(18),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.submitAbsensi(setState),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0056B5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: const Text(
                        'Kirim',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
