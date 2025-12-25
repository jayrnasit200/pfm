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
  // Calendar State
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat =
      CalendarFormat.month; // Handles expand/collapse

  // Form State
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  int? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];

  final Color primaryBlue = Colors.blue;

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
            return {
              'id': item['id'] is int
                  ? item['id']
                  : int.parse(item['id'].toString()),
              'name': item['name'].toString(),
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const NavigationBars("Spending"),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
              child: Text(
                "Spending Tracker",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue.withOpacity(0.9)),
              ),
            ),

            // Expandable Calendar Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _buildCalendar(),
              ),
            ),

            const SizedBox(height: 20),

            // List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Transactions",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(DateFormat('MMMM yyyy').format(_selectedDay),
                      style: TextStyle(
                          color: primaryBlue, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Scrollable List Area
            Expanded(child: _buildSpendingList()),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _selectedDay,

      // LOGIC: These three lines enable the scroll up/down to see less/more
      calendarFormat: _calendarFormat,
      onFormatChanged: (format) => setState(() => _calendarFormat = format),
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
        CalendarFormat.twoWeeks: 'Compact',
      },

      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() => _selectedDay = selectedDay);
        _showSpendingForm(selectedDay);
      },

      // Styling
      calendarStyle: CalendarStyle(
        selectedDecoration:
            BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
        todayDecoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.3), shape: BoxShape.circle),
        markerDecoration:
            BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonDecoration: BoxDecoration(
          color: primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        formatButtonTextStyle:
            TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showSpendingForm(DateTime selectedDate,
      {Map<String, dynamic>? existingSpending}) {
    final bool isEdit = existingSpending != null;
    if (isEdit) {
      _amountController.text = existingSpending['amount'].toString();
      _descriptionController.text = existingSpending['description'] ?? '';
      _selectedCategoryId = existingSpending['cat_id'];
    } else {
      _amountController.clear();
      _descriptionController.clear();
      _selectedCategoryId = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 25,
            right: 25,
            top: 25),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text(isEdit ? "Edit Transaction" : "New Transaction",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildModernField(_amountController, "Amount (£)",
                  Icons.attach_money_rounded, TextInputType.number),
              const SizedBox(height: 15),
              _buildCategoryDropdown(),
              const SizedBox(height: 15),
              _buildModernField(_descriptionController, "Description",
                  Icons.description_outlined, TextInputType.text,
                  maxLines: 2),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => isEdit
                      ? _updateSpending(existingSpending['id'])
                      : _addSpending(
                          DateFormat('yyyy-MM-dd').format(selectedDate)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: Text(isEdit ? "UPDATE" : "SAVE TRANSACTION",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernField(TextEditingController controller, String label,
      IconData icon, TextInputType type,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryBlue.withOpacity(0.5)),
        filled: true,
        fillColor: primaryBlue.withOpacity(0.05),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
      ),
      validator: (v) => v!.isEmpty ? "Required" : null,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      items: _categories
          .map((c) =>
              DropdownMenuItem<int>(value: c['id'], child: Text(c['name'])))
          .toList(),
      onChanged: (v) => setState(() => _selectedCategoryId = v),
      decoration: InputDecoration(
        labelText: "Category",
        prefixIcon:
            Icon(Icons.category_outlined, color: primaryBlue.withOpacity(0.5)),
        filled: true,
        fillColor: primaryBlue.withOpacity(0.05),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
      ),
      validator: (v) => v == null ? "Select Category" : null,
    );
  }

  Widget _buildSpendingList() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchSpendings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return _buildEmptyState();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) =>
              _buildSpendingCard(snapshot.data![index]),
        );
      },
    );
  }

  Widget _buildSpendingCard(Map<String, dynamic> spending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) =>
                  _showSpendingForm(_selectedDay, existingSpending: spending),
              backgroundColor: primaryBlue.withOpacity(0.1),
              foregroundColor: primaryBlue,
              icon: Icons.edit,
              borderRadius: BorderRadius.circular(15),
            ),
            SlidableAction(
              onPressed: (_) => _deleteSpending(spending['id']),
              backgroundColor: Colors.redAccent.withOpacity(0.1),
              foregroundColor: Colors.redAccent,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(15),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.shopping_bag_outlined,
                    color: Colors.redAccent),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(spending['description'] ?? 'Spending',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(spending['date'] ?? '',
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              Text("- £${spending['amount']}",
                  style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  // --- API Logic ---

  Future<void> _addSpending(String date) async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'amount': _amountController.text,
      'cat_id': _selectedCategoryId,
      'description': _descriptionController.text,
      'user_id': prefs.getInt('id').toString(),
      'date': date,
    };
    final res = await http.post(Uri.parse('$baseurl/api/newspendings'),
        headers: {'Content-Type': 'application/json'}, body: json.encode(data));
    if (res.statusCode == 200 || res.statusCode == 201) {
      Navigator.pop(context);
      _showSuccess('Spending saved! 🎉');
      setState(() {});
    }
  }

  Future<void> _updateSpending(int id) async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'id': id,
      'amount': _amountController.text,
      'cat_id': _selectedCategoryId,
      'description': _descriptionController.text
    };
    final res = await http.post(Uri.parse('$baseurl/api/spendingsupdate'),
        headers: {'Content-Type': 'application/json'}, body: json.encode(data));
    if (res.statusCode == 200) {
      Navigator.pop(context);
      _showSuccess('Updated! 🎉');
      setState(() {});
    }
  }

  Future<void> _deleteSpending(int id) async {
    final res = await http.get(Uri.parse('$baseurl/api/spendingsdeleted/$id'));
    if (res.statusCode == 200) {
      _showSuccess('Deleted!');
      setState(() {});
    }
  }

  Future<List<dynamic>> _fetchSpendings() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    final res =
        await http.get(Uri.parse('$baseurl/api/spendingslist?id=${id ?? 0}'));
    return res.statusCode == 200 ? json.decode(res.body)['data'] : [];
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey[200]),
          const SizedBox(height: 10),
          const Text("No transactions recorded",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showSuccess(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating));
}
