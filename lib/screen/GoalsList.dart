import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:FINEXA/data/local/local_db.dart';
import 'package:FINEXA/data/models/goal.dart';
import 'package:FINEXA/screen/SetGoals.dart';
import 'package:FINEXA/screen/ViewGoal.dart';

/// 🔹 CHANGE BASE URL HERE ONLY
const String BASE_URL = 'http://127.0.0.1:8000/api';

class GoalsList extends StatefulWidget {
  const GoalsList({super.key});

  @override
  State<GoalsList> createState() => _GoalsListState();
}

class _GoalsListState extends State<GoalsList> {
  // 1. Fixed: Nullable stream to avoid LateInitializationError
  Stream<List<Goal>>? _goalsStream;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    // 2. Initialize the stream from Isar immediately
    _goalsStream = LocalDb.isar.goals.where().watch(fireImmediately: true);

    // 3. Trigger the network sync
    _syncGoalsFromApi();
  }

  /// 🔹 API SYNC (USER BASED)
  Future<void> _syncGoalsFromApi() async {
    if (_syncing) return;
    if (mounted) setState(() => _syncing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final int userId = prefs.getInt('user_id') ?? 0;
      if (userId == 0) return;

      final url = Uri.parse('$BASE_URL/lsitgoals?id=$userId');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        final goals = data.map<Goal>((json) {
          return Goal(
            // id: json['id'], // Ensure your model uses the remote ID as Isar @Id
            name: json['name'] ?? 'Unnamed Goal',
            targetAmount:
                double.tryParse(json['target_amount'].toString()) ?? 0,
            savedAmount:
                double.tryParse(json['saved_amount']?.toString() ?? '0') ?? 0,
            deadline:
                DateTime.tryParse(json['deadline'] ?? '') ?? DateTime.now(),
          );
        }).toList();

        // UPSERT to Isar (Transaction)
        await LocalDb.isar.writeTxn(() async {
          await LocalDb.isar.goals.putAll(goals);
        });
      }
    } catch (e) {
      debugPrint('Goal sync error: $e');
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 4. Safety Check: If stream isn't ready, show loader
    if (_goalsStream == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text(
          'Financial Goals',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          _syncing
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.blue),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.blue),
                  onPressed: _syncGoalsFromApi,
                ),
        ],
      ),
      body: StreamBuilder<List<Goal>>(
        stream: _goalsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading goals: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final goals = snapshot.data!;

          if (goals.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: goals.length,
            itemBuilder: (_, i) => _buildGoalCard(goals[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SetGoals()),
          );
        },
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text('Add New Goal',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    final progress = goal.targetAmount > 0
        ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ViewGoal(goal: goal)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      goal.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.blueAccent,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade100,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SAVED',
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                              letterSpacing: 1)),
                      Text('£${goal.savedAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('DEADLINE',
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                              letterSpacing: 1)),
                      Text(goal.deadline.toLocal().toString().split(' ')[0],
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
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
        children: [
          Icon(Icons.rocket_launch_rounded,
              size: 80, color: Colors.blue.withOpacity(0.2)),
          const SizedBox(height: 20),
          const Text('No goals yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Create your first savings goal to track\nyour financial progress here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }
}
