import 'package:flutter/material.dart';
import 'package:hukum_apps/const/cTruncate.dart';
import 'package:hukum_apps/const/ccolor.dart';

import 'room_chat.dart';

class LawyerDetailPage extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double rating;
  final int id_user;
  final String description;
  final String location;
  final String organization;

  const LawyerDetailPage({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.id_user,
    required this.description,
    required this.location,
    required this.organization,
  });

  void _goToRoomChat(BuildContext context, int idUserAdmin, String nama) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomChat(
          idContacts: idUserAdmin,
          names: nama,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail Lawyer",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ColorPalete.utama,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: const Color.fromARGB(19, 126, 125, 125),
                  border: Border(
                      bottom:
                          BorderSide(color: ColorPalete.utama, width: 1.5))),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
                child: Image.network(
                  imageUrl,
                  height: 250.0,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      padding: EdgeInsets.all(12),
                      color: const Color.fromARGB(19, 126, 125, 125),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              Row(
                                children: List.generate(5, (index) {
                                  if (rating > index) {
                                    return Icon(
                                      Icons.star,
                                      color: checking(
                                          rating),
                                      size: 20,
                                    );
                                  } else if (rating > index - 0.5) {
                                    return Icon(
                                      Icons.star_half,
                                      color: checking(
                                          rating), 
                                      size: 20,
                                    );
                                  } else {
                                    return Icon(
                                      Icons.star_border,
                                      color: checking(
                                          rating),
                                      size: 20,
                                    );
                                  }
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            children: [
                              const Icon(Icons.account_balance,
                                  color: Colors.blue),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  "Lembaga Asal: $organization",
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 14,
                              ),
                              Text(
                                truncateText(location, 5),
                                style: const TextStyle(fontSize: 12.0),
                              ),
                              const SizedBox(height: 10.0),
                            ],
                          ),
                        ],
                      )),
                  const SizedBox(height: 20.0),
                  const Text(
                    "Tentang Lawyer:",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 20.0),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _goToRoomChat(context, id_user, name),
                      icon: const Icon(Icons.message, color: Colors.white),
                      label: const Text(
                        "Hubungi Sekarang",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalete.merah,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 12.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
