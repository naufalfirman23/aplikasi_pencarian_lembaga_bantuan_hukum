import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hukum_apps/const/cTruncate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const/capi.dart';
import '../const/ccolor.dart';
import '../const/cfont.dart';

class RoomChat extends StatefulWidget {
  final int idContacts;
  final String names;

  const RoomChat({super.key, required this.idContacts, required this.names});

  @override
  State<RoomChat> createState() => _RoomChatState();
}

class _RoomChatState extends State<RoomChat> {
  List<Map<String, dynamic>> messages =
      []; // Daftar pesan dengan dynamic untuk timestamp
  late ScrollController _scrollController; // Tambahkan ScrollController
  final TextEditingController messageController = TextEditingController();

  Future<void> fetchMessage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? "";

      if (token.isEmpty) {
        throw Exception("Token tidak ditemukan. Silakan login ulang.");
      }

      final url = Uri.parse(ApiChat.baseUrl + ApiChat.fetchMessages);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"id": widget.idContacts}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        setState(() {
          messages = (data['messages'] as List)
              .map((msg) => {
                    "sender": msg["from_id"] == widget.idContacts
                        ? "contact"
                        : "user",
                    "message": msg["body"],
                    "timestamp": DateTime.parse(msg["created_at"]),
                  })
              .toList()
              .cast<Map<String, dynamic>>();

          messages.sort((a, b) => a["timestamp"].compareTo(b["timestamp"]));
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        });

        print("Pesan berhasil diambil: ${response.body}");
      } else {
        print("Gagal mengambil pesan: ${response.body}");
      }
    } catch (error) {
      print("Terjadi kesalahan: $error");
    }
  }

  Future<void> sendMessage(String message) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? "";

      if (token.isEmpty) {
        throw Exception("Token tidak ditemukan. Silakan login ulang.");
      }

      final url = Uri.parse(ApiChat.baseUrl + ApiChat.sendMessage);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "id": widget.idContacts,
          "message": message,
          "type": "user",
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        setState(() {
          messages.add({
            "sender": "user",
            "message": message,
            "timestamp": DateTime.now(),
          });
          fetchMessage(); // Reload data dari server
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        });

        print("Pesan berhasil dikirim: ${data['message']}");
      } else {
        print("Gagal mengirim pesan: ${response.body}");
      }
    } catch (error) {
      print("Terjadi kesalahan: $error");
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    fetchMessage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: Text(
          truncateText(widget.names, 4),
          style: TextStyle(
            color: Colors.white,
            fontFamily: FontType.interBold,
          ),
        ),
        backgroundColor: ColorPalete.utama,
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isUserMessage = message["sender"] == "user";

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: isUserMessage
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 15.0),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          decoration: BoxDecoration(
                            color: isUserMessage ? Colors.blue : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0),
                              bottomLeft: isUserMessage
                                  ? Radius.circular(15.0)
                                  : Radius.zero,
                              bottomRight: isUserMessage
                                  ? Radius.zero
                                  : Radius.circular(15.0),
                            ),
                          ),
                          child: Text(
                            message["message"] ?? "",
                            style: TextStyle(
                              color:
                                  isUserMessage ? Colors.white : Colors.black,
                              fontFamily: FontType.interReg,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Tulis pesan...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors
                              .blue, // Warna biru untuk border ketika tidak fokus
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors
                              .blue, // Warna biru untuk border ketika fokus
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 15.0,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: ColorPalete.utama),
                  onPressed: () {
                    final message = messageController.text.trim();
                    if (message.isNotEmpty) {
                      sendMessage(message);
                      messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
