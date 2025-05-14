import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'const/cfont.dart';
import 'pages/splash.dart';

final InAppLocalhostServer localhostServer = InAppLocalhostServer();
void main() async {
  void setupTimeago() {
    timeago.setLocaleMessages('id', timeago.IdMessages());
  }
  setupTimeago();
  await initializeDateFormatting('id_ID', null);
  WidgetsFlutterBinding.ensureInitialized();
  await localhostServer.start();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const MyApp(),
    theme: ThemeData(
      fontFamily: FontType.interReg,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
    ),
    initialRoute: '/',
  ));
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
