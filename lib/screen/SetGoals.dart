import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('goalName', goalNameController.text);
    await prefs.setString('goalAmount', amountController.text);
    await prefs.setString('goalDate', selectedDate!.toIso8601String());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Goal saved successfully!"),
          backgroundColor: Colors.green),
    );

    Navigator.pop(context); // Go back to the previous screen
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
              decoration: InputDecoration(labelText: "Target Amount (\$)"),
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text(
                selectedDate == null
                    ? "Select Target Date"
                    : "Target Date: ${selectedDate!.toLocal()}".split(' ')[0],
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
