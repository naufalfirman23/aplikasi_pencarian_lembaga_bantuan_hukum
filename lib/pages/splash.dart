import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../const/ccolor.dart';
import '../const/cfont.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _counter = 5; // Set waktu hitungan mundur

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    // Timer untuk hitungan mundur
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_counter == 1) {
        timer.cancel();
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
      } else {
        setState(() {
          _counter--;
        });
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: ColorPalete.utama,
    body: Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/img/logo-white.png',
                width: 300,
              ),
            ],
          ),
        ),

        Positioned(
          bottom: 20, 
          left: 50,
          right: 50,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.black.withOpacity(0.1), 
            ),
            child: const Text(
              "Hukum Mobile Apps",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FontType.interMedium,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

}
