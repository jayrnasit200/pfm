// lib/screen/Spending.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:pfm/NavigationBar.dart';
import 'package:pfm/data/local/local_db.dart';
import 'package:pfm/data/models/spending.dart' as model;

class Spending extends StatefulWidget {
  const Spending({super.key});

  @override
  State<Spending> createState() => _SpendingState();
}

class _SpendingState extends State<Spending> {
  final Color primaryBlue = Colors.blue;

  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const NavigationBars("Spending"),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            _calendar(),
            const SizedBox(height: 15),
            _listHeader(),
            Expanded(child: _spendingList()),
          ],
        ),
      ),
    );
  }

  // ───────────────── HEADER ─────────────────

  Widget _header() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(25, 20, 25, 10),
      child: Text(
        "Spending Tracker",
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _calendar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TableCalendar(
        firstDay: DateTime.utc(2010),
        lastDay: DateTime.utc(2030),
        focusedDay: _selectedDay,
        calendarFormat: _calendarFormat,
        onFormatChanged: (f) => setState(() => _calendarFormat = f),
        selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
        onDaySelected: (d, _) {
          setState(() => _selectedDay = d);
          _openForm(d);
        },
      ),
    );
  }

  Widget _listHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Transactions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(DateFormat('MMMM yyyy').format(_selectedDay),
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ───────────────── LIST ─────────────────

  Widget _spendingList() {
    return FutureBuilder<List<model.Spending>>(
      future: _loadSpendings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = snapshot.data!;
        if (list.isEmpty) {
          return const Center(child: Text("No transactions recorded"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (_, i) => _spendingCard(list[i]),
        );
      },
    );
  }

  Widget _spendingCard(model.Spending s) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _openForm(s.date, existing: s),
            icon: Icons.edit,
            backgroundColor: Colors.blue.shade100,
            foregroundColor: Colors.blue,
          ),
          SlidableAction(
            onPressed: (_) => _deleteSpending(s.id),
            icon: Icons.delete,
            backgroundColor: Colors.red.shade100,
            foregroundColor: Colors.red,
          ),
        ],
      ),
      child: Card(
        child: ListTile(
          title: Text(s.description),
          subtitle: Text(DateFormat('MMM dd, yyyy').format(s.date)),
          trailing: Text(
            "- £${s.amount.toStringAsFixed(2)}",
            style:
                const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // ───────────────── FORM ─────────────────

  void _openForm(DateTime date, {model.Spending? existing}) {
    final isEdit = existing != null;

    if (isEdit) {
      _amountController.text = existing.amount.toString();
      _descriptionController.text = existing.description;
    } else {
      _amountController.clear();
      _descriptionController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 10),
            Text(isEdit ? "Edit Transaction" : "New Transaction",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _field(_amountController, "Amount (£)", TextInputType.number),
            const SizedBox(height: 10),
            _field(_descriptionController, "Description", TextInputType.text),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => isEdit ? _update(existing!) : _save(date),
                child: Text(isEdit ? "UPDATE" : "SAVE"),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ───────────────── DATABASE ─────────────────

  Future<List<model.Spending>> _loadSpendings() async {
    final db = LocalDb.isar;
    final day =
        DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);

    return db.spendings.filter().dateEqualTo(day).findAll();
  }

  Future<void> _save(DateTime date) async {
    if (!_formKey.currentState!.validate()) return;

    final db = LocalDb.isar;
    await db.writeTxn(() async {
      await db.spendings.put(
        model.Spending()
          ..amount = double.parse(_amountController.text)
          ..description = _descriptionController.text
          ..date = DateTime(date.year, date.month, date.day),
      );
    });

    Navigator.pop(context);
    setState(() {});
  }

  Future<void> _update(model.Spending s) async {
    if (!_formKey.currentState!.validate()) return;

    final db = LocalDb.isar;
    await db.writeTxn(() async {
      s.amount = double.parse(_amountController.text);
      s.description = _descriptionController.text;
      await db.spendings.put(s);
    });

    Navigator.pop(context);
    setState(() {});
  }

  Future<void> _deleteSpending(int id) async {
    final db = LocalDb.isar;
    await db.writeTxn(() async {
      await db.spendings.delete(id);
    });
    setState(() {});
  }

  // ───────────────── HELPERS ─────────────────

  Widget _field(
      TextEditingController controller, String label, TextInputType type) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      validator: (v) => v == null || v.isEmpty ? "Required" : null,
      decoration: InputDecoration(labelText: label),
    );
  }
}
