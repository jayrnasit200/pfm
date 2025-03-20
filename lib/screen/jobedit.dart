import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pfm/screen/RotaViewPage.dart';
import 'package:pfm/screen/joblist.dart';
import 'package:pfm/screen/rota.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String baseurl = "http://127.0.0.1:8000";

class Jobedit extends StatefulWidget {
  // Accepts either a Map with job details or an int (job id)
  final dynamic jobData;

  const Jobedit(this.jobData, {Key? key}) : super(key: key);

  @override
  State<Jobedit> createState() => _JobeditState();
}

class _JobeditState extends State<Jobedit> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController payRateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;
  Map<String, dynamic>? _jobDetails;

  @override
  void initState() {
    super.initState();
    if (widget.jobData != null) {
      if (widget.jobData is Map<String, dynamic>) {
        _jobDetails = widget.jobData as Map<String, dynamic>;
        _populateFields();
      } else if (widget.jobData is int) {
        // If only job id is provided, fetch full details from API
        _fetchJobDetails(widget.jobData as int);
      }
    }
  }

  void _populateFields() {
    jobTitleController.text = _jobDetails?['Job_title'] ?? "";
    payRateController.text = _jobDetails?['pay_rate']?.toString() ?? "";
    descriptionController.text = _jobDetails?['description'] ?? "";
  }

  Future<void> _fetchJobDetails(int jobId) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('$baseurl/api/jobedit/$jobId'));
      // print('$baseurl/api/jobedit?id=$jobId');
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        // Ensure the API returns a Map in the 'data' key.
        final data = jsonResponse['data'];
        // print(data);
        if (data is Map<String, dynamic>) {
          _jobDetails = data;
          _populateFields();
        } else {
          _showError("Unexpected data format returned from API");
        }
      } else {
        _showError(
            "Failed to load job details. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Error fetching job details: $e");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('id');
      if (userId == null) {
        _showError("User ID not found.");
        setState(() => isLoading = false);
        return;
      }

      // Prepare the request body.
      Map<String, dynamic> body = {
        "Jobtitle": jobTitleController.text,
        "payrate": double.tryParse(payRateController.text) ?? 0.0,
        "description": descriptionController.text,
        "user_id": userId,
      };

      // Determine if we are editing or creating.
      bool isEditing = _jobDetails != null;
      String url =
          isEditing ? '$baseurl/api/jobupdate' : '$baseurl/api/createjob';

      // If editing, include the job id in the request body.
      if (isEditing) {
        body["id"] = _jobDetails?['id'];
      }
      // print(body);
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Job saved successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JobListScreen()),
        );
      } else {
        _showError("Failed to save job. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Error: $e");
    }

    setState(() => isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If _jobDetails is null, we assume we're creating a job.
    bool isEditing = _jobDetails != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Job" : "Job"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildJobCard(),
                    const SizedBox(height: 20),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildJobCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Job Title",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          TextFormField(
            controller: jobTitleController,
            validator: (value) =>
                value!.isEmpty ? "Job title is required" : null,
            decoration: const InputDecoration(border: InputBorder.none),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text("Hourly Pay",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          TextFormField(
            controller: payRateController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) return "Pay rate is required";
              final double? parsedValue = double.tryParse(value);
              if (parsedValue == null) return "Enter a valid number";
              return null;
            },
            decoration: const InputDecoration(border: InputBorder.none),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text("Job Description",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          TextFormField(
            controller: descriptionController,
            validator: (value) =>
                value!.isEmpty ? "Description is required" : null,
            decoration: const InputDecoration(border: InputBorder.none),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // builder: (context) => rotaScreen(_jobDetails?['id']),
                  builder: (context) => RotaViewPage(_jobDetails?['id']),
                ),
              );
            },
            child: Text('View Rota'),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: isLoading ? null : _saveJob,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Save",
                style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
