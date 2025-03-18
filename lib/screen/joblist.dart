import 'package:flutter/material.dart';
import 'package:pfm/screen/jobedit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseurl = "http://127.0.0.1:8000";

class JobListScreen extends StatefulWidget {
  const JobListScreen({Key? key}) : super(key: key);

  @override
  _JobListScreenState createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  List<Map<String, dynamic>> jobs = [];
  bool isLoading = false;
  String errorMsg = '';

  @override
  void initState() {
    super.initState();
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id');
    if (userId == null) {
      setState(() {
        errorMsg = "User ID not found.";
        isLoading = false;
      });
      return;
    }

    var url = '$baseurl/api/getjob?id=$userId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['data'];
        setState(() {
          jobs = data.map((job) => job as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMsg = "Failed to load jobs. Status Code: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = "Error fetching jobs: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job List"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg.isNotEmpty
              ? Center(child: Text(errorMsg))
              : ListView.builder(
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: ListTile(
                        title: Text(job['Job_title'] ?? "No Title"),
                        subtitle:
                            Text(job['Job_description'] ?? "No Description"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => Jobedit(job['id'])));
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
