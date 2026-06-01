import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WriteComplaintPage extends StatefulWidget {
  const WriteComplaintPage({super.key});

  @override
  State<WriteComplaintPage> createState() => _WriteComplaintPageState();
}

class _WriteComplaintPageState extends State<WriteComplaintPage> {
  final TextEditingController complaintController =
      TextEditingController();

  bool isLoading = false;

  Future<void> submitComplaint() async {
    final text = complaintController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please write your complaint before submitting."),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final name = userDoc.data()?['name'] ?? "Unknown";

      await FirebaseFirestore.instance
          .collection('complaints')
          .add({
        'userId': user.uid,
        'name': name,
        'description': text,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      complaintController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Complaint submitted successfully"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Try again."),
        ),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    complaintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Write Complaint"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Text(
              "Describe your issue",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Provide clear details so we can resolve it quickly.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 30),

            /// INPUT CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: complaintController,
                    maxLines: 6,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText:
                          "Write your complaint here...",
                      border: InputBorder.none,
                      counterText: "",
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: complaintController,
                      builder: (context, value, _) {
                        return Text(
                          "${value.text.length}/500",
                          style: theme.textTheme.bodySmall
                              ?.copyWith(
                            color: theme
                                .colorScheme.onSurface
                                .withOpacity(0.5),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isLoading ? null : submitComplaint,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Submit Complaint",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}