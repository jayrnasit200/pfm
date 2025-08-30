import 'package:flutter/material.dart';
import 'package:pfm/screen/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Contactinfo extends StatefulWidget {
  const Contactinfo({Key? key}) : super(key: key);

  @override
  _ContactinfoState createState() => _ContactinfoState();
}

class _ContactinfoState extends State<Contactinfo> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load user profile from local storage (SharedPreferences)
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('name') ?? '';
      emailController.text = prefs.getString('email') ?? '';
      isLoading = false;
    });
  }

  /// Save profile locally
  Future<void> _updateProfile() async {
    final prefs = await SharedPreferences.getInstance();

    // Validate input
    if (nameController.text.isEmpty || emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Save locally
    await prefs.setString('name', nameController.text);
    await prefs.setString('email', emailController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile updated successfully!"),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back to profile screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Profile()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Edit Profile"), backgroundColor: Colors.blue),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text("Save Changes",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
    );
  }
}
