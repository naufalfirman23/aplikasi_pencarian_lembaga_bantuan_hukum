import 'package:flutter/material.dart';
import 'package:hukum_apps/pages/room_chat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;


import '../const/capi.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Future<List<dynamic>> fetchContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');

    if (token == null) {
      throw Exception("User not authenticated");
    }

    final url = Uri.parse(ApiChat.baseUrl + ApiChat.getContacts);

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("HAHAHAHDATADATA: ${jsonEncode(data)}");

      return data['contacts'];
    } else {
      throw Exception('Failed to load messages');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        setState(() {}); // Memanggil setState untuk reload data
        return true; // Izinkan navigasi back
      },
      child: Scaffold(
        body: FutureBuilder<List<dynamic>>(
          future: fetchContacts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              var contacts = snapshot.data!;
              return ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  var username = contacts[index]['username'] ?? 'No Username';
                  var lastMessage =
                      contacts[index]['last_message'] ?? 'No last message';
                  var createdAtRaw = contacts[index]['max_created_at'] ?? '';
                  var createdAt = createdAtRaw.isNotEmpty
                      ? timeago.format(DateTime.parse(createdAtRaw),
                          locale: 'id')
                      : 'N/A';

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomChat(
                            idContacts: contacts[index]['id'],
                            names: contacts[index]['username'],
                          ),
                        ),
                      ).then((_) {
                        // Reload halaman saat kembali
                        setState(() {});
                      });
                    },
                    child: Card(
                      elevation: 5,
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(15),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            username[
                                0], // Menampilkan huruf pertama dari username
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          username,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(lastMessage),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              createdAt,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.blueAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text('No contacts found'));
            }
          },
        ),
      ),
    );
  }
}
