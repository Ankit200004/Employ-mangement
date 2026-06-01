import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final AuthController controller = AuthController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Auth")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// PHONE INPUT
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Phone number",
                    hintText: "9876543210",
                  ),
                ),

                const SizedBox(height: 16),

                /// SEND OTP BUTTON
                ElevatedButton(
                  onPressed: controller.loading
                      ? null
                      : () {
                          controller.sendOTP(
                            phoneController.text.trim(),
                          );
                        },
                  child: controller.loading
                      ? const CircularProgressIndicator()
                      : const Text("Send OTP"),
                ),

                if (controller.otpSent) ...[
                  const SizedBox(height: 20),

                  /// OTP INPUT
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Enter OTP",
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// VERIFY OTP BUTTON
                  ElevatedButton(
                    onPressed: controller.loading
                        ? null
                        : () async {
                            final token = await controller.verifyOTP(
                              otpController.text.trim(),
                            );

                            if (token != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Login Successful 🎉"),
                                ),
                              );
                            }
                          },
                    child: controller.loading
                        ? const CircularProgressIndicator()
                        : const Text("Verify OTP"),
                  ),
                ],

                if (controller.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    controller.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
