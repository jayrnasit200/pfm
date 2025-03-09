import 'package:flutter/material.dart';
import 'package:pfm/NavigationBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_slidable/flutter_slidable.dart';

class Spending extends StatefulWidget {
  const Spending({super.key});

  @override
  State<Spending> createState() => _SpendingState();
}

class _SpendingState extends State<Spending> {
  DateTime _selectedDay = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  // Declare _selectedCategoryId as int?
  int? _selectedCategoryId;

  // Store categories as a list of maps.
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/api/categorylist'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> categories = jsonResponse['date'];
      setState(() {
        _descriptionController.text = "";
        _amountController.text = "";
        _selectedCategoryId = null;
        _categories = categories.map((item) {
          // Ensure that the id is treated as an int.
          final id =
              item['id'] is int ? item['id'] : int.parse(item['id'].toString());
          return {
            'id': id,
            'name': item['name'].toString(),
          };
        }).toList();
      });
    } else {
      // Handle error appropriately.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBars("Spending"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalendar(),
              const SizedBox(height: 20),
              Expanded(child: _buildHealthStats()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _selectedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
        });
        _showDatePopup(context, selectedDay);
      },
    );
  }

  void _showDatePopup(BuildContext context, DateTime selectedDate) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Spending Details"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                items: _categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category['id'],
                    child: Text(category['name'].toString()),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedCategoryId = newValue;
                  });
                },
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // Prepare the data for the API.
                final amount = _amountController.text;
                final description = _descriptionController.text;
                final categoryId = _selectedCategoryId;
                final prefs = await SharedPreferences.getInstance();
                // Use getInt instead of getString since the id was stored as int.
                final userId = prefs.getInt('id');
                // Build the data object.
                final data = {
                  'amount': amount,
                  'category_id': categoryId,
                  'description': description,
                  'user_id': userId?.toString() ?? "",
                  'date': formattedDate,
                };
                // Print data to debug.
                print("Data to send: $data");
                // Send data to your API.
                final response = await http.post(
                  Uri.parse('http://127.0.0.1:8000/api/newspendings'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(data),
                );
                if (response.statusCode == 200) {
                  // Successfully sent
                  // print("Data sent successfully!");
                  Navigator.pushReplacement(
                    context,
                    // MaterialPageRoute(builder: (context) => const Spending()),
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          Spending(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                } else {
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        Spending(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  );
                  print("Error sending data: ${response.statusCode}");
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>> _fetchSpendingsList() async {
    final prefs = await SharedPreferences.getInstance();
    var url = 'http://127.0.0.1:8000/api/spendingslist?id=' +
        prefs.getInt('id').toString();
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      // Assuming your API returns a JSON object with a key 'data' containing the list.
      return jsonResponse['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to load spendings');
    }
  }

  Widget _buildHealthStats() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchSpendingsList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No spendings found'));
        } else {
          final spendings = snapshot.data!;
          // Build a ListView using the fetched spendings.
          return ListView.builder(
            itemCount: spendings.length,
            itemBuilder: (context, index) {
              final spending = spendings[index];
              // Adjust field names as per your API response.
              return _buildStatCard(
                spending['amount']?.toString() ?? 'amount',
                spending['description']?.toString() ?? 'description',
                spending['Date']?.toString() ?? 'date',
                index,
                spendings,
              );
            },
          );
        }
      },
    );
  }

  Widget _buildStatCard(String amount, String value, String date, int index,
      List<dynamic> spendings) {
    return Slidable(
      key: ValueKey(spendings[index]['id']), // Unique key for each item
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => print('More options tapped'),
            backgroundColor: Colors.blue.shade50,
            foregroundColor: Colors.black,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) async {
              final spendingId = spendings[index]['id'];
              spendings.removeAt(index);

              final response = await http.delete(
                Uri.parse('http://127.0.0.1:8000/api/spendings/$spendingId'),
              );

              if (response.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Spending deleted')),
                );
                setState(() {}); // Refresh UI
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete spending')),
                );
              }
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("£ " + amount,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                    DateFormat.yMMMMd()
                        .format(DateFormat("yyyy-MM-dd").parse(date)),
                    style: const TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
