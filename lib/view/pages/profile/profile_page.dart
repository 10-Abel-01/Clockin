import 'package:flutter/material.dart';
import 'package:Clockin/model/model_profile.dart';
import 'package:Clockin/view/components/custom_bottom_nav.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'controller_profile.dart';
import 'package:Clockin/utils/logger.dart';

class ProfilePage extends StatefulWidget {
  final ProfileModel userData;
  const ProfilePage({super.key, required this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ProfileController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    controller = ProfileController(userData: widget.userData, context: context);

    _initData();
  }

  Future<void> _initData() async {
    await controller.loadUserData();
    await controller.fetchProfileData();

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userData = controller.userData;
    final imageBaseUrl = dotenv.env['IMAGE_URL'] ?? '';

    String profileImage = '';
    if (userData.fotoProfil.isNotEmpty) {
      final fp = userData.fotoProfil.trim();
      if (fp.toLowerCase().startsWith('http')) {
        profileImage = fp;
      } else {
        if (imageBaseUrl.isEmpty) {
          profileImage = fp;
        } else if (imageBaseUrl.endsWith('/') && fp.startsWith('/')) {
          profileImage = imageBaseUrl + fp.substring(1);
        } else if (!imageBaseUrl.endsWith('/') && !fp.startsWith('/')) {
          profileImage = '$imageBaseUrl/$fp';
        } else {
          profileImage = imageBaseUrl + fp;
        }
      }
    }

    final ImageProvider avatarProvider =
        profileImage.isNotEmpty
            ? NetworkImage(profileImage)
            : const AssetImage('assets/img/placeholder.png');

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/img/background-profile.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 10, top: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0056B5).withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'PT DELTASINDO GLOBAL SCIENTIFIC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CircleAvatar(
                  backgroundImage: avatarProvider,
                  radius: 70,
                  onBackgroundImageError: (_, __) {
                    Log.e('Error loading profile image: $profileImage');
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  userData.namaKaryawan,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildProfileItem(
                        Icons.badge,
                        'ID Karyawan',
                        userData.idKaryawan.toString(),
                      ),
                      const SizedBox(height: 6),
                      _buildProfileItem(
                        Icons.work,
                        'Jabatan',
                        userData.jabatan?.namaJabatan ?? '-',
                      ),
                      const SizedBox(height: 6),
                      _buildProfileItem(Icons.phone, 'No Tlp', userData.noTelp),
                      const SizedBox(height: 6),
                      _buildProfileItem(Icons.email, 'Email', userData.email),
                      const SizedBox(height: 6),
                      _buildProfileItem(
                        Icons.account_balance,
                        'Rekening',
                        '${userData.bank ?? ''} - ${userData.rekening ?? ''}',
                      ),
                      const Divider(height: 24),
                      // ListTile(
                      //   contentPadding: const EdgeInsets.symmetric(
                      //     horizontal: 0,
                      //   ),
                      //   dense: true,
                      //   leading: const Icon(Icons.lock),
                      //   title: const Text('Ubah Password'),
                      //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      //   onTap: () {},
                      // ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                        ),
                        dense: true,
                        leading: const Icon(Icons.logout),
                        title: const Text('Logout'),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: const Text('Konfirmasi'),
                                  content: const Text('Yakin ingin logout?'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Batal'),
                                      onPressed: () => Navigator.of(ctx).pop(),
                                    ),
                                    TextButton(
                                      child: const Text('Logout'),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        controller.logout();
                                      },
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
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

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.black, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
