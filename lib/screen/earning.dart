import 'package:flutter/material.dart';
import 'package:pfm/NavigationBar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class earning extends StatefulWidget {
  const earning({super.key});

  @override
  State<earning> createState() => _earningState();
}

class _earningState extends State<earning> {
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBars("Earning"),
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
    TextEditingController _amountController = TextEditingController();
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Earning Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Selected Date: $formattedDate",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: "Enter Amount",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              String amount = _amountController.text;
              if (amount.isNotEmpty) {
                print("Amount entered for $formattedDate: $amount");
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStats() {
    return ListView(
      children: [
        _buildStatCard('Heart Rate', '72 bpm', 'Monitoring your heartbeat.'),
        _buildStatCard('Steps', '10,500', 'Keeping you active every day.'),
        _buildStatCard('Calories', '550 kcal', 'Tracking your daily burn.'),
        _buildStatCard('Sleep', '8 hrs', 'Ensuring restful nights.'),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle) {
    return Container(
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
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const Text('View Details', style: TextStyle(color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
