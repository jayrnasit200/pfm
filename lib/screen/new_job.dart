// lib/screen/new_job_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:pfm/data/local/local_db.dart';
import 'package:pfm/data/models/job.dart';
import 'package:pfm/screen/joblist.dart';

class NewJobScreen extends StatefulWidget {
  final job? jobData;

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
  job? _jobDetails;

  @override
  void initState() {
    super.initState();
    if (widget.jobData != null) {
      _jobDetails = widget.jobData;
      _populateFields();
    }
  }

  void _populateFields() {
    jobTitleController.text = _jobDetails?.title ?? "";
    payRateController.text = _jobDetails?.payRate.toString() ?? "";
    descriptionController.text = _jobDetails?.description ?? "";
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final db = LocalDb.isar;

      if (_jobDetails != null) {
        // Update existing job
        final updatedJob = _jobDetails!
          ..title = jobTitleController.text
          ..payRate = double.tryParse(payRateController.text) ?? 0.0
          ..description = descriptionController.text;

        await db.writeTxn(() async {
          await db.jobs.put(updatedJob);
        });
      } else {
        // Create new job
        final newJob = job()
          ..title = jobTitleController.text
          ..payRate = double.tryParse(payRateController.text) ?? 0.0
          ..description = descriptionController.text;

        await db.writeTxn(() async {
          await db.jobs.put(newJob);
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Job saved successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const JobListScreen()),
      );
    } catch (e) {
      _showError("Error saving job: $e");
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
    bool isEditing = _jobDetails != null;

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
