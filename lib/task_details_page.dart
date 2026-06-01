import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskDetailsPage extends StatelessWidget {
  final String taskId;
  final Map<String, dynamic> taskData;

  const TaskDetailsPage({
    super.key,
    required this.taskId,
    required this.taskData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    final bool isAssignedToMe =
        currentUser != null && taskData['assignedTo'] == currentUser.uid;

    final String status = taskData['status'] ?? 'pending';
    final bool isCompleted = status == 'completed';

    Color statusColor;
    IconData statusIcon;

    if (isCompleted) {
      statusColor = const Color(0xFF00B894);
      statusIcon = Icons.check_circle_outline;
    } else if (status == 'in_progress') {
      statusColor = Colors.orange;
      statusIcon = Icons.timelapse_outlined;
    } else {
      statusColor = Colors.redAccent;
      statusIcon = Icons.pending_outlined;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE SECTION
            Text(
              taskData['title'] ?? '',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            /// STATUS BADGE
            _buildStatusBadge(status, statusColor, statusIcon),

            const SizedBox(height: 30),

            /// DESCRIPTION CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Description",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    taskData['description'] ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color:
                          theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// COMPLETE BUTTON
            if (isAssignedToMe && !isCompleted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('tasks')
                        .doc(taskId)
                        .update({
                      'status': 'completed',
                      'completedAt':
                          FieldValue.serverTimestamp(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Task Marked as Completed"),
                      ),
                    );

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Mark as Completed",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

            if (!isAssignedToMe)
              Center(
                child: Text(
                  "This task is not assigned to you.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// ================= STATUS BADGE =================
  Widget _buildStatusBadge(
      String status,
      Color color,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            status.replaceAll("_", " "),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}