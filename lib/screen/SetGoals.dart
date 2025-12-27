import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:pfm/data/local/local_db.dart';
import 'package:pfm/data/models/goal.dart';

class SetGoals extends StatefulWidget {
  const SetGoals({super.key});

  @override
  State<SetGoals> createState() => _SetGoalsState();
}

class _SetGoalsState extends State<SetGoals> {
  final TextEditingController goalNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  DateTime? selectedDate;
  bool isSaving = false;

  final Color primaryBlue = Colors.blue;

  @override
  void dispose() {
    goalNameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() => selectedDate = pickedDate);
    }
  }

  /// ✅ SAVE GOAL LOCALLY (ISAR)
  Future<void> _saveGoal() async {
    if (goalNameController.text.isEmpty ||
        amountController.text.isEmpty ||
        selectedDate == null) {
      _showSnackBar("Please fill all fields", Colors.redAccent);
      return;
    }

    setState(() => isSaving = true);

    try {
      final isar = LocalDb.isar;

      final goal = Goal(
        name: goalNameController.text.trim(),
        targetAmount: double.tryParse(amountController.text.trim()) ?? 0.0,
        deadline: selectedDate!,
      )..savedAmount = 0.0;

      await isar.writeTxn(() async {
        await isar.goals.put(goal);
      });

      if (!mounted) return;

      _showSnackBar("Goal saved locally 🎯", Colors.green);
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Error saving goal: $e", Colors.redAccent);
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        title: const Text(
          "New Savings Goal",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 30),
            _buildLabel("What are you saving for?"),
            _buildInputField(
              controller: goalNameController,
              hint: "e.g. New Laptop, Vacation",
              icon: Icons.flag_rounded,
            ),
            const SizedBox(height: 20),
            _buildLabel("How much is the target?"),
            _buildInputField(
              controller: amountController,
              hint: "0.00",
              icon: Icons.account_balance_wallet_rounded,
              keyboardType: TextInputType.number,
              formatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 20),
            _buildLabel("When do you need it by?"),
            _buildDatePicker(),
            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: primaryBlue, size: 30),
          const SizedBox(width: 15),
          const Expanded(
            child: Text(
              "Setting a deadline helps you stay on track with your savings.",
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: primaryBlue.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: formatters,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryBlue.withOpacity(0.5)),
          hintText: hint,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _pickDate(context),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: primaryBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: primaryBlue.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: primaryBlue),
            const SizedBox(width: 15),
            Text(
              selectedDate == null
                  ? "Select Target Date"
                  : DateFormat('MMMM dd, yyyy').format(selectedDate!),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selectedDate == null ? Colors.black38 : Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: primaryBlue.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isSaving ? null : _saveGoal,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "SET GOAL",
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
