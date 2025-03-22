import 'package:flutter/material.dart';
import 'package:pfm/NavigationBar.dart';
import 'package:pfm/screen/new_job.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
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
  List<Map<String, dynamic>> jobsData = [];
  List<String> jobList = [];
  List<Map<String, dynamic>> earningsList = [];

  @override
  void initState() {
    super.initState();
    _selectedJob = "all"; // Set default value to "all"
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

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> jobs = jsonResponse['data'];

        setState(() {
          jobsData = jobs.cast<Map<String, dynamic>>();
          jobList = jobsData.map((job) => job['Job_title'].toString()).toList();
        });

        // Fetch earnings when jobs are loaded
        _fetchEarnings(
            null); // Fetch all earnings initially when "all" is selected
      } else {
        print('Failed to load jobs. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching jobs: $e");
    }
  }

  Future<void> _fetchEarnings(int? jobId) async {
    String url = jobId != null && jobId > 0
        ? '$baseurl/api/getearnings?job_id=$jobId'
        : '$baseurl/api/getearnings';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> earnings = jsonResponse['data'];

        setState(() {
          earningsList = earnings.map((e) {
            return {
              'category': e['category'],
              'amount': e['amount'],
              'date': e['date_earned'],
            };
          }).toList();
        });
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
              const SizedBox(height: 20),
              _buildJobDropdown(),
              const SizedBox(height: 20),
              _buildCalendar(),
              const SizedBox(height: 20),
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
        const SizedBox(height: 10),
        DropdownButton<String>(
          value: _selectedJob != null &&
                  (jobList.contains(_selectedJob) || _selectedJob == "all")
              ? _selectedJob
              : null,
          hint: const Text('Choose a job or select "Add New Job"'),
          isExpanded: true,
          items: [
            const DropdownMenuItem(
              value: "all",
              child: Text("All Jobs"),
            ),
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

              if (newValue == "all") {
                _fetchEarnings(null);
              } else {
                var selectedJobData =
                    jobsData.firstWhere((job) => job['Job_title'] == newValue);
                int jobId = selectedJobData['id'];
                _fetchEarnings(jobId);
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
            earning['category'], earning['amount'], earning['date']);
      },
    );
  }

  Widget _buildEarningCard(dynamic category, dynamic amount, dynamic date) {
    return InkWell(
      onTap: () {
        print(
            "Earning tapped: Category - $category, Amount - $amount, Date - $date");
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Amount: \£${amount.toStringAsFixed(2)}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Category: $category",
                    style: const TextStyle(color: Colors.grey)),
                Text("Date: $date", style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
