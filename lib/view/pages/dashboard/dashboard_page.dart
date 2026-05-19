import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Clockin/view/components/custom_bottom_nav.dart';
import 'package:Clockin/view/pages/profile/profile_page.dart';
import 'package:Clockin/view/pages/absensi/absensi_page.dart';
import 'package:Clockin/view/pages/shift/shift_page.dart';
import 'package:Clockin/model/model_dashboard.dart' as dashboardModel;
import 'package:Clockin/model/model_profile.dart';
import 'package:Clockin/view/pages/dashboard/menu_item_page/izin_page.dart';
import 'package:Clockin/view/pages/dashboard/controller_dashboard.dart';

class DashboardPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const DashboardPage({super.key, required this.userData});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = DashboardController(
      context: context,
      initialUserData: widget.userData,
    );
    controller.loadUserData(setState).then((_) {
      controller.fetchJadwalAndAbsensi(setState);
      controller.fetchSisaCuti(setState);
      controller.fetchIzinCount(setState);
      controller.startAutoRefresh(setState);
    });
  }

  @override
  void dispose() {
    controller.stopAutoRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiUrl = dotenv.env['API_URL'] ?? '';
    final imageUrl = dotenv.env['IMAGE_URL'] ?? '';
    final user = controller.userData;

    String photoUrl = '';
    if (user['foto_profil'] != null && user['foto_profil'].toString().isNotEmpty) {
      final fp = user['foto_profil'].toString().trim();
      if (fp.toLowerCase().startsWith('http')) {
        photoUrl = Uri.encodeFull(fp);
      } else {
        if (imageUrl.isEmpty) {
          photoUrl = Uri.encodeFull(fp);
        } else if (imageUrl.endsWith('/') && fp.startsWith('/')) {
          photoUrl = Uri.encodeFull(imageUrl + fp.substring(1));
        } else if (!imageUrl.endsWith('/') && !fp.startsWith('/')) {
          photoUrl = Uri.encodeFull('$imageUrl/$fp');
        } else {
          photoUrl = Uri.encodeFull(imageUrl + fp);
        }
      }
    }

    final ImageProvider avatarProvider =
        photoUrl.isNotEmpty ? NetworkImage(photoUrl) : const AssetImage('assets/img/placeholder.png');

    final now = DateTime.now();
    final hari = DateFormat('EEEE', 'id_ID').format(now);
    final tanggal = DateFormat('dd MMMM yyyy', 'id_ID').format(now);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/img/background-dashboard.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                // profil
                                MaterialPageRoute(
                                  builder:
                                      (_) => ProfilePage(
                                        userData: ProfileModel.fromJson(user),
                                      ),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              backgroundImage: avatarProvider,
                              radius: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user['nama_karyawan'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user['email'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/img/Logo-Samping.png',
                          height: 60,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // shift sama rekap absensi
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Image.asset(
                                    'assets/img/Jam.png',
                                    width: 35,
                                    height: 35,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.jadwalShift ?? 'Shift',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      Text(
                                        controller.jamShift ??
                                            '08:00 - 17:00 WIB',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            'Masuk | ',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF0056B5),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            controller.clockIn ?? '-',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF0056B5),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      hari,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    Text(
                                      tanggal,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'Pulang | ',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF0056B5),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          controller.clockOut ?? '-',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF0056B5),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Divider(color: Colors.black, thickness: 1),
                            const SizedBox(height: 6),
                            Column(
                              children: [
                                const Text(
                                  'Rekap Absensi Bulan Ini',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildAbsensiColumnWithLine(
                                      'Hadir',
                                      '${controller.totalHadir} Hari',
                                      Color(0xFF002B54),
                                      Color(0xFF002B54),
                                    ),
                                    _buildAbsensiDivider(),
                                    _buildAbsensiColumnWithLine(
                                      'Izin',
                                      '${controller.totalIzin} Hari',
                                      Color(0xFF0056B5),
                                      Color(0xFF0056B5),
                                    ),
                                    _buildAbsensiDivider(),
                                    _buildAbsensiColumnWithLine(
                                      'Sisa Cuti',
                                      controller.sisaCuti != null
                                          ? '${controller.sisaCuti} Hari'
                                          : '-',
                                      Color(0xFFFFBB00),
                                      Color(0xFFFFBB00),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Menu Grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0,
                          childAspectRatio: 1,
                          children: [
                            _buildMenuItem(
                              'Izin',
                              'assets/img/Izin.png',
                              () => Navigator.pushNamed(context, '/izin'),
                            ),
                            _buildMenuItem(
                              'Lembur',
                              'assets/img/Lembur.png',
                              () => Navigator.pushNamed(context, '/lembur'),
                            ),
                            // _buildMenuItem(
                            //   'Visit',
                            //   'assets/img/Shift.png',
                            //   () => Navigator.pushNamed(context, '/visit'),
                            // ),
                            // _buildMenuItem(
                            //   'Reimburse',
                            //   'assets/img/Reimburse.png',
                            //   () => Navigator.pushNamed(context, '/reimburse'),
                            // ),
                            // _buildMenuItem(
                            //   'Aktivitas',
                            //   'assets/img/Aktivitas.png',
                            //   () => Navigator.pushNamed(context, '/aktivitas'),
                            // ),
                            // _buildMenuItem(
                            //   'Berita',
                            //   'assets/img/Berita.png',
                            //   () => Navigator.pushNamed(context, '/Berita'),
                            // ),
                            // _buildMenuItem(
                            //   'Slip Gaji',
                            //   'assets/img/Slip-Gaji.png',
                            //   () => Navigator.pushNamed(context, '/slip-gaji'),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: controller.selectedIndex,
        onTap: controller.onNavTap,
      ),
    );
  }

  Widget _buildAbsensiColumnWithLine(
    String title,
    String value,
    Color color,
    Color lineColor,
  ) {
    return SizedBox(
      height: 65,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.left,
          ),
          Container(height: 4, width: 80, color: lineColor),
        ],
      ),
    );
  }

  Widget _buildAbsensiDivider() {
    return Container(
      height: 65,
      width: 1,
      color: Colors.black,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildMenuItem(String label, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFF666666).withOpacity(0.1),
              ), // Added border color
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12), // biar ikon nggak mentok
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0056B5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
