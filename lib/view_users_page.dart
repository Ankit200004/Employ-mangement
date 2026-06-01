import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewUsersPage extends StatelessWidget {
  const ViewUsersPage({Key? key}) : super(key: key);

  Future<void> _deleteUser(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting user: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context, String docId, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete User"),
        content: Text("Are you sure you want to delete $name?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Delete",
                style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(context, docId);
            },
          ),
        ],
      ),
    );
  }

//   void _showComplaintDialog(
//       BuildContext context, String docId, String name) {

//     final TextEditingController complaintController =
//         TextEditingController();

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text("Write Complaint for $name"),
//         content: TextField(
//           controller: complaintController,
//           maxLines: 3,
//           decoration: const InputDecoration(
//             hintText: "Enter complaint...",
//             border: OutlineInputBorder(),
//           ),
//         ),
//         actions: [
//           TextButton(
//             child: const Text("Cancel"),
//             onPressed: () => Navigator.pop(context),
//           ),
//           ElevatedButton(
//             child: const Text("Submit"),
//             onPressed: () async {
//               if (complaintController.text.trim().isEmpty) return;

//               await FirebaseFirestore.instance
//                   .collection('users')
//                   .doc(docId)
//                   .update({
//                 'complaints': FieldValue.arrayUnion([
//                   {
//                     'text': complaintController.text.trim(),
//                     'createdAt': FieldValue.serverTimestamp(),
//                   }
//                 ])
//               });

//               Navigator.pop(context);

//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                     content: Text("Complaint added successfully")),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
    void _showComplaintDialog(
    BuildContext context, String docId, String name) {

  final TextEditingController complaintController =
      TextEditingController();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Write Complaint for $name"),
      content: TextField(
        controller: complaintController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: "Enter complaint...",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text("Submit"),
          onPressed: () async {

            final complaintText = complaintController.text.trim();

            if (complaintText.isEmpty) return;

            await FirebaseFirestore.instance
                .collection('complaints')
                .add({
              'userId': docId,                 // To whom
              'userName': name,                // Optional display name
              'complaint': complaintText,      // Complaint text
              'createdBy': FirebaseAuth.instance.currentUser!.uid,
              'createdAt': FieldValue.serverTimestamp(),
            });

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Complaint submitted successfully"),
              ),
            );
          },
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFDFE6E9),
      appBar: AppBar(
        title: const Text("All Users"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'user')
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No users found",
                  style: TextStyle(fontSize: 16)),
            );
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {

              final doc = users[index];
              final data = doc.data() as Map<String, dynamic>;

              final String name = data['name'] ?? '';
              final String phone = data['phone'] ?? 'No Number';

              final displayName =
                  name.trim().isNotEmpty ? name : phone;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [

                      /// Avatar
                      CircleAvatar(
                        radius: 26,
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.15),
                        child: Text(
                          displayName[0].toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      /// Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(
                                      fontWeight:
                                          FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              phone,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),

                      /// Complaint Button
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.orange),
                        onPressed: () => _showComplaintDialog(
                            context, doc.id, displayName),
                      ),

                      /// Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red),
                        onPressed: () => _confirmDelete(
                            context, doc.id, displayName),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
