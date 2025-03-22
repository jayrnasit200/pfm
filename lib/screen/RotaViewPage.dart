import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pfm/screen/rota.dart';

const String baseurl = "http://127.0.0.1:8000";

class RotaViewPage extends StatefulWidget {
  final int jobId;

  RotaViewPage(this.jobId);

  @override
  _RotaViewPageState createState() => _RotaViewPageState();
}

class _RotaViewPageState extends State<RotaViewPage> {
  bool isLoading = true;
  List<dynamic> rotaRecords = [];

  @override
  void initState() {
    super.initState();
    fetchRotaRecords();
  }

  Future<void> fetchRotaRecords() async {
    try {
      var response = await http.get(
        Uri.parse("$baseurl/api/getrota?job=${widget.jobId}"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          rotaRecords = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        print("Failed to load rota records");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<TimeOfDay?> _pickTime(
      BuildContext context, TimeOfDay initialTime) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
  }

  void _editRota(
      int id, String startTime, String endTime, String date, String status) {
    TimeOfDay selectedStartTime = _parseTime(startTime);
    TimeOfDay selectedEndTime = _parseTime(endTime);
    bool isCompleted = status.toLowerCase() == 'completed';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Update Rota"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Date of Shift: $date"), // Fixed undefined variable
                  ListTile(
                    title: Text(
                        "Start Time: ${selectedStartTime.format(context)}"),
                    trailing: Icon(Icons.access_time),
                    onTap: () async {
                      TimeOfDay? pickedTime =
                          await _pickTime(context, selectedStartTime);
                      if (pickedTime != null) {
                        setState(() {
                          selectedStartTime = pickedTime;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text("End Time: ${selectedEndTime.format(context)}"),
                    trailing: Icon(Icons.access_time),
                    onTap: () async {
                      TimeOfDay? pickedTime =
                          await _pickTime(context, selectedEndTime);
                      if (pickedTime != null) {
                        setState(() {
                          selectedEndTime = pickedTime;
                        });
                      }
                    },
                  ),
                  Row(
                    children: [
                      Text("Completed: "),
                      Checkbox(
                        value: isCompleted,
                        onChanged: (bool? value) {
                          setState(() {
                            isCompleted = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    String updatedStatus =
                        isCompleted ? 'completed' : 'pending';

                    try {
                      var response = await http.post(
                        Uri.parse("$baseurl/api/updaterotastatus"),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'id': id,
                          'date': date,
                          'startTime': _formatTime(selectedStartTime),
                          'endTime': _formatTime(selectedEndTime),
                          'status': updatedStatus,
                          'jobid': widget.jobId,
                        }),
                      );
                      // print(response.body);
                      if (response.statusCode == 200) {
                        fetchRotaRecords();
                        Navigator.pop(context);
                      } else {
                        print("Failed to update rota record");
                      }
                    } catch (e) {
                      print("Error: $e");
                    }
                  },
                  child: Text("Submit"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  TimeOfDay _parseTime(String time) {
    List<String> parts = time.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  void _addRota() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => rotaScreen(widget.jobId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rota View"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addRota,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: rotaRecords.length,
              itemBuilder: (context, index) {
                var rota = rotaRecords[index];
                String date = rota['Date'];
                String startTime = rota['sTime'];
                String endTime = rota['eTime'];
                String status = rota['status'];

                if (status == "pending") {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Date: $date",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text("Start Time: $startTime"),
                          Text("End Time: $endTime"),
                          Text("Status: $status"),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () => _editRota(rota['id'],
                                    startTime, endTime, date, status),
                                child: Text("Update"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SizedBox.shrink(); // Hide completed records
              },
            ),
    );
  }
}
