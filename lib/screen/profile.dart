import 'package:flutter/material.dart';
import 'package:pfm/NavigationBar.dart';
import 'package:pfm/screen/joblist.dart';
import 'package:pfm/screen/rota.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String baseurl = "http://127.0.0.1:8000";

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
                "https://img.freepik.com/free-photo/3d-illustration-cute-cartoon-girl-blue-jacket-glasses_1142-41044.jpg",
                height: swidth / 4,
                width: swidth / 4,
              ),
            ),
            const SizedBox(height: 10),
            // Text(
            //   // 'User Name',
            //   getLoginname().toString(),
            //   style: Theme.of(context).textTheme.headlineMedium,
            // ),
            FutureBuilder<String>(
              future: getLoginname(), // This returns Future<String>
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return Text(
                    snapshot.data!,
                    style: Theme.of(context).textTheme.headlineMedium,
                  );
                } else {
                  return const Text('No name found');
                }
              },
            ),
            const SizedBox(height: 10),
            FutureBuilder<String>(
              future: getLoginemail(), // This returns Future<String>
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return Text(
                    snapshot.data!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  );
                } else {
                  return const Text('No name found');
                }
              },
            ),

            const SizedBox(height: 20),
            _buildProfileOption("Set Goals", Icons.flag, () {
              // Implement goal setting functionality
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JobListScreen()),
              );
            }),
            _buildProfileOption("Add Job", Icons.work, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JobListScreen()),
              );
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
        title: Text(title, style: const TextStyle(fontSize: 18)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Future<String> getLoginname() async {
    final prefs = await SharedPreferences.getInstance();
    // print(prefs.getString('name'));
    return prefs.getString('name') ?? 'Guest';
  }

  Future<String> getLoginemail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? 'Guest';
  }
}
