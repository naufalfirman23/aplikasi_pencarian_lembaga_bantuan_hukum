import 'package:shared_preferences/shared_preferences.dart';


class ApiServices {

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }


}
