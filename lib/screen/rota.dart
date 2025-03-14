// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class rotaScreen extends StatefulWidget {
//   final int id;
//   rotaScreen(this.id);

//   @override
//   _rotaScreenState createState() => _rotaScreenState();
// }

// class _rotaScreenState extends State<rotaScreen> {
//   late DateTime selectedWeekStart;
//   final List<String> dayNames = [
//     'Monday',
//     'Tuesday',
//     'Wednesday',
//     'Thursday',
//     'Friday',
//     'Saturday',
//     'Sunday'
//   ];
//   late Map<String, TimeOfDay> shiftStartTimes;
//   late Map<String, TimeOfDay> shiftEndTimes;

//   @override
//   void initState() {
//     super.initState();
//     DateTime now = DateTime.now();
//     selectedWeekStart = now.subtract(Duration(days: now.weekday - 1));
//     initializeWeekData();
//     print("Received ID: ${widget.id}");
//   }

//   void initializeWeekData() {
//     shiftStartTimes = {
//       for (var day in dayNames) day: TimeOfDay(hour: 8, minute: 0),
//     };
//     shiftEndTimes = {
//       for (var day in dayNames) day: TimeOfDay(hour: 12, minute: 0),
//     };
//   }

//   Future<void> _selectTime(
//       BuildContext context, String day, bool isStartTime) async {
//     final TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: isStartTime ? shiftStartTimes[day]! : shiftEndTimes[day]!,
//     );
//     if (pickedTime != null) {
//       setState(() {
//         if (isStartTime) {
//           shiftStartTimes[day] = pickedTime;
//         } else {
//           if (pickedTime.hour < shiftStartTimes[day]!.hour ||
//               (pickedTime.hour == shiftStartTimes[day]!.hour &&
//                   pickedTime.minute <= shiftStartTimes[day]!.minute)) {
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                 content: Text("End time must be later than start time")));
//           } else {
//             shiftEndTimes[day] = pickedTime;
//           }
//         }
//       });
//     }
//   }

//   String _formatTimeOfDay(TimeOfDay time) {
//     return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
//   }

//   Future<void> _saveRota() async {
//     List<Map<String, dynamic>> rotaData = dayNames.map((day) {
//       return {
//         "date": selectedWeekStart
//             .add(Duration(days: dayNames.indexOf(day)))
//             .toIso8601String()
//             .split('T')[0],
//         "start_time": _formatTimeOfDay(shiftStartTimes[day]!),
//         "end_time": _formatTimeOfDay(shiftEndTimes[day]!),
//       };
//     }).toList();

//     try {
//       print("Sending Data for ID: ${widget.id}");
//       print(rotaData);
//       var response = await http.post(
//         Uri.parse("http://1.1.1.1/newrota"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"id": widget.id, "rota": rotaData}),
//       );
//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text("Rota saved successfully!")));
//       } else {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text("Failed to save rota")));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Error: $e")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Weekly Rota")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(
//                 "Week Starting: ${selectedWeekStart.toLocal().toString().split(' ')[0]}",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 16),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: dayNames.length,
//                 itemBuilder: (context, index) {
//                   String day = dayNames[index];
//                   DateTime date = selectedWeekStart.add(Duration(days: index));
//                   return Card(
//                     elevation: 3,
//                     margin: const EdgeInsets.symmetric(vertical: 6),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                               "$day - ${date.toLocal().toString().split(' ')[0]}",
//                               style: TextStyle(
//                                   fontSize: 16, fontWeight: FontWeight.bold)),
//                           SizedBox(height: 8),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               ElevatedButton(
//                                 onPressed: () =>
//                                     _selectTime(context, day, true),
//                                 child: Text(
//                                     "Start: ${_formatTimeOfDay(shiftStartTimes[day]!)}"),
//                               ),
//                               ElevatedButton(
//                                 onPressed: () =>
//                                     _selectTime(context, day, false),
//                                 child: Text(
//                                     "End: ${_formatTimeOfDay(shiftEndTimes[day]!)}"),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             ElevatedButton(
//               onPressed: _saveRota,
//               child: Text("Save Rota"),
//               style: ElevatedButton.styleFrom(
//                   minimumSize: Size(double.infinity, 50)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
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
  late List<String> jobList; // List to store job names
  String? selectedJob; // Variable to store the selected job

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    selectedWeekStart = now.subtract(Duration(days: now.weekday - 1));
    initializeWeekData();
    jobList = [];
    selectedJob = null;
    fetchJobList(); // Fetch the job list when the screen is initialized
    print("Received ID: ${widget.id}");
  }

  void initializeWeekData() {
    shiftStartTimes = {
      for (var day in dayNames) day: TimeOfDay(hour: 8, minute: 0),
    };
    shiftEndTimes = {
      for (var day in dayNames) day: TimeOfDay(hour: 12, minute: 0),
    };
  }

  // Fetch job list from the API
  Future<void> fetchJobList() async {
    try {
      var response = await http.get(Uri.parse("http://127.0.0.1:8000/getJobs"));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          jobList = List<String>.from(data['jobs']);
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to load jobs")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error fetching jobs: $e")));
    }
  }

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

  String _formatTimeOfDay(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _saveRota() async {
    List<Map<String, dynamic>> rotaData = dayNames.map((day) {
      return {
        "date": selectedWeekStart
            .add(Duration(days: dayNames.indexOf(day)))
            .toIso8601String()
            .split('T')[0],
        "start_time": _formatTimeOfDay(shiftStartTimes[day]!),
        "end_time": _formatTimeOfDay(shiftEndTimes[day]!),
        "job": selectedJob, // Add the selected job to the rota data
      };
    }).toList();

    try {
      print("Sending Data for ID: ${widget.id}");
      print(rotaData);
      var response = await http.post(
        Uri.parse("http://1.1.1.1/newrota"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": widget.id, "rota": rotaData}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Rota saved successfully!")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to save rota")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Week Rota",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
                "Week Starting: ${selectedWeekStart.toLocal().toString().split(' ')[0]}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            // Dropdown for job selection
            if (jobList.isNotEmpty)
              DropdownButton<String>(
                value: selectedJob,
                hint: Text('Select Job'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedJob = newValue;
                  });
                },
                items: jobList.map<DropdownMenuItem<String>>((String job) {
                  return DropdownMenuItem<String>(
                    value: job,
                    child: Text(job),
                  );
                }).toList(),
              ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: dayNames.length,
                itemBuilder: (context, index) {
                  String day = dayNames[index];
                  DateTime date = selectedWeekStart.add(Duration(days: index));
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
                                  fontSize: 16, fontWeight: FontWeight.bold)),
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
    );
  }
}
