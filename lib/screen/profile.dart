import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:pfm/NavigationBar.dart';
import 'package:pfm/data/local/local_db.dart';
import 'package:pfm/data/models/user.dart';
import 'package:pfm/screen/Auth/Login.dart';
import 'package:pfm/screen/GoalsList.dart';
import 'package:pfm/screen/contactinfo.dart';
import 'package:pfm/screen/joblist.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? _user;
  final Color primaryBlue = Colors.blue;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final db = LocalDb.isar;
    final users = await db.users.where().findAll();
    if (users.isNotEmpty) {
      setState(() {
        _user = users.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const NavigationBars("Profile"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel("Account Settings"),
                  _buildProfileOption("Set Financial Goals", Icons.flag_rounded,
                      () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => GoalsList()));
                  }),
                  _buildProfileOption(
                      "Employment / Jobs", Icons.work_outline_rounded, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => JobListScreen()));
                  }),
                  _buildProfileOption(
                      "Contact Information", Icons.contact_mail_outlined, () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Contactinfo()));
                  }),
                  const SizedBox(height: 20),
                  _sectionLabel("Security"),
                  _buildProfileOption(
                    "Logout",
                    Icons.logout_rounded,
                    _handleLogout,
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 80, bottom: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryBlue.withOpacity(0.15), Colors.white],
        ),
      ),
      child: Column(
        children: [
          // Avatar with Blue Opacity ring
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryBlue.withOpacity(0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: primaryBlue.withOpacity(0.1),
              backgroundImage: const NetworkImage(
                "https://img.freepik.com/premium-vector/blue-circle-with-white-user-vector_941526-5765.jpg?semt=ais_hybrid",
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            _user?.name ?? 'Guest User',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            _user?.email ?? 'Not signed in',
            style: TextStyle(
                fontSize: 14, color: Colors.grey[600], letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: primaryBlue.withOpacity(0.6),
            letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildProfileOption(String title, IconData icon, VoidCallback onTap,
      {bool isDestructive = false}) {
    final Color color = isDestructive ? Colors.redAccent : primaryBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.redAccent : Colors.black87)),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: color.withOpacity(0.3),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final db = LocalDb.isar;
    await db.writeTxn(() async {
      await db.users.clear();
    });

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Logged out successfully"),
        backgroundColor: Colors.blue.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
