// import 'package:flutter/material.dart';
// import 'package:pfm/NavigationBar.dart';

// class earning extends StatefulWidget {
//   const earning({super.key});

//   @override
//   State<earning> createState() => _earningState();
// }

// class _earningState extends State<earning> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.lightBlue,
//       bottomNavigationBar: NavigationBars("earning"),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               'earning ',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pfm/NavigationBar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // For date formatting

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
      bottomNavigationBar: NavigationBars("earning"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildCalendar(),
              const SizedBox(height: 20),
              _buildHealthStats(),
            ],
          ),
        ),
      ),
    );
  }

  /// **Builds the Calendar Widget**
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

  /// **Shows the Popup with Date and Input Field**
  void _showDatePopup(BuildContext context, DateTime selectedDate) {
    TextEditingController _amountController = TextEditingController();
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Enter earning Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// **Date Label**
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Selected Date: $formattedDate",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            /// **Text Field for Amount**
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
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
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              String amount = _amountController.text;
              if (amount.isNotEmpty) {
                print("Amount entered for $formattedDate: $amount");
              }
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  /// **Dummy Health Stats Widget**
  Widget _buildHealthStats() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard('Heart Rate', '24.32 bpm',
              'Monitoring Hearts, One Beat at a Time.'),
          _buildStatCard('Steps', '1024', 'Keeping you active and on track.'),
          _buildStatCard(
              'Calories', '230 kcal', 'Burning energy for a better you.'),
          _buildStatCard('Sleep', '7 hrs', 'Ensuring your restful nights.'),
          _buildStatCard(
              'Calories', '230 kcal', 'Burning energy for a better you.'),
          _buildStatCard(
              'Calories', '230 kcal', 'Burning energy for a better you.'),
        ],
      ),
    );
  }

  /// **Reusable Card Widget**
  Widget _buildStatCard(String title, String value, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('View Details', style: TextStyle(color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 5),
          Text(subtitle, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
