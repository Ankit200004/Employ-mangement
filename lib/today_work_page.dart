import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodayWorkPage extends StatelessWidget {
  const TodayWorkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    /// today range
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Work"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
    .collection('attendance')
    .where('userId', isEqualTo: user.uid)
    .where(
      'startTime',
      isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
    )
    .where(
      'startTime',
      isLessThan: Timestamp.fromDate(tomorrowStart),
    )
    .snapshots(),
        builder: (context, snapshot) {
          /// LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          /// ERROR
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          /// EMPTY
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _emptyState(theme);
          }

          final docs = snapshot.data!.docs;

          /// calculate total seconds
          int totalSeconds = 0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            totalSeconds += (data['totalSeconds'] ?? 0) as int;
          }

          final totalDuration = Duration(seconds: totalSeconds);

          final hours = totalDuration.inHours;
          final minutes = totalDuration.inMinutes % 60;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// TOTAL CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Today's Work",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "$hours h $minutes m",
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Total time worked today",
                        style: TextStyle(color: Colors.white70),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// WORK SESSION LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data =
                          docs[index].data() as Map<String, dynamic>;

                      final start =
                          (data['startTime'] as Timestamp?)?.toDate();
                      final end =
                          (data['endTime'] as Timestamp?)?.toDate();

                      final seconds = data['totalSeconds'] ?? 0;
                      final duration = Duration(seconds: seconds);

                      if (start == null || end == null) {
                        return const SizedBox();
                      }

                      return _workCard(theme, start, end, duration);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// EMPTY STATE
  Widget _emptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_off_outlined,
            size: 70,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            "No work recorded today",
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            "Start your work timer to track your time.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// WORK SESSION CARD
  Widget _workCard(
      ThemeData theme, DateTime start, DateTime end, Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${start.hour}:${start.minute.toString().padLeft(2, '0')} → ${end.hour}:${end.minute.toString().padLeft(2, '0')}",
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                "Work session",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
          Text(
            "$hours h $minutes m",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}