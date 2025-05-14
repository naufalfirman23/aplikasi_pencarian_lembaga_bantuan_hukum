import 'package:hukum_apps/const/cfont.dart';
import 'package:hukum_apps/pages/account.dart';
import 'package:hukum_apps/pages/chat.dart';
import 'package:hukum_apps/pages/home.dart';
import 'package:hukum_apps/pages/organization.dart'; // Import halaman baru
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../const/capi.dart';
import '../const/ccolor.dart';

class MainMenu extends StatefulWidget {
  final int selectedIndex;
  const MainMenu({super.key, this.selectedIndex = 1});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  Future<void> fetchUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null) {
        throw Exception("Token tidak ditemukan. Silakan login ulang.");
      }

      final url = Uri.parse(ApiUri.baseUrl + ApiUri.user);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final userId =
            data['id']; // Sesuaikan dengan struktur JSON respons dari server
        print("User ID: $userId");
      } else {
        final errorData = jsonDecode(response.body);
        print("Error response: ${errorData['message']}");
        throw Exception(errorData['message'] ?? "Gagal mengambil data user.");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error: $e");
    }
  }

  // Menyimpan nilai index untuk bottom navigation
  int myIndex = 1;

  // List widget untuk halaman yang dapat dipilih
  List<Widget> widgetList = [
    ChatScreen(),
    HomePage(),
    OrganizationPage(),
    AccountPage()
  ];
  List<String> title = ["Chat", "Home", "Lembaga", "Account"];

  @override
  void initState() {
    super.initState();
    myIndex = widget.selectedIndex;
    fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(35.0),
        child: AppBar(
          title: Text(
            title[myIndex],
            style:
                TextStyle(color: Colors.white, fontFamily: FontType.interBold),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: ColorPalete.utama,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Menampilkan semua label
        backgroundColor: Colors.white,
        items: List.generate(
          widgetList.length,
          (index) => BottomNavigationBarItem(
            icon: Icon(
              index == 0
                  ? Icons.message_rounded
                  : index == 1
                      ? Icons.home
                      : index == 2
                          ? Icons.apartment
                          : Icons.account_box,
            ),
            label: title[index],
          ),
        ),
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        currentIndex: myIndex,
        selectedItemColor: ColorPalete.utama,
        unselectedItemColor: Colors.black,
      ),
      body: widgetList[myIndex],
    );
  }
}
