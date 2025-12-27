import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pfm/data/local/local_db.dart';
import 'package:pfm/data/models/job.dart';
import 'package:pfm/screen/RotaViewPage.dart';

class JobEdit extends StatefulWidget {
  final Job? jobData;

  const JobEdit({Key? key, this.jobData}) : super(key: key);

  @override
  State<JobEdit> createState() => _JobEditState();
}

class _JobEditState extends State<JobEdit> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController payRateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool isLoading = false;
  Job? _jobDetails;

  @override
  void initState() {
    super.initState();
    _jobDetails = widget.jobData;
    if (_jobDetails != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    jobTitleController.text = _jobDetails!.title;
    payRateController.text = _jobDetails!.payRate.toString();
    descriptionController.text = _jobDetails!.description ?? '';
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final isar = LocalDb.isar;

      await isar.writeTxn(() async {
        if (_jobDetails != null) {
          // 🔹 Update existing
          _jobDetails!
            ..title = jobTitleController.text.trim()
            ..payRate = double.tryParse(payRateController.text) ?? 0.0
            ..description = descriptionController.text.trim();

          await isar.jobs.put(_jobDetails!);
        } else {
          // 🔹 Create new
          final newJob = Job(
            title: jobTitleController.text.trim(),
            payRate: double.tryParse(payRateController.text) ?? 0.0,
            description: descriptionController.text.trim(),
          );

          await isar.jobs.put(newJob);
        }
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job details saved!'),
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      _showError('Error saving job: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = _jobDetails != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Job' : 'New Job',
          style: const TextStyle(
              fontWeight: FontWeight.w800, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildFormSection(),
                    const SizedBox(height: 24),
                    if (isEditing) _buildSecondaryActions(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            label: 'Job Title',
            controller: jobTitleController,
            hint: 'e.g. Graphic Designer',
            icon: Icons.work_outline_rounded,
            action: TextInputAction.next,
            validator: (v) => v!.isEmpty ? 'Job title is required' : null,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Pay Rate (Hourly)',
            controller: payRateController,
            hint: '0.00',
            icon: Icons.payments_outlined,
            prefix: '£ ',
            action: TextInputAction.next,
            keyboard: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
            ],
            validator: (v) => v!.isEmpty ? 'Pay rate is required' : null,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Description',
            controller: descriptionController,
            hint: 'Describe your duties...',
            icon: Icons.notes_rounded,
            maxLines: 3,
            action: TextInputAction.done,
            validator: (v) => v!.isEmpty ? 'Description is required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? prefix,
    int maxLines = 1,
    TextInputAction action = TextInputAction.next,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: action,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        hintText: hint,
        prefixText: prefix,
        prefixIcon: Icon(icon, size: 20, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildSecondaryActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RotaViewPage(_jobDetails!.id),
            ),
          );
        },
        icon: const Icon(Icons.calendar_view_day_rounded, size: 20),
        label: const Text('View Work Rota',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        style: TextButton.styleFrom(
          foregroundColor: Colors.blueAccent,
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        onPressed: isLoading ? null : _saveJob,
        child: const Text(
          'Save Job Details',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
