import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Clockin/view/pages/dashboard/dashboard_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:Clockin/model/model_login.dart';
import 'package:Clockin/utils/logger.dart';

class LoginController {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  final BuildContext context;

  LoginController({required this.context});

  Future<void> login(Function setState) async {
    final id = idController.text.trim();
    final kataSandi = passwordController.text.trim();

    if (id.isEmpty || kataSandi.isEmpty) {
      showMessage('ID dan Password tidak boleh kosong.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final baseUrl = dotenv.env['API_URL'] ?? '';
      final response = await http.post(
        Uri.parse('${baseUrl}api-login.php'),
        body: {'id_karyawan': id, 'kata_sandi': kataSandi},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final loginModel = LoginModel.fromJson(data['user']);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('karyawan_id', loginModel.idKaryawan);
          await prefs.setString('user_data', jsonEncode(loginModel.toJson()));

          await Future.delayed(const Duration(seconds: 2));

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (_, __, ___) => DashboardPage(userData: loginModel.toJson()),
              transitionsBuilder: (_, animation, __, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                final tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        } else {
          showMessage(data['message'] ?? 'Login gagal');
        }
      } else {
        showMessage('Gagal menghubungi server (${response.statusCode})');
      }
    } catch (e) {
      showMessage('Terjadi kesalahan: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
