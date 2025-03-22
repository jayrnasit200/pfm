import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pfm/screen/Auth/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String baseurl = "http://127.0.0.1:8000";

class SetGoals extends StatefulWidget {
  @override
  _SetGoalsState createState() => _SetGoalsState();
}

class _SetGoalsState extends State<SetGoals> {
  TextEditingController goalNameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  DateTime? selectedDate;

  Future<void> _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveGoal() async {
    if (goalNameController.text.isEmpty ||
        amountController.text.isEmpty ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Please fill all fields"),
            backgroundColor: Colors.red),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();

    int? userId =
        prefs.getInt("id") ?? int.tryParse(prefs.getString("id") ?? "");

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("User ID not found"), backgroundColor: Colors.red),
      );
      return;
    }
    final url = Uri.parse("$baseurl/api/creategoals");
    final Map<String, dynamic> goalData = {
      "user_id": userId,
      "name": goalNameController.text,
      "target_amount": amountController.text,
      "deadline": selectedDate!.toIso8601String(),
    };
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(goalData),
      );

      if (response.statusCode == 201) {
        print(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Goal saved successfully!"),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to save goal"),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Set a Goal"), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: goalNameController,
              decoration: InputDecoration(labelText: "Goal Name"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: "Target Amount "),
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text(
                selectedDate == null
                    ? "Select Target Date"
                    : "Target Date: ${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}",
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _pickDate(context),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveGoal,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text("Save Goal", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
