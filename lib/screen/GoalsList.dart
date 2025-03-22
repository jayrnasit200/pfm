import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pfm/screen/SetGoals.dart';
import 'package:pfm/screen/ViewGoal.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:pfm/screen/ViewGoal.dart';
const String baseurl = "http://127.0.0.1:8000";

class GoalsList extends StatefulWidget {
  @override
  _GoalsListState createState() => _GoalsListState();
}

class _GoalsListState extends State<GoalsList> {
  List<dynamic> goals = [];

  @override
  void initState() {
    super.initState();
    fetchGoals();
  }

  Future<void> fetchGoals() async {
    final prefs = await SharedPreferences.getInstance();
    var userid = prefs.getInt('id');
    final url = Uri.parse("$baseurl/api/lsitgoals?id=$userid");
    try {
      final response =
          await http.get(url, headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        setState(() {
          goals = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print("Error fetching goals: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Goals",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue),
      body: goals.isEmpty
          ? Center(child: Text("No goals yet."))
          : ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                var goal = goals[index];
                double progress =
                    (goal["saved_amount"] / goal["target_amount"]) * 100;

                return Card(
                  child: ListTile(
                    title: Text(goal["name"],
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Progress: ${progress.toStringAsFixed(1)}%"),
                        Text("Deadline: ${goal["deadline"]}"),
                      ],
                    ),
                    trailing: Text(
                        "£${goal["saved_amount"]} / £${goal["target_amount"]}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewGoal(goal),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SetGoals()),
          );
        },
      ),
    );
  }
}
