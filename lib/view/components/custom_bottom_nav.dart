import 'package:flutter/material.dart';
import 'package:Clockin/view/pages/dashboard/dashboard_page.dart';
import 'package:Clockin/view/pages/absensi/absensi_page.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final Map<String, dynamic>? userData;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.userData,
  });

  void _handleTap(BuildContext context, int index) {
    if (index == 0 && userData != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(userData: userData!),
        ),
      );
    } else if (index == 1 && userData != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AbsensiPage(userData: userData!),
        ),
      );
    } else if (onTap != null) {
      onTap!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _handleTap(context, index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white.withOpacity(0),
      elevation: 0,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      selectedItemColor: const Color(0xFF0056B5),
      unselectedItemColor: const Color(0xFF0056B5),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      items: [
        BottomNavigationBarItem(
          icon: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: const Offset(0, 4),
                child: Image.asset(
                  'assets/img/Beranda.png',
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(height: 5), // kasih jarak antara icon dan label
            ],
          ),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: const Offset(0, -6),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0056B5),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/img/Sidik-Jari-Biru.png',
                    width: 50,
                    height: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          label: 'Absensi',
        ),
        BottomNavigationBarItem(
          icon: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: const Offset(0, 0),
                child: Image.asset(
                  'assets/img/Data-Absensi.png',
                  width: 24,
                  height: 24,
                ),
              ),
              // const SizedBox(height: 1), // sama
            ],
          ),
          label: 'Data Absensi',
        ),
      ],
    );
  }
}
