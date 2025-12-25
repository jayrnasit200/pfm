import 'package:flutter/material.dart';
import 'package:pfm/data/models/goal.dart';
import 'package:intl/intl.dart';

class ViewGoal extends StatelessWidget {
  final Goal goal;

  const ViewGoal({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = Colors.blue;

    // Calculate progress for the UI
    final double progressRatio = goal.targetAmount > 0
        ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final String percentLabel = (progressRatio * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: const Text("Goal Details",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // Add edit logic here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 1. Top Card with Main Stats
            _buildMainCard(primaryBlue, percentLabel, progressRatio),

            const SizedBox(height: 35),

            // 2. Goal Information Section
            const Text("Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            _buildInfoTile(
              icon: Icons.calendar_today_rounded,
              label: "Target Date",
              value: DateFormat('MMMM dd, yyyy').format(goal.deadline),
              color: Colors.orange,
            ),
            _buildInfoTile(
              icon: Icons.flag_rounded,
              label: "Goal Purpose",
              value: goal.name,
              color: Colors.green,
            ),
            _buildInfoTile(
              icon: Icons.hourglass_empty_rounded,
              label: "Remaining Amount",
              value:
                  "£${(goal.targetAmount - goal.savedAmount).toStringAsFixed(2)}",
              color: primaryBlue,
            ),

            const SizedBox(height: 40),

            // 3. Action Button (To be linked to your Savings API)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Logic to add savings
                },
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                label: const Text("ADD SAVINGS",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard(Color primaryBlue, String percent, double ratio) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: primaryBlue.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            "£${goal.savedAmount.toStringAsFixed(2)}",
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: primaryBlue),
          ),
          Text(
            "of £${goal.targetAmount.toStringAsFixed(2)} goal",
            style:
                TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 25),

          // Large Progress Bar
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text("$percent% Achieved",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryBlue.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
      {required IconData icon,
      required String label,
      required String value,
      required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}
