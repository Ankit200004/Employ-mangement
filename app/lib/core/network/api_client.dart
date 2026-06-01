import 'package:http/http.dart' as http;

class ApiClient {
  static Future<http.Response> get(
      String url, String token) async {
    return http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
  }
}
