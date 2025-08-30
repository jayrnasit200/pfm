import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

const String baseurl = "http://127.0.0.1:8000";

class ViewGoal extends StatefulWidget {
  final Map<String, dynamic> goal;
  ViewGoal(this.goal);

  @override
  _ViewGoalState createState() => _ViewGoalState();
}

class _ViewGoalState extends State<ViewGoal> {
  late Map<String, dynamic> goal;
  List<dynamic> transactions = [];

  @override
  void initState() {
    super.initState();
    goal = widget.goal;
    _fetchTransactions();
  }

  // Fetch transactions related to this goal
  Future<void> _fetchTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseurl/api/goalcontrilist?id=${goal["id"]}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() {
          transactions = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch transactions.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Edit goal dialog
  Future<void> _editGoal(BuildContext context) async {
    final nameController = TextEditingController(text: goal["name"]);
    final targetController =
        TextEditingController(text: goal["target_amount"].toString());
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Goal"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Goal Name"),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a name' : null,
              ),
              TextFormField(
                controller: targetController,
                decoration: InputDecoration(labelText: "Target Amount (£)"),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                        ? 'Enter a valid number'
                        : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel")),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                try {
                  final response = await http.post(
                    Uri.parse('$baseurl/api/goalupdate'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'id': goal["id"],
                      'name': nameController.text,
                      'target_amount': double.parse(targetController.text),
                    }),
                  );
                  if (response.statusCode == 200) {
                    setState(() {
                      goal["name"] = nameController.text;
                      goal["target_amount"] =
                          double.parse(targetController.text);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Goal updated successfully')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update goal.')));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Error: $e')));
                }
                Navigator.of(context).pop();
              }
            },
            child: Text("Save Changes"),
          ),
        ],
      ),
    );
  }

  // Add transaction dialog
  Future<void> _addTransaction(BuildContext context) async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final dateController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    Future<void> _selectDate() async {
      DateTime selectedDate = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Transaction"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: amountController,
                decoration: InputDecoration(labelText: "Amount (£)"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  if (double.tryParse(value) == null)
                    return 'Enter valid number';
                  return null;
                },
              ),
              TextFormField(
                controller: noteController,
                decoration: InputDecoration(labelText: "Note"),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter note' : null,
              ),
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: dateController,
                    decoration: InputDecoration(labelText: "Date (YYYY-MM-DD)"),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Select date' : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel")),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                try {
                  final response = await http.post(
                    Uri.parse('$baseurl/api/goalcontri'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'goal_id': goal["id"],
                      'amount': amountController.text,
                      'note': noteController.text,
                      'date': dateController.text,
                    }),
                  );
                  if (response.statusCode == 200) {
                    setState(() {
                      goal["saved_amount"] +=
                          double.parse(amountController.text);
                    });
                    _fetchTransactions();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Transaction added successfully')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add transaction.')));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Error: $e')));
                }
                Navigator.of(context).pop();
              }
            },
            child: Text("Add Transaction"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = goal["saved_amount"] / goal["target_amount"].toDouble();
    double remaining =
        goal["target_amount"].toDouble() - goal["saved_amount"].toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(goal["name"]),
        actions: [
          IconButton(
              icon: Icon(Icons.edit), onPressed: () => _editGoal(context)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal Summary Card
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Target: £${goal["target_amount"]}"),
                    Text("Saved: £${goal["saved_amount"]}"),
                    Text("Remaining: £${remaining.toStringAsFixed(2)}"),
                    SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 5),
                    Text("${(progress * 100).toStringAsFixed(1)}%"),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text("Transactions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final t = transactions[index];
                  return Card(
                    child: ListTile(
                      title: Text("£${t["amount"]}"),
                      subtitle:
                          Text("Date: ${t["date"]} | Note: ${t["notes"]}"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addTransaction(context),
      ),
    );
  }
}
