import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hukum_apps/const/cTruncate.dart';
import 'package:hukum_apps/const/ccolor.dart';
import 'package:hukum_apps/const/cfont.dart';
import 'package:hukum_apps/pages/room_chat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../const/calert.dart';
import '../const/capi.dart';

class InstitutionDetailPage extends StatefulWidget {
  final int id_instansi;

  const InstitutionDetailPage({
    super.key,
    required this.id_instansi,
  });

  @override
  State<InstitutionDetailPage> createState() => _InstitutionDetailPageState();
}

class _InstitutionDetailPageState extends State<InstitutionDetailPage> {
  Map<String, dynamic>? institutionData;
  List<dynamic> lawyers = [];
  late int idUserAdmin;
  final AlertWidget alert = AlertWidget();

  @override
  void initState() {
    super.initState();
    fetchInstitutionDetails();
  }

  Future<void> fetchInstitutionDetails() async {
    const String apiUrl = ApiUri.baseUrl + ApiUri.detail_instansi;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      throw Exception("Token tidak ditemukan. Silakan login ulang.");
    }

    try {
      final response = await http.get(
        Uri.parse("$apiUrl?id=${widget.id_instansi}"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          institutionData = data;
          lawyers = data['pegawai_lembaga'] ?? [];
        });
        if (data['detail_admin'] != null && data['detail_admin'].isNotEmpty) {
          final idUser = data['detail_admin'][0]['id_user'];
          idUserAdmin = idUser ?? 0;
          print("ID User dari detail_admin: $idUser");
        } else {
          idUserAdmin = 0;
        }
      } else {
        throw Exception('Failed to load institution details');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  void _goToRoomChat() {
    if (idUserAdmin == null || idUserAdmin == 0) {
      alert.ErrorAlert(context, "Admin Belum terdaftar", "Error!");
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoomChat(
            idContacts: idUserAdmin,
            names: institutionData!['nama_instansi'],
          ),
        ),
      );
    }
  }

  void _openMap(double? latitude, double? longitude) async {
    if (latitude != 0 && longitude != 0) {
      final Uri url =
          Uri.parse("https://www.google.com/maps?q=$latitude,$longitude");
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw "Could not launch $url";
      }
    } else {
      alert.ErrorAlert(context, "Admin Belum Melengkapi data", "Error!");
    }
  }

  void _callPhone(String phoneNumber) async {
    final Uri phoneUrl = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    } else {
      throw "Could not call $phoneNumber";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (institutionData == null) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(35.0),
          child: AppBar(
            title: Text(
              "Detail Lembaga",
              style: TextStyle(
                  color: Colors.white, fontFamily: FontType.interBold),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: ColorPalete.utama,
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final institutionName =
        institutionData?['nama_instansi'] ?? "Tidak Tersedia";
    final address = institutionData?['alamat'] ?? "Tidak Tersedia";
    final logoImageUrl = institutionData?['logo'] != null
        ? "${ApiUri.bbaseUrl}/storage/${institutionData!['logo']}"
        : "Tidak Tersedia";
    final bannerImageUrl = institutionData?['foto_banner'] != null
        ? "${ApiUri.bbaseUrl}/storage/${institutionData!['foto_banner']}"
        : "https://via.placeholder.com/600x200";
    final latitude = double.tryParse(institutionData?['latitude'] ?? '') ?? 0.0;
    final longitude =
        double.tryParse(institutionData?['longitude'] ?? '') ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail Instansi",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ColorPalete.utama,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Gambar
            Image.network(
              bannerImageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            // Informasi Lembaga
            Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundImage: NetworkImage(logoImageUrl),
                    radius: 50,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          institutionName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          address,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Advokat/Lawyer Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Advokat/Lawyer",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 240,
                    child: lawyers.isEmpty
                        ? const Center(
                            child: Text("Lawyer Tidak Terdeteksi"),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: lawyers.length,
                            itemBuilder: (context, index) {
                              final lawyer = lawyers[index];
                              final lawyerName = lawyer['nama'];
                              final id_userLawyer = lawyer['id_user'];
                              final lawyerRating = lawyer['rating'];
                              final lawyerLocation = lawyer['kecamatan'] ?? "-";
                              final lawyerImageUrl =
                                  "${ApiUri.bbaseUrl}/storage/${lawyer['profile_pict']}";
                              return LawyerCard(
                                id_user: id_userLawyer,
                                name: lawyerName,
                                rating: lawyerRating.toString(),
                                location: lawyerLocation,
                                imageUrl: lawyerImageUrl,
                              ).buildCard(context);
                            },
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _goToRoomChat(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              icon: const Icon(Icons.message, color: Colors.white),
              label: const Text(
                "Hubungi",
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _openMap(latitude, longitude),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              icon: const Icon(Icons.map, color: Colors.white),
              label: const Text(
                "Lokasi",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LawyerCard {
  final String name;
  final String rating;
  final String location;
  final String imageUrl;
  final int id_user;

  LawyerCard({
    required this.name,
    required this.rating,
    required this.location,
    required this.imageUrl,
    required this.id_user,
  });

  Widget buildCard(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(8),
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: ColorPalete.utama, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),

              // Nama
              Text(
                truncateTextByChars(name, 12),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.start,
              ),

              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "${formatRating(rating)} / 5.0",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Lokasi
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Icons.location_pin, color: Colors.red, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Tombol Message
              SizedBox(
                width: 120,
                height: 36,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RoomChat(
                                idContacts: id_user,
                                names: name,
                              )),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF56C7F3), // Warna biru tombol
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Message",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: "InterLight", // Sesuaikan nama font jika ada
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ));
  }
}

class Review {
  final String reviewer;
  final String comment;

  Review({
    required this.reviewer,
    required this.comment,
  });

  Widget buildReview() {
    return Padding(
        padding: const EdgeInsets.all(6.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: const BoxDecoration(
            color: Color.fromARGB(118, 197, 202, 233),
            borderRadius: BorderRadius.all(
              Radius.circular(12.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reviewer,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              Text(comment),
            ],
          ),
        ));
  }
}
