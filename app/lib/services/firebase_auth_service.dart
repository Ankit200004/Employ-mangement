import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  /// SEND OTP
  Future<void> sendOTP(String phone) async {
    final formattedPhone =
        phone.startsWith('+') ? phone : '+91$phone';

    await _auth.verifyPhoneNumber(
      phoneNumber: formattedPhone,

      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto verification (Android only)
        await _auth.signInWithCredential(credential);
      },

      verificationFailed: (FirebaseAuthException e) {
        throw Exception(e.message ?? 'OTP verification failed');
      },

      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        print('OTP Sent: $verificationId');
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  /// VERIFY OTP
  Future<String?> verifyOTP(String otp) async {
    if (_verificationId == null) {
      throw Exception('OTP not sent yet');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );

    final userCredential =
        await _auth.signInWithCredential(credential);

    return await userCredential.user?.getIdToken();
  }
}
