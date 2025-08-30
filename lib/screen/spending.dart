// File: lib/screen/Spending.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pfm/NavigationBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_slidable/flutter_slidable.dart';

const String baseurl = "http://127.0.0.1:8000";

class Spending extends StatefulWidget {
  const Spending({super.key});

  @override
  State<Spending> createState() => _SpendingState();
}

class _SpendingState extends State<Spending> {
  DateTime _selectedDay = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  int? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseurl/api/categorylist'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> categories = jsonResponse['data'];
        setState(() {
          _categories = categories.map((item) {
            final id = item['id'] is int
                ? item['id']
                : int.parse(item['id'].toString());
            return {
              'id': id,
              'name': item['name'].toString(),
            };
          }).toList();
        });
      }
    } catch (e) {
      print("Error fetching categories: $e");
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
              Expanded(child: _buildSpendingList()),
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
        _showDatePopup(selectedDay);
      },
    );
  }

  void _showDatePopup(DateTime selectedDate) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    _amountController.clear();
    _descriptionController.clear();
    _selectedCategoryId = null;

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
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter amount'
                    : null,
              ),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                items: _categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category['id'],
                    child: Text(category['name']),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategoryId = newValue;
                  });
                },
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter description'
                    : null,
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
                await _addSpending(formattedDate);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _addSpending(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');
    final data = {
      'amount': _amountController.text,
      'cat_id': _selectedCategoryId,
      'description': _descriptionController.text,
      'user_id': userId?.toString() ?? "",
      'date': date,
    };

    final response = await http.post(
      Uri.parse('$baseurl/api/newspendings'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context);
      _showSuccess('Spending created successfully! 🎉');
      setState(() {});
    } else {
      _showError('Failed to create spending');
    }
  }

  Future<List<dynamic>> _fetchSpendings() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id');
    final response = await http
        .get(Uri.parse('$baseurl/api/spendingslist?id=${userId ?? 0}'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['data'] as List<dynamic>;
    } else {
      return [];
    }
  }

  Widget _buildSpendingList() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchSpendings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No spendings found'));
        }
        final spendings = snapshot.data!;
        return ListView.builder(
          itemCount: spendings.length,
          itemBuilder: (context, index) {
            final spending = spendings[index];
            return _buildSpendingCard(spending);
          },
        );
      },
    );
  }

  Widget _buildSpendingCard(Map<String, dynamic> spending) {
    final date = spending['date'] ?? '';
    final formattedDate =
        DateFormat.yMMMMd().format(DateFormat('yyyy-MM-dd').parse(date));

    return Slidable(
      key: ValueKey(spending['id']),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _editSpending(spending['id']),
            backgroundColor: Colors.blue.shade50,
            foregroundColor: Colors.black,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) => _deleteSpending(spending['id']),
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
                Text("£ ${spending['amount']}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(formattedDate, style: const TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 5),
            Text(spending['description'] ?? '',
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Future<void> _editSpending(int spendingId) async {
    final response =
        await http.get(Uri.parse('$baseurl/api/spendingedit/$spendingId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      _amountController.text = data['amount'].toString();
      _descriptionController.text = data['description'];
      _selectedCategoryId = data['cat_id'];
      _showEditDialog(spendingId);
    } else {
      _showError('Failed to fetch spending details');
    }
  }

  void _showEditDialog(int spendingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Spending"),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter amount'
                    : null,
              ),
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                items: _categories.map((c) {
                  return DropdownMenuItem<int>(
                    value: c['id'],
                    child: Text(c['name']),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) =>
                    value == null ? 'Please select category' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter description'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () => _updateSpending(spendingId),
              child: const Text("Update")),
        ],
      ),
    );
  }

  Future<void> _updateSpending(int spendingId) async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'id': spendingId,
      'amount': _amountController.text,
      'cat_id': _selectedCategoryId,
      'description': _descriptionController.text,
    };

    final response = await http.post(
      Uri.parse('$baseurl/api/spendingsupdate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
      _showSuccess('Spending updated successfully! 🎉');
      setState(() {});
    } else {
      _showError('Failed to update spending');
    }
  }

  Future<void> _deleteSpending(int spendingId) async {
    final response =
        await http.get(Uri.parse('$baseurl/api/spendingsdeleted/$spendingId'));
    if (response.statusCode == 200) {
      _showSuccess('Spending deleted successfully! 🎉');
      setState(() {});
    } else {
      _showError('Failed to delete spending');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
