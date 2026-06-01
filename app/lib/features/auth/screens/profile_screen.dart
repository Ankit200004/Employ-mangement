import 'package:flutter/material.dart';
import '../../../services/backend_api_service.dart';
import '../../../services/token_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: FutureBuilder(
        future: BackendApiService()
            .getProfile(TokenService.token!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data as Map<String, dynamic>;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("UID: ${data['uid']}"),
                Text("Phone: ${data['phone']}"),
                Text("Provider: ${data['provider']}"),
              ],
            ),
          );
        },
      ),
    );
  }
}
