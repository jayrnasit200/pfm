import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:FINEXA/NavigationBar.dart';
import 'package:FINEXA/screen/Auth/Login.dart';
import 'package:FINEXA/screen/GoalsList.dart';
import 'package:FINEXA/screen/contactinfo.dart';
import 'package:FINEXA/screen/joblist.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _name = 'Guest User';
  String _email = 'Sign in to sync data';

  final Color primaryBlue = Colors.blueAccent;

  @override
  void initState() {
    super.initState();
    _loadUserFromPrefs();
  }

  // ───────────────── LOAD USER (LIVE LOGIN DATA) ─────────────────

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (!isLoggedIn) return;

    setState(() {
      _name = prefs.getString('name') ?? 'Guest User';
      _email = prefs.getString('email') ?? '';
    });
  }

  // ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      bottomNavigationBar: const NavigationBars("Profile"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel("Financial Management"),
                  _buildProfileOption(
                    "Savings & Goals",
                    Icons.track_changes_rounded,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GoalsList()),
                    ),
                  ),
                  _buildProfileOption(
                    "Work & Employment",
                    Icons.work_history_rounded,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const JobListScreen()),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionLabel("Personal Details"),
                  _buildProfileOption(
                    "Contact Information",
                    Icons.alternate_email_rounded,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Contactinfo()),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionLabel("Account Safety"),
                  _buildProfileOption(
                    "Logout",
                    Icons.power_settings_new_rounded,
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

  // ───────────────── HEADER ─────────────────

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 80, bottom: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryBlue.withOpacity(0.1), width: 4),
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: primaryBlue.withOpacity(0.05),
              backgroundImage: const NetworkImage(
                "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _email,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── SECTIONS ─────────────────

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade500,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final Color iconColor = isDestructive ? Colors.redAccent : primaryBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.02)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDestructive ? Colors.redAccent : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.grey.shade300,
          size: 16,
        ),
      ),
    );
  }

  // ───────────────── LOGOUT ─────────────────

  Future<void> _handleLogout() async {
    bool confirm = await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Logout"),
            content: const Text(
                "Are you sure you want to sign out? Your local data will be cleared."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child:
                    const Text("Logout", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
      (_) => false,
    );
  }
}
