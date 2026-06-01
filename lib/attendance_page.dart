import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({Key? key}) : super(key: key);

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "-";
    return DateFormat('hh:mm a').format(timestamp.toDate());
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "-";
    return DateFormat('dd MMM yyyy').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.secondary.withOpacity(0.3),
      appBar: AppBar(
        title: const Text("Attendance Records"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No attendance records"));
          }

          final records = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {

              final data =
                  records[index].data() as Map<String, dynamic>;

              final String name = data['name'] ?? 'Unknown';
              final String formattedTime =
                  data['formattedTime'] ?? '00:00:00';

              final Timestamp? startTime = data['startTime'];
              final Timestamp? endTime = data['endTime'];
              final Timestamp? createdAt = data['createdAt'];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// Name + Duration
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: Text(
                              formattedTime,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// Date
                      Text(
                        "Date: ${_formatDate(createdAt)}",
                        style: theme.textTheme.bodySmall,
                      ),

                      const SizedBox(height: 10),

                      /// Start Time
                      Row(
                        children: [
                          const Icon(Icons.login, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            "Start: ${_formatTime(startTime)}",
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      /// End Time
                      Row(
                        children: [
                          const Icon(Icons.logout, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            "End: ${_formatTime(endTime)}",
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
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
