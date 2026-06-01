import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'write_complaint_page.dart';
import 'my_complaints_page.dart';
import 'all_tasks_page.dart';
import 'today_work_page.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  final TextEditingController nameController = TextEditingController();

  bool isLoading = true;
  String? userName;

  bool isWorking = false;
  DateTime? startTime;
  Duration elapsed = Duration.zero;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _checkUserName();
    _restoreWorkState(); // restore timer if app was closed
  }

  @override
  void dispose() {
    timer?.cancel();
    nameController.dispose();
    super.dispose();
  }

  /// ================= CHECK USER NAME =================
  Future<void> _checkUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    if (doc.exists && doc.data()?['name'] != null) {
      setState(() {
        userName = doc['name'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      _showNameDialog();
    }
  }

  Future<void> _restoreWorkState() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('active_work')
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    startTime = (doc['startTime'] as Timestamp).toDate();

    setState(() {
      isWorking = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        elapsed = DateTime.now().difference(startTime!);
      });
    });
  }

  void _showNameDialog() {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Welcome 👋"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: "Enter Your Name",
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  _saveName();
                }
              },
              child: const Text("Continue"),
            )
          ],
        ),
      );
    });
  }

  Future<void> _saveName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({'name': nameController.text.trim()},
            SetOptions(merge: true));

    if (!mounted) return;

    setState(() => userName = nameController.text.trim());
    Navigator.pop(context);
  }

  /// ================= WORK TIMER =================
  Future<void> _startWork(bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (value) {
      startTime = DateTime.now();

      await FirebaseFirestore.instance
          .collection('active_work')
          .doc(user.uid)
          .set({
        'startTime': startTime,
        'name': userName,
      });

      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          elapsed = DateTime.now().difference(startTime!);
        });
      });
    } else {
      _stopWork();
    }

    setState(() => isWorking = value);
  }

  Future<void> _stopWork() async {
    timer?.cancel();
    if (startTime == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime!);

    await FirebaseFirestore.instance.collection('attendance').add({
      'userId': user.uid,
      'name': userName,
      'startTime': startTime,
      'endTime': endTime,
      'formattedTime': formatTime(duration),
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    await FirebaseFirestore.instance
    .collection('active_work')
    .doc(user.uid)
    .delete();

  setState(() {
    isWorking = false;
    startTime = null;
    elapsed = Duration.zero;
  });
  }

  String formatTime(Duration d) {
    return "${d.inHours.toString().padLeft(2, '0')}:"
        "${(d.inMinutes % 60).toString().padLeft(2, '0')}:"
        "${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  /// ================= APPLY HOLIDAY =================
  Future<void> _applyForHoliday() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (selectedDate == null) return;

    final docId =
        "${user.uid}_${selectedDate.year}_${selectedDate.month}_${selectedDate.day}";

    await FirebaseFirestore.instance
        .collection('holidays')
        .doc(docId)
        .set({
      'userId': user.uid,
      'name': userName,
      'date': Timestamp.fromDate(selectedDate),
      'formattedDate':
          "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Holiday Applied Successfully")),
    );
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      drawer: _buildPremiumDrawer(),
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, ${userName ?? ''} 👋",
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Let’s make today productive",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 30),
            _buildPremiumWorkCard(),
            const SizedBox(height: 30),
            _buildPremiumHolidayButton(),
          ],
        ),
      ),
    );
  }

  /// ================= PREMIUM WORK CARD =================
  Widget _buildPremiumWorkCard() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isWorking ? "You are Working" : "Start Your Work",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              formatTime(elapsed),
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Working Status",
                style: TextStyle(color: Colors.white70),
              ),
              Switch(
                value: isWorking,
                activeColor: Colors.white,
                onChanged: _startWork,
              ),
            ],
          )
        ],
      ),
    );
  }

  /// ================= HOLIDAY BUTTON =================
  Widget _buildPremiumHolidayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.beach_access_outlined),
        label: const Text("Apply for Holiday"),
        onPressed: _applyForHoliday,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  /// ================= PREMIUM DRAWER =================
  Widget _buildPremiumDrawer() {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text(
                    userName != null && userName!.isNotEmpty
                        ? userName![0].toUpperCase()
                        : "U",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName ?? "User",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  FirebaseAuth.instance.currentUser?.phoneNumber ?? "",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _drawerItem(
          Icons.access_time,
          "Today's Work",
          TodayWorkPage(),
        ),
          _drawerItem(Icons.task_alt_outlined, "All Tasks", const AllTasksPage()),
          _drawerItem(Icons.edit_note_outlined, "Write Complaint", WriteComplaintPage()),
          _drawerItem(Icons.list_alt_outlined, "My Complaints", MyComplaintsPage()),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }
}