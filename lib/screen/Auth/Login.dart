import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pfm/screen/Auth/%20signup.dart';
import 'package:pfm/screen/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String baseurl = "http://127.0.0.1:8000";

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  String get baseUrl => const String.fromEnvironment('BASE_URL');

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login(BuildContext context, String email, String password) async {
    // temp
    upDateSharedPreferences(1, 'jay', 'jay@jay.com');
    showSuccess(context, 'Login successful! 🎉');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const homescreen()),
    );
    if (email.isEmpty || password.isEmpty) {
      showError(context, 'Please fill in all fields');
      return;
    }

    try {
      final response = await http.post(
        // Uri.parse(widget.baseUrl + '/api/login'),
        Uri.parse('http://localhost:8000/api/login'),
        body: {'email': email, 'password': password},
      );

      if (!mounted) return; // Avoid errors when widget is unmounted

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var userdata = data['user'];
        upDateSharedPreferences(
            userdata['id'], userdata['name'], userdata['email']);
        showSuccess(context, 'Login successful! 🎉');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const homescreen()),
        );
      } else {
        showError(context, 'Invalid email or password');
      }
    } catch (e) {
      // debugPrint(String.fromEnvironment('BASE_URL'));
      debugPrint(e.toString());

      // showError(context, String.fromEnvironment('genBaseUrl'));
      showError(context, 'An error occurred, please try again');
    }
  }

  void upDateSharedPreferences(int id, String name, String email) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    // _prefs.setString('token', token);
    _prefs.setInt('id', id);
    _prefs.setString('name', name);
    _prefs.setString('email', email);
    _prefs.get('id');
  }

  void showError(BuildContext context, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void showSuccess(BuildContext context, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text("Enter your credentials to login",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 32),
                _inputField(),
                const SizedBox(height: 20),
                _loginButton(),
                _forgotPassword(),
                _signupLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.blue.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.blue.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.lock),
          ),
        ),
      ],
    );
  }

  Widget _loginButton() {
    return ElevatedButton(
      onPressed: () {
        login(context, emailController.text.trim(),
            passwordController.text.trim());
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.blue,
      ),
      child: const Text("Login",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          )),
    );
  }

  Widget _forgotPassword() {
    return TextButton(
      onPressed: () {
        showError(context, 'Forgot Password clicked');
      },
      child: const Text("Forgot password?",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
    );
  }

  Widget _signupLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        TextButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Signup()));
          },
          child: const Text("Sign Up", style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}
