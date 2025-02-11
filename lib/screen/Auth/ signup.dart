import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pfm/screen/Auth/login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  void signup(BuildContext context) async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showError(context, 'All fields are required');
      return;
    }

    if (password != confirmPassword) {
      showError(context, 'Passwords do not match');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/signup'),
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        var data = jsonDecode(response.body);
        showSuccess(context, 'Signup successful! 🎉');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else {
        showError(context, 'Signup failed, try again');
      }
    } catch (e) {
      showError(context, 'An error occurred, please try again');
    }
  }

  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Column(
                children: const [
                  SizedBox(height: 60.0),
                  Text("Sign up",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Text("Create your account",
                      style: TextStyle(fontSize: 15, color: Colors.grey)),
                ],
              ),
              Column(
                children: <Widget>[
                  _inputField(nameController, "Name", Icons.person),
                  const SizedBox(height: 20),
                  _inputField(emailController, "Email", Icons.email),
                  const SizedBox(height: 20),
                  _inputField(passwordController, "Password", Icons.lock,
                      obscureText: true),
                  const SizedBox(height: 20),
                  _inputField(
                      confirmPasswordController, "Confirm Password", Icons.lock,
                      obscureText: true),
                ],
              ),
              ElevatedButton(
                onPressed: () => signup(context),
                child: const Text("Sign up", style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Login())),
                    child: const Text("Login",
                        style: TextStyle(color: Colors.blue)),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(
      TextEditingController controller, String hint, IconData icon,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none),
        fillColor: Colors.blue.withOpacity(0.1),
        filled: true,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
