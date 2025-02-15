import 'package:flutter/material.dart';
import 'package:pfm/NavigationBar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double swidth = size.width;
    return Scaffold(
      bottomNavigationBar: NavigationBars("Profile"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 50),
            ClipRRect(
              borderRadius: BorderRadius.circular(1000),
              child: Image.network(
                "https://img.freepik.com/free-photo/3d-illustration-cute-cartoon-girl-blue-jacket-glasses_1142-41044.jpg",
                height: swidth / 4,
                width: swidth / 4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'User Name',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'user.email@example.com',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            _buildProfileOption("Set Goals", Icons.flag, () {
              // Implement goal setting functionality
            }),
            _buildProfileOption("Add Job", Icons.work, () {
              // Implement add job functionality
            }),
            _buildProfileOption("Contact Information", Icons.phone, () {
              // Implement contact info update functionality
            }),
            _buildProfileOption("Logout", Icons.logout, () {
              // Implement logout functionality
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
        title: Text(title, style: TextStyle(fontSize: 18)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
