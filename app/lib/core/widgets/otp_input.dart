import 'package:flutter/material.dart';

class OTPInput extends StatelessWidget {
  final TextEditingController controller;

  const OTPInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(labelText: "OTP"),
    );
  }
}
