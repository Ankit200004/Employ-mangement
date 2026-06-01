import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class BackendApiService {
  Future<Map<String, dynamic>> getProfile(String token) async {
    final res = await ApiClient.get(
      "${ApiConstants.baseUrl}/profile",
      token,
    );

    return jsonDecode(res.body);
  }
}
