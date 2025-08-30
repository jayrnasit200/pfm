import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:pfm/NavigationBar.dart';
// ignore: library_prefixes
import 'package:pfm/screen/Auth/login.dart';
import 'package:pfm/data/local/local_db.dart';
import 'package:pfm/data/models/goal.dart';
import 'package:pfm/data/models/earning.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:pfm/data/models/job.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double totalEarnings = 0.0;
  double totalSpending = 0.0;
  List<Goal> goals = [];
  // List<Job> shifts = [];
  List<job> shifts = [];

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  /// Load all financial data from local DB
  Future<void> _loadFinancialData() async {
    final db = LocalDb.isar;

    // Load goals
    final allGoals = await db.goals.where().findAll();

    // Load shifts/jobs
    final allShifts = await db.jobs.where().findAll();

    // Load earnings
    final allEarnings = await db.earnings.where().findAll();
    double earningsSum = allEarnings.fold(0.0, (sum, e) => sum + e.amount);

    double spendingSum = 0.0; // Update if you have a spending collection

    setState(() {
      goals = allGoals;
      // shifts = allShifts.cast<JobModel1.job>();
      shifts = allShifts.cast<job>();

      totalEarnings = earningsSum;
      totalSpending = spendingSum;
    });
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
                _buildFinancialCard('Earnings', '£$totalEarnings', Colors.green,
                    FontAwesome5Solid.dollar_sign),
                _buildFinancialCard('Spending', '£$totalSpending', Colors.red,
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
              double saved = goal.savedAmount;
              double target = goal.targetAmount;
              return _buildSavingsProgress(goal.name, saved, target);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsProgress(String goal, double saved, double target) {
    double progress = saved / (target == 0 ? 1 : target);
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
        Text('£$saved of £$target saved',
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
            const Text(
              'Upcoming Shifts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ...shifts.map((shift) {
              final jobShift = shift as job;
              final date = jobShift.date?.toString() ?? '';
              final startTime = jobShift.startTime ?? '';
              final endTime = jobShift.endTime ?? '';
              final title = jobShift.title;
              ;

              return _buildShiftCard(date, startTime, endTime, title);
            }).toList(),
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
              children: const [
                Text('Welcome Back,',
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
                Text('Jay',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue)),
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
              const SnackBar(
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
