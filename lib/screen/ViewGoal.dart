import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert'; // For encoding the data into JSON

const String baseurl = "http://127.0.0.1:8000";

class ViewGoal extends StatefulWidget {
  final Map<String, dynamic> goal;

  ViewGoal(this.goal);

  @override
  _ViewGoalState createState() => _ViewGoalState();
}

class _ViewGoalState extends State<ViewGoal> {
  late Map<String, dynamic> goal;
  List<dynamic> transactions = []; // List to hold the transaction data

  @override
  void initState() {
    super.initState();
    goal = widget.goal; // Initialize goal from widget
    _fetchTransactions(); // Fetch transactions when the page loads
  }

  // Fetch transactions from the API
  Future<void> _fetchTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseurl/api/goalcontrilist?id=${goal["id"]}'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );
      // print(response.body);
      if (response.statusCode == 200) {
        //  ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text("Goals Contribution saved successfully"),
        //     backgroundColor: Colors.green,
        //   ),
        // );
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

  Future<void> _addTransaction(BuildContext context) async {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    // Function to show date picker and set the date to the text field
    Future<void> _selectDate(BuildContext context) async {
      DateTime selectedDate = DateTime.now();

      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (picked != null && picked != selectedDate) {
        selectedDate = picked;
        dateController.text = "${selectedDate.toLocal()}"
            .split(' ')[0]; // Formats the date to YYYY-MM-DD
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: noteController,
                  decoration: InputDecoration(labelText: "Note"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a note';
                    }
                    return null;
                  },
                ),
                GestureDetector(
                  onTap: () =>
                      _selectDate(context), // Trigger date picker on tap
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: dateController,
                      decoration:
                          InputDecoration(labelText: "Date (YYYY-MM-DD)"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  // Extract input data
                  String amount = amountController.text;
                  String note = noteController.text;
                  String date = dateController.text;

                  // Send POST request
                  try {
                    final response = await http.post(
                      Uri.parse('$baseurl/api/goalcontri'),
                      headers: <String, String>{
                        'Content-Type': 'application/json',
                      },
                      body: jsonEncode({
                        'goal_id':
                            goal["id"], // Assuming goal has an 'id' field
                        'amount': amount,
                        'note': note,
                        'date': date,
                      }),
                    );
                    // print(response.body);
                    if (response.statusCode == 200) {
                      // Successfully added transaction, update the state
                      setState(() {
                        goal["saved_amount"] += double.parse(amount);
                      });

                      // Refresh the transactions list after adding a new one
                      _fetchTransactions();

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Transaction added successfully')));
                    } else {
                      // Handle error
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Failed to add transaction.')));
                    }
                  } catch (e) {
                    // Handle error
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error: $e')));
                  }

                  Navigator.of(context).pop();
                }
              },
              child: Text("Add Transaction"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = (goal["saved_amount"] / goal["target_amount"]) * 100;
    double remaining =
        goal["target_amount"].toDouble() - goal["saved_amount"].toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          goal["name"],
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal Summary
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    12), // Slightly reduced border radius for a smaller card
              ),
              shadowColor: Colors.blueAccent.withOpacity(0.2), // Soft shadow
              child: Padding(
                padding: const EdgeInsets.all(
                    12.0), // Reduced padding to decrease height
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Target Amount",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          "Saved Amount",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    // Title: Target Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Target Amount
                        Text(
                          "£${goal["target_amount"]}",
                          style: TextStyle(
                            fontSize: 20, // Slightly smaller font size
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        // Saved Amount
                        Text(
                          "£${goal["saved_amount"]}",
                          style: TextStyle(
                            fontSize: 20, // Slightly smaller font size
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8), // Reduced height between sections

                    // Title: Remaining Amount
                    Text(
                      "Remaining",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      "£${remaining.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 20, // Slightly smaller font size
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 16), // Reduced height between sections

                    // Progress Bar
                    LinearProgressIndicator(
                      value: progress / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                    SizedBox(height: 8),

                    // Progress Percentage
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Progress",
                          style: TextStyle(
                            fontSize:
                                16, // Reduced font size for the progress label
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          "${progress.toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize:
                                16, // Reduced font size for the progress percentage
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            SizedBox(height: 20),

            // List of Entries
            Text("Transactions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: transactions
                    .length, // Use the length of the transactions list
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        "Amount: £${transaction["amount"]}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Date: ${transaction["date"]}"),
                          Text("Note: ${transaction["notes"]}"),
                        ],
                      ),
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
        onPressed: () => _addTransaction(
            context), // Open the dialog when + button is pressed
      ),
    );
  }
}
