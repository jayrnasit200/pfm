import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:pfm/NavigationBar.dart';
import 'package:pfm/screen/Auth/Login.dart';
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
  List<Job> shifts = [];
  String userName = "User";

  final Color primaryBlue = Colors.blue;

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  Future<void> _loadFinancialData() async {
    final db = LocalDb.isar;
    final prefs = await SharedPreferences.getInstance();

    final allGoals = await db.goals.where().findAll();
    final allShifts = (await db.jobs.where().findAll()).cast<Job>();
    final allEarnings = await db.earnings.where().findAll();

    double earningsSum = allEarnings.fold(0.0, (sum, e) => sum + e.amount);

    setState(() {
      userName = prefs.getString('name') ?? "User";
      goals = allGoals;
      shifts = allShifts.cast<Job>();
      totalEarnings = earningsSum;
      totalSpending = 0.0; // Update this logic as your spending model grows
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBars("home"),
      body: CustomScrollView(
        slivers: [
          // Elegant Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 60, 25, 20),
              child: _buildHeader(),
            ),
          ),

          // Main Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMainBalanceCard(),
                const SizedBox(height: 25),
                _buildSectionHeader("Savings Goals", Icons.savings_outlined),
                const SizedBox(height: 12),
                _buildSavingsGoals(),
                const SizedBox(height: 25),
                _buildSectionHeader(
                    "Upcoming Shifts", Icons.calendar_today_outlined),
                const SizedBox(height: 12),
                _buildUpcomingShifts(),
                const SizedBox(height: 100), // Bottom padding for FAB/Nav
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back,',
                style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            Text(userName,
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue.withOpacity(0.9))),
          ],
        ),
        GestureDetector(
          onTap: _handleLogout,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Feather.log_out, color: Colors.redAccent, size: 20),
          ),
        )
      ],
    );
  }

  Widget _buildMainBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue.withOpacity(0.9), primaryBlue.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          const Text("Total Earnings",
              style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text("£${totalEarnings.toStringAsFixed(2)}",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              _balanceMiniStat("Income", totalEarnings, Icons.arrow_upward),
              Container(width: 1, height: 30, color: Colors.white24),
              _balanceMiniStat("Spending", totalSpending, Icons.arrow_downward),
            ],
          )
        ],
      ),
    );
  }

  Widget _balanceMiniStat(String label, double amount, IconData icon) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white60, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white60, fontSize: 12)),
              Text("£${amount.toStringAsFixed(0)}",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: primaryBlue),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSavingsGoals() {
    if (goals.isEmpty) return _emptyState("No goals set yet");
    return Column(
      children: goals.map((goal) => _buildGoalItem(goal)).toList(),
    );
  }

  Widget _buildGoalItem(Goal goal) {
    double progress =
        (goal.savedAmount / (goal.targetAmount == 0 ? 1 : goal.targetAmount))
            .clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryBlue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(goal.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text("${(progress * 100).toInt()}%",
                  style: TextStyle(
                      color: primaryBlue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor:
                  AlwaysStoppedAnimation<Color>(primaryBlue.withOpacity(0.7)),
            ),
          ),
          const SizedBox(height: 8),
          Text("£${goal.savedAmount} of £${goal.targetAmount}",
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildUpcomingShifts() {
    if (shifts.isEmpty) return _emptyState("No shifts scheduled");
    return Column(
      children: shifts.map((shift) => _buildShiftItem(shift)).toList(),
    );
  }

  Widget _buildShiftItem(Job shift) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              Icon(MaterialCommunityIcons.calendar_clock, color: primaryBlue),
        ),
        title: Text(shift.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${shift.date} • ${shift.startTime} - ${shift.endTime}"),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
          child: Text(message, style: const TextStyle(color: Colors.grey))),
    );
  }

  Future<void> _handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }
}
