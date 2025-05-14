import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hukum_apps/const/cTruncate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../const/calert.dart';
import '../const/capi.dart';
import '../const/ccolor.dart';
import 'detail-lawyer.dart';
import 'detail-lbh.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  Map<String, dynamic>? userData;
  final AlertWidget alert = AlertWidget();

  String currentLocation = "Memuat lokasi...";
  String currentAddress = "Memuat lokasi...";
  late Position userPosition;

  Future<void> fetchUserProfile() async {
    setState(() {
      isLoading = true;
    });

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
        setState(() {
          userData = data;
        });
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? "Gagal mengambil data user.");
      }
    } catch (e) {
      alert.ErrorAlert(context, "Gagal Memuat Konten", "Error!");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchLocation() async {
    try {
      // Periksa izin lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            currentLocation = "Izin lokasi ditolak.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          currentLocation = "Izin lokasi ditolak secara permanen.";
        });
        return;
      }

      // Ambil lokasi saat ini
      userPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = "${userPosition.latitude}, ${userPosition.longitude}";
      });

      // Konversi lokasi menjadi alamat
      List<Placemark> placemarks = await placemarkFromCoordinates(
        userPosition.latitude,
        userPosition.longitude,
      );
      Placemark place = placemarks[0];

      setState(() {
        currentAddress = "${place.locality}";
      });
    } catch (e) {
      setState(() {
        currentLocation = "Error mengambil lokasi: $e";
        currentAddress = "Error mengambil alamat.";
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchLawyers() async {
    const String apiUrl = ApiUri.baseUrl + ApiUri.lawyers;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      throw Exception("Token tidak ditemukan. Silakan login ulang.");
    }
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((item) {
          return {
            "id": item["id"] ?? 0,
            "id_user": item["id_user"] ?? 0,
            "name": item["nama"] ?? "Nama tidak tersedia",
            "tentang": item["tentang"] ?? "Tentang tidak Tersedia",
            "address": item["alamat"] ?? "Alamat tidak tersedia",
            "province": item["provinsi"] ?? "Provinsi tidak tersedia",
            "image": item["profile_pict"] != null
                ? "${ApiUri.bbaseUrl}/storage/${item["profile_pict"]}"
                : "${ApiUri.bbaseUrl}/storage/logos/xCdXdDcGKkqIaMOru3tgAAfls1mkOc2pW2LFs0Pa.jpg",
            "district": item["kecamatan"] ?? "Kecamatan tidak tersedia",
            "city": item["kabupaten"] ?? "Kabupaten tidak tersedia",
            "village":
                item["desa_kelurahan"] ?? "Desa/Kelurahan tidak tersedia",
            "rt": item["rt"] ?? "RT tidak tersedia",
            "rw": item["rw"] ?? "RW tidak tersedia",
            "nama_instansi":
                item["nama_instansi"] ?? "Nama Instansi tidak tersedia",
            "rating": item["rating"] ?? 0,
            "contact": item["telp"] ?? "Nomor telepon tidak tersedia",
          };
        }).toList();
      } else {
        throw Exception(
            'Gagal Mengambil data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal Mengambil data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchInstitutions() async {
    const String apiUrl = ApiUri.baseUrl + ApiUri.instansi;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      throw Exception("Token tidak ditemukan. Silakan login ulang.");
    }

    try {
      final response = await http.get(
        Uri.parse(
            "$apiUrl?long=${userPosition.longitude}&lat=${userPosition.latitude}"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((item) {
          return {
            "id": item["id"] ?? 0,
            "name": item["nama_instansi"] ?? "Nama tidak tersedia",
            "address": item["alamat"] ?? "Alamat tidak tersedia",
            "province": item["provinsi"] ?? "Provinsi tidak tersedia",
            "image": item["logo"] != null
                ? "${ApiUri.bbaseUrl}/storage/${item["logo"]}"
                : "${ApiUri.bbaseUrl}/storage/logos/xCdXdDcGKkqIaMOru3tgAAfls1mkOc2pW2LFs0Pa.jpg",
            "district": item["kecamatan"] ?? "Kecamatan tidak tersedia",
            "city": item["kabupaten"] ?? "Kabupaten tidak tersedia",
            "distance": item["distance"] ?? 0.0,
            "gallery": [],
            "location": LatLng(
              double.tryParse(item["latitude"] ?? "0.0") ?? 0.0,
              double.tryParse(item["longitude"] ?? "0.0") ?? 0.0,
            ),
          };
        }).toList();
      } else {
        throw Exception('Failed to load institutions');
      }
    } catch (e) {
      throw Exception('Mengambil Lokasi Anda...');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildHeader(context),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                children: [
                  buildInstitutionsList(context),
                  const SizedBox(height: 20.0),
                  buildTopLawyerList(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header Widget (Tambah Lokasi Saat Ini)
  Widget buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      color: ColorPalete.utama,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30.0,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40.0, color: ColorPalete.utama),
              ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selamat Datang,",
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                  Text(
                    '${userData?['username'] ?? '...'}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Lokasi: $currentAddress",
                    style: const TextStyle(color: Colors.white, fontSize: 12.0),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          // Kolom pencarian
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Cari Kategori",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInstitutionsList(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchInstitutions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No data available"));
        }

        final institutions = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Lembaga Bantuan Hukum",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            SizedBox(
              height: 160.0,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: institutions.map((institution) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InstitutionDetailPage(
                              id_instansi: institution["id"],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border:
                              Border.all(color: ColorPalete.utama, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        width: 250.0,
                        margin: const EdgeInsets.only(right: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10.0),
                              ),
                              child: Image.network(
                                institution["image"],
                                height: 90.0,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    truncateText(institution["name"], 3),
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    "${institution["province"]}",
                                    style: const TextStyle(fontSize: 12.0),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    "Jarak: ${formatDistance(institution["distance"])}",
                                    style: const TextStyle(fontSize: 8.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildTopLawyerList(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchLawyers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data available"));
          }

          final lawyers = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Top 5 Lawyer",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              ...lawyers.map((lawyer) {
                final ratingLawyer = lawyer['rating'].toDouble();
                return GestureDetector(
                  onTap: () {
                    // Navigasi ke halaman detail lawyer sambil membawa data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LawyerDetailPage(
                          id_user: lawyer["id_user"],
                          name: lawyer["name"],
                          imageUrl: lawyer["image"],
                          organization: lawyer["nama_instansi"],
                          rating: ratingLawyer,
                          description: lawyer["tentang"],
                          location: lawyer["address"],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: ColorPalete.utama,
                          width: 1.5), // Warna Stroke Biru
                      borderRadius:
                          BorderRadius.circular(12), // Sudut melengkung
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Container(
                        width: 60.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue, // Warna border
                            width: 2.0, // Ketebalan border
                          ),
                          borderRadius: BorderRadius.circular(
                              30.0), // Sudut border melingkar
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30.0),
                          child: Image.network(
                            lawyer["image"]!,
                            width: 60.0,
                            height: 60.0,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      title: Text(lawyer["name"]!,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.orange, size: 16.0),
                          const SizedBox(width: 5),
                          Text("${formatRating(lawyer["rating"])} / 5.0"),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                );
              }),
            ],
          );
        });
  }
}
