import 'package:flutter/material.dart';
import '../../../services/firebase_auth_service.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();

  bool otpSent = false;
  bool loading = false;
  String? error;

  /// SEND OTP
  Future<void> sendOTP(String phone) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      await _authService.sendOTP(phone);
      otpSent = true;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// VERIFY OTP
  Future<String?> verifyOTP(String otp) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      final token = await _authService.verifyOTP(otp);
      return token;
    } catch (e) {
      error = e.toString();
      return null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
