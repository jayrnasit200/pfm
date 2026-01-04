import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:FINEXA/data/local/local_db.dart';
import 'package:FINEXA/data/models/job.dart';
import 'package:FINEXA/screen/joblist.dart';

class NewJobScreen extends StatefulWidget {
  final Job? jobData;

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
  Job? _jobDetails;

  final Color primaryBlue = Colors.blue;

  @override
  void initState() {
    super.initState();
    _jobDetails = widget.jobData;
    if (_jobDetails != null) {
      _populateFields();
    }
  }

  @override
  void dispose() {
    jobTitleController.dispose();
    payRateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _populateFields() {
    jobTitleController.text = _jobDetails!.title;
    payRateController.text = _jobDetails!.payRate.toString();
    descriptionController.text = _jobDetails!.description ?? '';
  }

  /// ✅ SAVES DATA LOCALLY ON PHONE (ISAR)
  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final isar = LocalDb.isar;

      await isar.writeTxn(() async {
        if (_jobDetails != null) {
          // UPDATE
          _jobDetails!
            ..title = jobTitleController.text.trim()
            ..payRate = double.tryParse(payRateController.text) ?? 0.0
            ..description = descriptionController.text.trim();

          await isar.jobs.put(_jobDetails!);
        } else {
          // CREATE
          final job = Job(
            title: jobTitleController.text.trim(),
            payRate: double.tryParse(payRateController.text) ?? 0.0,
            description: descriptionController.text.trim(),
          );

          await isar.jobs.put(job);
        }
      });

      if (!mounted) return;

      _showFeedback('Job saved locally on device', Colors.green);

      // ✅ Go back — JobList listens to Isar changes
      Navigator.pop(context);
    } catch (e) {
      _showFeedback('Error saving job: $e', Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showFeedback(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = _jobDetails != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: Text(
          isEditing ? 'Edit Job' : 'New Occupation',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Basic Details'),
              _buildModernTextField(
                controller: jobTitleController,
                label: 'Job Title',
                icon: Icons.work_outline_rounded,
                hint: 'e.g. Software Engineer',
              ),
              const SizedBox(height: 20),
              _buildModernTextField(
                controller: payRateController,
                label: 'Hourly Pay (£)',
                icon: Icons.payments_outlined,
                hint: '0.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                formatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d*$'),
                  )
                ],
              ),
              const SizedBox(height: 25),
              _buildSectionHeader('Information'),
              _buildModernTextField(
                controller: descriptionController,
                label: 'Description',
                icon: Icons.notes_rounded,
                hint: 'What do you do at this job?',
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
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: primaryBlue.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? '$label is required' : null,
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: isLoading ? null : _saveJob,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'CONFIRM & SAVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}
