import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:pfm/NavigationBar.dart';
import 'package:pfm/data/local/local_db.dart';
import 'package:pfm/data/models/job.dart';
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
    final size = MediaQuery.of(context).size;
    final double swidth = size.width;

    return Scaffold(
      bottomNavigationBar: const NavigationBars("Profile"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 50),
            ClipRRect(
              borderRadius: BorderRadius.circular(1000),
              child: Image.network(
                "https://img.freepik.com/premium-vector/blue-circle-with-white-user-vector_941526-5765.jpg?semt=ais_hybrid",
                height: swidth / 4,
                width: swidth / 4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _user?.name ?? 'Guest',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              _user?.email ?? 'Guest',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            _buildProfileOption("Set Goals", Icons.flag, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GoalsList()),
              );
            }),
            _buildProfileOption("Add Job", Icons.work, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JobListScreen()),
              );
            }),
            _buildProfileOption("Contact Information", Icons.phone, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Contactinfo()),
              );
            }),
            _buildProfileOption("Logout", Icons.logout, () async {
              final db = LocalDb.isar;
              await db.writeTxn(() async {
                await db.users.clear();
              });

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Logged out successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
