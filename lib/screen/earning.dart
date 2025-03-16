import 'package:flutter/material.dart';
import 'package:pfm/NavigationBar.dart';
import 'package:pfm/screen/new_job.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class earning extends StatefulWidget {
  const earning({super.key});

  @override
  State<earning> createState() => _earningState();
}

class _earningState extends State<earning> {
  DateTime _selectedDay = DateTime.now();
  String? _selectedJob;
  List<String> jobList = [];

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

    var url = 'http://127.0.0.1:8000/api/getjob?id=$userId';

    try {
      final response = await http.get(Uri.parse(url));

      print("Response Status Code: ${response.statusCode}");
      var listdata = response.body;
      // print(listdata['data']);

      if (response.statusCode == 200) {
        try {
          List<dynamic> jobs = json.decode(response.body);
          setState(() {
            jobList = jobs.map((job) => job['title'].toString()).toList();
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
              Expanded(child: _buildJobSection()),
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
          hint: const Text('Choose a job or select "No Job"'),
          isExpanded: true,
          items: [
            ...jobList.map((job) => DropdownMenuItem(
                  value: job,
                  child: Text(job),
                )),
            const DropdownMenuItem(
              value: "No Job",
              child: Text("I don't have a job now"),
            ),
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
                // MaterialPageRoute(builder: (context) => const Spending()),
              );
              ;
            } else {
              setState(() {
                _selectedJob = newValue;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildJobSection() {
    if (_selectedJob == "No Job" || _selectedJob == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            print("Show job listings");
          },
          child: const Text("Show Jobs"),
        ),
      );
    }
    return ListView.builder(
      itemCount: jobList.length,
      itemBuilder: (context, index) {
        return _buildJobCard(
            jobList[index], "Description for ${jobList[index]}");
      },
    );
  }

  Widget _buildJobCard(String title, String description) {
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
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(description, style: const TextStyle(color: Colors.grey)),
        ],
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
      },
    );
  }
}
