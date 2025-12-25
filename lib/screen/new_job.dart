// lib/screen/new_job_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:pfm/data/local/local_db.dart';
import 'package:pfm/data/models/job.dart';
import 'package:pfm/screen/joblist.dart';

class NewJobScreen extends StatefulWidget {
  final job? jobData; // Note: Ensure your model class is 'job' or 'Job'

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

  final Color primaryBlue = Colors.blue;

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
        final updatedJob = _jobDetails!
          ..title = jobTitleController.text
          ..payRate = double.tryParse(payRateController.text) ?? 0.0
          ..description = descriptionController.text;

        await db.writeTxn(() async {
          await db.jobs.put(updatedJob);
        });
      } else {
        final newJob = job()
          ..title = jobTitleController.text
          ..payRate = double.tryParse(payRateController.text) ?? 0.0
          ..description = descriptionController.text;

        await db.writeTxn(() async {
          await db.jobs.put(newJob);
        });
      }

      _showFeedback("Job saved successfully", Colors.green);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const JobListScreen()),
      );
    } catch (e) {
      _showFeedback("Error saving job: $e", Colors.red);
    }
    setState(() => isLoading = false);
  }

  void _showFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = _jobDetails != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: Text(isEditing ? "Edit Job" : "New Occupation",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Basic Details"),
              _buildModernTextField(
                controller: jobTitleController,
                label: "Job Title",
                icon: Icons.work_outline_rounded,
                hint: "e.g. Software Engineer",
              ),
              const SizedBox(height: 20),
              _buildModernTextField(
                controller: payRateController,
                label: "Hourly Pay (£)",
                icon: Icons.payments_outlined,
                hint: "0.00",
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                formatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
                ],
              ),
              const SizedBox(height: 25),
              _buildSectionHeader("Information"),
              _buildModernTextField(
                controller: descriptionController,
                label: "Description",
                icon: Icons.notes_rounded,
                hint: "What do you do at this job?",
                maxLines: 4,
              ),
              const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: primaryBlue.withOpacity(0.6),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: primaryBlue.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          labelStyle: TextStyle(color: primaryBlue.withOpacity(0.7)),
        ),
        validator: (value) => value!.isEmpty ? "$label is required" : null,
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: isLoading ? null : _saveJob,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "CONFIRM & SAVE",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
              ),
      ),
    );
  }
}
