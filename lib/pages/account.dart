import 'package:flutter/material.dart';
import 'package:hukum_apps/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPage createState() => _AccountPage();
}

class _AccountPage extends State<AccountPage> {
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken'); 
    print("Token dihapus, pengguna telah logout");
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200, // Lebar tombol
              height: 50,  // Tinggi tombol
              child: ElevatedButton(
                onPressed: () {
                  print("Navigasi ke halaman Setting");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Latar belakang putih
                  side: const BorderSide(
                    color: Colors.blue, // Border biru
                    width: 2, // Ketebalan border
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Sudut melengkung
                  ),
                ),
                child: const Text(
                  "Setting",
                  style: TextStyle(color: Colors.blue), // Teks berwarna biru
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200, // Lebar tombol
              height: 50,  // Tinggi tombol
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Latar belakang putih
                  side: const BorderSide(
                    color: Color.fromARGB(255, 241, 58, 58), 
                    width: 2, // Ketebalan border
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Sudut melengkung
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Color.fromARGB(255, 241, 58, 58)), // Teks berwarna biru
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
