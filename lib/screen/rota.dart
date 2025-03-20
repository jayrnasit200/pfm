import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class rotaScreen extends StatefulWidget {
  final int id;
  rotaScreen(this.id);

  @override
  _rotaScreenState createState() => _rotaScreenState();
}

class _rotaScreenState extends State<rotaScreen> {
  late DateTime selectedWeekStart;
  final List<String> dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  late Map<String, TimeOfDay> shiftStartTimes;
  late Map<String, TimeOfDay> shiftEndTimes;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    // Set to the Monday of the current week
    selectedWeekStart = now.subtract(Duration(days: now.weekday - 1));
    initializeWeekData();

    print("Received ID: ${widget.id}");
  }

  // Initialize shift times for each day to default values (00:00)
  void initializeWeekData() {
    shiftStartTimes = {
      for (var day in dayNames) day: TimeOfDay(hour: 0, minute: 0),
    };
    shiftEndTimes = {
      for (var day in dayNames) day: TimeOfDay(hour: 0, minute: 0),
    };
  }

  // Function to change the displayed week
  void _changeWeek(int days) {
    setState(() {
      selectedWeekStart = selectedWeekStart.add(Duration(days: days));
      // Optionally reinitialize the shift times for the new week
      initializeWeekData();
    });
  }

  // Show time picker to select shift times
  Future<void> _selectTime(
      BuildContext context, String day, bool isStartTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? shiftStartTimes[day]! : shiftEndTimes[day]!,
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          shiftStartTimes[day] = pickedTime;
        } else {
          if (pickedTime.hour < shiftStartTimes[day]!.hour ||
              (pickedTime.hour == shiftStartTimes[day]!.hour &&
                  pickedTime.minute <= shiftStartTimes[day]!.minute)) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("End time must be later than start time")));
          } else {
            shiftEndTimes[day] = pickedTime;
          }
        }
      });
    }
  }

  // Format TimeOfDay to a readable string
  String _formatTimeOfDay(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  // Send only the data for the currently displayed week
  Future<void> _saveRota() async {
    List<Map<String, dynamic>> rotaData = dayNames.map((day) {
      return {
        "date": selectedWeekStart
            .add(Duration(days: dayNames.indexOf(day)))
            .toIso8601String()
            .split('T')[0],
        "start_time": _formatTimeOfDay(shiftStartTimes[day]!),
        "end_time": _formatTimeOfDay(shiftEndTimes[day]!),
        "job": widget.id.toString(),
      };
    }).toList();

    try {
      // print("Sending Data for ID: ${widget.id}");
      // print(jsonEncode({"rota": rotaData}));
      var response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/jobrota"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"rota": rotaData}), // Use jsonEncode
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Rota saved successfully!")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to save rota")));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Week Rota", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      // Wrap the body in a GestureDetector to detect horizontal swipes
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              // Swipe left to go to the next week
              _changeWeek(7);
            } else if (details.primaryVelocity! > 0) {
              // Swipe right to go to the previous week
              _changeWeek(-7);
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header row with arrow buttons and week start display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => _changeWeek(-7),
                  ),
                  Text(
                    "Week Starting: ${selectedWeekStart.toLocal().toString().split(' ')[0]}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () => _changeWeek(7),
                  ),
                ],
              ),

              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: dayNames.length,
                  itemBuilder: (context, index) {
                    String day = dayNames[index];
                    DateTime date =
                        selectedWeekStart.add(Duration(days: index));
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$day - ${date.toLocal().toString().split(' ')[0]}",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () =>
                                      _selectTime(context, day, true),
                                  child: Text(
                                      "Start: ${_formatTimeOfDay(shiftStartTimes[day]!)}"),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      _selectTime(context, day, false),
                                  child: Text(
                                      "End: ${_formatTimeOfDay(shiftEndTimes[day]!)}"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _saveRota,
                child: Text("Save Rota"),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
