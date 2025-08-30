import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:pfm/screen/SetGoals.dart';
import 'package:pfm/screen/ViewGoal.dart';
import 'package:pfm/data/local/local_db.dart';
import 'package:pfm/data/models/goal.dart';

class GoalsList extends StatefulWidget {
  const GoalsList({super.key});

  @override
  _GoalsListState createState() => _GoalsListState();
}

class _GoalsListState extends State<GoalsList> {
  List<Goal> goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  /// Load goals from local DB
  Future<void> _loadGoals() async {
    final db = LocalDb.isar;

    // ✅ Use Isar query API
    final allGoals = await db.goals.where().findAll();

    setState(() {
      goals = allGoals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Goals",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: goals.isEmpty
          ? const Center(child: Text("No goals yet."))
          : ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final progress = goal.targetAmount > 0
                    ? (goal.savedAmount / goal.targetAmount) * 100
                    : 0.0;

                return Card(
                  child: ListTile(
                    title: Text(
                      goal.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Progress: ${progress.toStringAsFixed(1)}%"),
                        Text(
                          "Deadline: ${goal.deadline.toLocal().toString().split(' ')[0]}",
                        ),
                      ],
                    ),
                    trailing: Text(
                      "£${goal.savedAmount.toStringAsFixed(2)} / £${goal.targetAmount.toStringAsFixed(2)}",
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ViewGoal(goal as Map<String, dynamic>),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SetGoals()),
          );
          _loadGoals(); // Reload after adding a new goal
        },
      ),
    );
  }
}
