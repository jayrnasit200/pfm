import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pfm/screen/Auth/%20signup.dart';
import 'package:pfm/screen/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  // Custom Color Base
  final Color primaryBlue = Colors.blue;

  void login(BuildContext context, String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      showError(context, 'Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/login'),
        body: {'email': email, 'password': password},
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var userdata = data['user'];

        await upDateSharedPreferences(
            userdata['id'], userdata['name'], userdata['email']);

        showSuccess(context, 'Login successful!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        showError(context, 'Invalid email or password');
      }
    } catch (e) {
      showError(context, 'Server connection failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> upDateSharedPreferences(
      int id, String name, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setInt('id', id);
    await prefs.setString('name', name);
    await prefs.setString('email', email);
  }

  void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: primaryBlue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                // Header Icon with Opacity
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_person_rounded,
                      size: 60, color: primaryBlue),
                ),
                const SizedBox(height: 30),
                Text(
                  "Welcome Back",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue.withOpacity(0.8)),
                ),
                const SizedBox(height: 8),
                Text(
                  "Please sign in to continue",
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),

                // Input Fields
                _inputField(emailController, "Email Address",
                    Icons.email_rounded, false),
                const SizedBox(height: 16),
                _inputField(passwordController, "Password",
                    Icons.vpn_key_rounded, true),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                          color: primaryBlue.withOpacity(0.7),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Login Button
                _loginButton(),
                const SizedBox(height: 25),

                // Signup Link
                _signupLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String hint,
      IconData icon, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: primaryBlue.withOpacity(0.4)),
        prefixIcon: Icon(icon, color: primaryBlue.withOpacity(0.5)),
        filled: true,
        fillColor: primaryBlue.withOpacity(0.05), // Soft Blue Background
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryBlue.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
              BorderSide(color: primaryBlue.withOpacity(0.4), width: 1.5),
        ),
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () => login(context, emailController.text.trim(),
                passwordController.text.trim()),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue.withOpacity(0.9),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Text("LOGIN",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
      ),
    );
  }

  Widget _signupLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? ",
            style: TextStyle(color: Colors.grey[600])),
        GestureDetector(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Signup())),
          child: Text(
            "Sign Up",
            style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
