import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;

import '../const/capi.dart';
import '../const/ccolor.dart';
import 'detail-lbh.dart';

class OrganizationPage extends StatefulWidget {
  const OrganizationPage({Key? key}) : super(key: key);

  @override
  _OrganizationPageState createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
  List<dynamic> organizations = [];
  List<dynamic> filteredOrganizations = [];
  final TextEditingController _searchController = TextEditingController();

  Future<void> fetchOrganizations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    const String apiUrl = ApiUri.baseUrl + ApiUri.allinstansi;

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30)); // Timeout selama 30 detik

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          setState(() {
            organizations = data;
            filteredOrganizations = organizations;
          });
        } else if (data['data'] is List) {
          setState(() {
            organizations = data['data'];
            filteredOrganizations = organizations;
          });
        } else {
          print('Data tidak memiliki format yang diharapkan');
        }
      } else {
        throw Exception('Failed to load organizations');
      }
    } on TimeoutException catch (_) {
      print('Request timed out');
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOrganizations(); // Mengambil data saat halaman pertama kali dibuka
  }

  void _filterOrganizations(String query) {
    final results = organizations.where((org) {
      final name = org['nama_instansi']?.toLowerCase() ?? '';
      final location = org['provinsi']?.toLowerCase() ?? '';
      return name.contains(query.toLowerCase()) ||
          location.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredOrganizations = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input pencarian
            TextField(
              controller: _searchController,
              onChanged: _filterOrganizations,
              decoration: InputDecoration(
                labelText: "Cari Lembaga",
                labelStyle: TextStyle(color: ColorPalete.utama),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.blue, // Warna biru untuk border ketika tidak fokus
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.blue, // Warna biru untuk border ketika fokus
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),

            const SizedBox(height: 20.0),
            // Daftar lembaga
            Expanded(
              child: filteredOrganizations.isEmpty
                  ? const Center(
                      child: Text("Tidak ada data yang ditemukan"),
                    )
                  : ListView.builder(
                      itemCount: filteredOrganizations.length,
                      itemBuilder: (context, index) {
                        final organization = filteredOrganizations[index];

                        return GestureDetector(
                          onTap: () {
                            // Aksi saat item ditekan
                            // Misalnya navigasi ke halaman detail
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InstitutionDetailPage(id_instansi: organization['id'],),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: ColorPalete.utama,
                                width: 1.5, // Warna stroke biru
                              ),
                              borderRadius: BorderRadius.circular(12), // Sudut melengkung
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(30.0),
                                  child: Image.network(
                                    organization['logo'] != null
                                        ? "${ApiUri.bbaseUrl}/storage/${organization['logo']}"
                                        : "https://via.placeholder.com/60", // Placeholder jika tidak ada gambar
                                    width: 60.0,
                                    height: 60.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  organization['nama_instansi'] ?? 'Nama Tidak Tersedia',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  organization['provinsi'] ?? 'Kota Tidak Tersedia',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

