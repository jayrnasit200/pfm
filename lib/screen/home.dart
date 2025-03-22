import 'package:flutter/material.dart';
import 'package:pfm/NavigationBar.dart';
import 'package:pfm/screen/Auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseurl = "http://127.0.0.1:8000";

class homescreen extends StatefulWidget {
  const homescreen({super.key});

  @override
  State<homescreen> createState() => _homescreenState();
}

class _homescreenState extends State<homescreen> {
  double totalEarnings = 0.0;
  double totalSpending = 0.0;
  List goals = [];
  List shifts = [];

  @override
  void initState() {
    super.initState();
    fetchFinancialData();
  }

  Future<void> fetchFinancialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      int? userId =
          prefs.getInt("id") ?? int.tryParse(prefs.getString("id") ?? "");

      final response =
          await http.get(Uri.parse('$baseurl/api/Homepage?id=$userId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          goals = data['goals'] ?? [];
          shifts = data['rota'] ?? [];

          totalEarnings = (data['TotalEarn'] as num?)?.toDouble() ?? 0.0;
          totalSpending = (data['Totalspending'] is num)
              ? (data['Totalspending'] as num).toDouble()
              : double.tryParse(data['Totalspending']?.toString() ?? "0.0") ??
                  0.0;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      bottomNavigationBar: NavigationBars("home"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 25),
                _buildFinancialOverview(),
                const SizedBox(height: 20),
                _buildUpcomingShifts(),
                const SizedBox(height: 20),
                _buildSavingsGoals(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialOverview() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Financial Overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFinancialCard('Earnings', '\£$totalEarnings',
                    Colors.green, FontAwesome5Solid.dollar_sign),
                _buildFinancialCard('Spending', '\£$totalSpending', Colors.red,
                    FontAwesome5Solid.shopping_cart),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCard(
      String title, String amount, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 5),
        Text(title, style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 5),
        Text(amount,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildSavingsGoals() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Savings Goals',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ...goals.map((goal) {
              double saved = (goal['saved_amount'] as num?)?.toDouble() ?? 0.0;
              double target = (goal['target_amount'] as num?)?.toDouble() ??
                  1.0; // Prevent division by zero
              return _buildSavingsProgress(
                  goal['name'] ?? 'Unnamed Goal', saved, target);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsProgress(String goal, double saved, double target) {
    double progress = saved / target;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(goal, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade300,
          color: Colors.green,
        ),
        const SizedBox(height: 5),
        Text('\$$saved of \$$target saved',
            style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildUpcomingShifts() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upcoming Shifts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ...shifts
                .map((shift) => _buildShiftCard(shift['Date'], shift['sTime'],
                    shift['eTime'], shift['Job_title']))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftCard(
      String date, String startTime, String endTime, String jobTitle) {
    return ListTile(
      leading:
          Icon(FontAwesome5Solid.calendar_alt, color: Colors.blue.shade700),
      title: Text('$jobTitle - $date',
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('$startTime - $endTime',
          style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back,',
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                ),
                const Text(
                  'Jay',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(FontAwesome.sign_out, color: Colors.red),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Logged out successfully"),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ],
    );
  }
}
