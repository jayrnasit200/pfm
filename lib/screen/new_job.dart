import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String baseurl = "http://127.0.0.1:8000"; // Change as needed

class NewJobScreen extends StatefulWidget {
  final Map<String, dynamic>? jobData;

  const NewJobScreen({super.key, this.jobData});

  @override
  State<NewJobScreen> createState() => _NewJobScreenState();
}

class _NewJobScreenState extends State<NewJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController payRateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.jobData != null) {
      jobTitleController.text = widget.jobData!['jobTitle'] ?? "";
      payRateController.text = widget.jobData!['hourlyPay']?.toString() ?? "";
      descriptionController.text = widget.jobData!['description'] ?? "";
    }
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('id');
      final response = await http.post(
        Uri.parse('$baseurl/api/createjob'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Jobtitle": jobTitleController.text,
          "payrate": double.tryParse(payRateController.text) ?? 0.0,
          "description": descriptionController.text,
          "user_id": userId,
        }),
      );
      // print(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Job saved successfully"),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Close the screen on success
      } else {
        _showError("Failed to save job. Try again.");
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
    bool isEditing = widget.jobData != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Job" : "Add New Job"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
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
              FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d*$')), // Only allows numbers & decimals
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
