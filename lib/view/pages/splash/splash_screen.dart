import 'package:flutter/material.dart';
import 'package:Clockin/view/pages/login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:Clockin/view/pages/dashboard/dashboard_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _transitionController;
  late Animation<Offset> _iconAnimation;
  late Animation<Offset> _backgroundAnimation;

  final List<bool> _visibleLetters = List.generate(
    7,
    (index) => false,
  ); // CLOCKIN = 7 huruf

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _iconAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _iconController, curve: Curves.ease));

    _backgroundAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1, 0),
    ).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.ease),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await _iconController.forward();
    await _revealLetters(); // animasi satu per satu
    await Future.delayed(const Duration(milliseconds: 400));
    await _transitionController.forward();
    // After splash, check if user_data exists. If yes, go to Dashboard.
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null && userDataString.isNotEmpty) {
        final userMap = jsonDecode(userDataString) as Map<String, dynamic>;
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => DashboardPage(userData: userMap)));
        return;
      }
    } catch (_) {
      // fallback to login
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  Future<void> _revealLetters() async {
    for (int i = 0; i < _visibleLetters.length; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      setState(() {
        _visibleLetters[i] = true;
      });
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = "CLOCKIN";
    return Scaffold(
      body: Stack(
        children: [
          SlideTransition(
            position: _backgroundAnimation,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/img/main-background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SlideTransition(
            position: _iconAnimation,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/img/logo-tanpa-tulisan.png',
                    width: 130,
                    height: 130,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(text.length, (index) {
                      return AnimatedOpacity(
                        opacity: _visibleLetters[index] ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          text[index],
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
