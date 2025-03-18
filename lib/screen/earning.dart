import 'package:flutter/material.dart';
import 'package:pfm/NavigationBar.dart';
import 'package:pfm/screen/new_job.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseurl = "http://127.0.0.1:8000";

class earning extends StatefulWidget {
  const earning({super.key});

  @override
  State<earning> createState() => _earningState();
}

class _earningState extends State<earning> {
  DateTime _selectedDay = DateTime.now();
  String? _selectedJob;
  // Store complete job objects to have access to the job id.
  List<Map<String, dynamic>> jobsData = [];
  // List of job titles used for the dropdown.
  List<String> jobList = [];
  // List of earnings to display below the calendar.
  List<Map<String, dynamic>> earningsList = [];

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');

    if (userId == null) {
      print("User ID not found in SharedPreferences");
      return;
    }

    var url = '$baseurl/api/getjob?id=$userId';
    try {
      final response = await http.get(Uri.parse(url));

      print("Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> jsonResponse = json.decode(response.body);

          // Extract 'data' list from the response
          List<dynamic> jobs = jsonResponse['data'];

          setState(() {
            jobsData = jobs.cast<Map<String, dynamic>>();
            jobList =
                jobsData.map((job) => job['Job_title'].toString()).toList();
          });
        } catch (e) {
          print("Error decoding JSON: $e");
        }
      } else {
        print('Failed to load jobs. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching jobs: $e");
    }
  }

  Future<void> _fetchEarnings(int jobId) async {
    var url = '$baseurl/api/getearnings?job_id=$jobId';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> jsonResponse = json.decode(response.body);
          List<dynamic> earnings = jsonResponse['data'];

          setState(() {
            earningsList = earnings.map((e) {
              return {
                'id': e['id'],
                'amount': e['amount'],
                'date': e['date'],
              };
            }).toList();
          });
        } catch (e) {
          print("Error decoding earnings JSON: $e");
        }
      } else {
        print('Failed to load earnings. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching earnings: $e");
    }
  }

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
              const SizedBox(height: 10),
              _buildJobDropdown(),
              const SizedBox(height: 10),
              _buildCalendar(),
              const SizedBox(height: 20),
              // Replace the job list with the earnings list.
              Expanded(child: _buildEarningsSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Job:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        DropdownButton<String>(
          value: _selectedJob,
          hint: const Text('Choose a job or select "Add New Job"'),
          isExpanded: true,
          items: [
            ...jobList.map((job) => DropdownMenuItem(
                  value: job,
                  child: Text(job),
                )),
            const DropdownMenuItem(
              value: "Add New Job",
              child: Text("➕ Add New Job"),
            ),
          ],
          onChanged: (String? newValue) {
            if (newValue == "Add New Job") {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      NewJobScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            } else {
              setState(() {
                _selectedJob = newValue;
              });
              // Find the corresponding job id from jobsData
              try {
                var selectedJobData =
                    jobsData.firstWhere((job) => job['Job_title'] == newValue);
                int jobId = selectedJobData['id'];
                // Call _fetchEarnings passing the job id.
                _fetchEarnings(jobId);
              } catch (e) {
                print("Error finding job data: $e");
              }
            }
          },
        ),
      ],
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
      },
    );
  }

  // This widget now builds the earnings list (instead of job list).
  Widget _buildEarningsSection() {
    if (_selectedJob == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            print("Please select a job from the dropdown");
          },
          child: const Text("Show Earnings"),
        ),
      );
    }
    if (earningsList.isEmpty) {
      return const Center(child: Text("No earnings available"));
    }
    return ListView.builder(
      itemCount: earningsList.length,
      itemBuilder: (context, index) {
        var earning = earningsList[index];
        return _buildEarningCard(
            earning['id'], earning['amount'], earning['date']);
      },
    );
  }

  // Each earnings card is tappable; on tap, we print the last earning id.
  Widget _buildEarningCard(dynamic id, dynamic amount, dynamic date) {
    return InkWell(
      onTap: () {
        if (earningsList.isNotEmpty) {
          var lastEarning = earningsList.last;
          print("Last earning id: ${lastEarning['id']}");
        }
      },
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
            Text("Earning ID: $id",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text("Amount: $amount", style: const TextStyle(color: Colors.grey)),
            Text("Date: $date", style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
