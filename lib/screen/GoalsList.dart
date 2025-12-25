import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:pfm/data/local/local_db.dart';
import 'package:pfm/data/models/goal.dart';
import 'package:pfm/screen/SetGoals.dart';
import 'package:pfm/screen/ViewGoal.dart';

class GoalsList extends StatefulWidget {
  const GoalsList({super.key});

  @override
  State<GoalsList> createState() => _GoalsListState();
}

class _GoalsListState extends State<GoalsList> {
  late final Stream<void> _goalsWatcher;

  @override
  void initState() {
    super.initState();
    _goalsWatcher = LocalDb.isar.goals.watchLazy();
  }

  Future<List<Goal>> _fetchGoals() {
    return LocalDb.isar.goals.where().findAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Goals'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: StreamBuilder<void>(
        stream: _goalsWatcher,
        builder: (_, __) {
          return FutureBuilder<List<Goal>>(
            future: _fetchGoals(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final goals = snapshot.data ?? [];

              if (goals.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  return _buildGoalCard(goals[index]);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SetGoals()),
          );
        },
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    final progress = goal.targetAmount > 0
        ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ViewGoal(goal: goal)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Deadline: ${goal.deadline.toLocal().toString().split(' ')[0]}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                color: Colors.blue,
                minHeight: 6,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '£${goal.savedAmount.toStringAsFixed(0)} saved',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.flag_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No goals yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            'Tap + to create your first goal',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
