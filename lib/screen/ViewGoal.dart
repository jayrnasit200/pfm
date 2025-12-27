import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pfm/data/models/goal.dart';
import 'package:pfm/data/local/local_db.dart';

class ViewGoal extends StatefulWidget {
  final Goal goal;

  const ViewGoal({super.key, required this.goal});

  @override
  State<ViewGoal> createState() => _ViewGoalState();
}

class _ViewGoalState extends State<ViewGoal> {
  late Goal goal;
  final Color primaryBlue = Colors.blue;

  @override
  void initState() {
    super.initState();
    goal = widget.goal;
  }

  /// ✅ ADD SAVINGS LOCALLY
  Future<void> _addSavings() async {
    final controller = TextEditingController();

    final amount = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Savings"),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: "Enter amount",
            prefixText: "£ ",
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () {
                final value = double.tryParse(controller.text.trim());
                Navigator.pop(context, value);
              },
              child: const Text("Add")),
        ],
      ),
    );

    if (amount == null || amount <= 0) return;

    final isar = LocalDb.isar;

    await isar.writeTxn(() async {
      goal.savedAmount += amount;
      await isar.goals.put(goal);
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildMainCard(percentLabel, progressRatio),
            const SizedBox(height: 35),
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
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _addSavings,
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

  Widget _buildMainCard(String percent, double ratio) {
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
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 25),
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
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text("$percent% Achieved",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
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
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
