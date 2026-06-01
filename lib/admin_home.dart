import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'assign_work_page.dart';
import 'attendance_page.dart';
import 'view_users_page.dart';


class AdminHome extends StatelessWidget {
  const AdminHome({Key? key}) : super(key: key);

  Widget _bentoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 32,
                color: theme.colorScheme.primary,
              ),
              const Spacer(),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFDFE6E9),
      body: CustomScrollView(
        slivers: [

          /// 💜 Gradient SliverAppBar
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("Admin Dashboard"),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFA29BFE),
                      Color(0xFF6C5CE7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          /// 📦 Bento Grid
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              delegate: SliverChildListDelegate([
                _bentoCard(
                  context,
                  title: "Assign Task",
                  icon: Icons.work_outline,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AssignWorkPage(),
                      ),
                    );
                  },
                ),
                _bentoCard(
                  context,
                  title: "Attendance",
                  icon: Icons.check_circle_outline,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AttendancePage(),
                      ),
                    );
                  },
                ),
                _bentoCard(
                  context,
                  title: "View Users",
                  icon: Icons.people_outline,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ViewUsersPage(),
                      ),
                    );
                  },
                ),
                _bentoCard(
                  context,
                  title: "Logout",
                  icon: Icons.logout,
                  onTap: () => _logout(context),
                ),
              ]),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
