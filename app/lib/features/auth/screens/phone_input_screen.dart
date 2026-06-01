import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'otp_screen.dart';

class PhoneInputScreen extends StatelessWidget {
  const PhoneInputScreen({super.key});

@override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true,
    body: SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFAEEDD),
              Color(0xFFFFE5D4),
            ],
          ),
        ),
        child: SingleChildScrollView(
          reverse: true,
          padding: EdgeInsets.only(
            left: 28,
            right: 28,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const SizedBox(height: 80),

              // Logo
              Image.asset(
                'assets/logo1.jpg',
                height: 120, // reduce size
              ),

              const SizedBox(height: 20),

              const Text(
                "Welcome 👋",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),

              const SizedBox(height: 50),

              // White Card
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Login with Phone",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        "Phone Number",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF8C52),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: '+91 9999999999',
                          prefixIcon: const Icon(
                            Icons.phone_android_rounded,
                            color: Color(0xFFFF8C52),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !RegExp(r'^\+\d{1,3}\d{9,10}$')
                                  .hasMatch(value)) {
                            return 'Enter valid phone number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 35),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _sendCodeToPhoneNumber,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFFF8C52),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            "Send OTP",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ),
  );
}

}
