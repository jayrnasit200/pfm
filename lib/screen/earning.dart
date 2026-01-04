import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:FINEXA/NavigationBar.dart';
import 'package:FINEXA/data/local/local_db.dart';
import 'package:FINEXA/data/models/earning.dart';
import 'package:FINEXA/data/models/shift.dart';
import 'package:FINEXA/data/models/job.dart';

class EarningScreen extends StatefulWidget {
  const EarningScreen({super.key});

  @override
  State<EarningScreen> createState() => _EarningScreenState();
}

class _EarningScreenState extends State<EarningScreen> {
  final Color primaryBlue = Colors.blue;

  int? selectedJobId;

  List<Job> jobs = [];
  List<Shift> pendingShifts = [];
  List<Earning> earnings = [];

  double pendingTotal = 0;
  double monthTotal = 0;
  double yearTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ───────────────── LOAD DATA ─────────────────

  Future<void> _loadData() async {
    final db = LocalDb.isar;

    final jobData = await db.jobs.where().findAll();
    final allEarnings = await db.earnings.where().findAll();
    final completedShifts =
        await db.shifts.filter().statusEqualTo("completed").findAll();

    final filteredShifts = selectedJobId == null
        ? completedShifts
        : completedShifts.where((s) => s.jobId == selectedJobId).toList();

    final now = DateTime.now();

    double pending = 0;
    for (final s in filteredShifts) {
      pending += _shiftAmount(s, jobData);
    }

    double month = 0;
    double year = 0;

    for (final e in allEarnings) {
      if (selectedJobId != null && e.jobId != selectedJobId) continue;
      if (e.dateEarned.year == now.year) {
        year += e.amount;
        if (e.dateEarned.month == now.month) month += e.amount;
      }
    }

    setState(() {
      jobs = jobData;
      earnings = allEarnings;
      pendingShifts = filteredShifts;
      pendingTotal = pending;
      monthTotal = month;
      yearTotal = year;
    });
  }

  // ───────────────── HELPERS ─────────────────

  int _toMinutes(String time) {
    final p = time.split(":");
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  double _shiftAmount(Shift s, List<Job> jobsList) {
    final job = jobsList.firstWhere((j) => j.id == s.jobId);
    return ((_toMinutes(s.endTime) - _toMinutes(s.startTime)) / 60) *
        job.payRate;
  }

  // ───────────────── ADD MANUAL EARNING ─────────────────

  Future<void> _addManualEarning() async {
    final amountCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    int? jobId;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("Add Earning",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          TextField(
            controller: amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: "Amount (£)"),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int?>(
            hint: const Text("Select Job (optional)"),
            items: [
              const DropdownMenuItem(value: null, child: Text("Other Income")),
              ...jobs.map(
                (j) => DropdownMenuItem(value: j.id, child: Text(j.title)),
              ),
            ],
            onChanged: (v) => jobId = v,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: categoryCtrl,
            decoration: const InputDecoration(labelText: "Category"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text);
              if (amount == null) return;

              final db = LocalDb.isar;
              await db.writeTxn(() async {
                await db.earnings.put(
                  Earning()
                    ..amount = amount
                    ..jobId = jobId ?? 0
                    ..category =
                        categoryCtrl.text.isEmpty ? "Other" : categoryCtrl.text
                    ..dateEarned = DateTime.now()
                    ..status = "paid",
                );
              });

              Navigator.pop(context);
              _loadData();
            },
            child: const Text("SAVE"),
          )
        ]),
      ),
    );
  }

  // ───────────────── MONTHLY BAR CHART (FIXED) ─────────────────

  void _openMonthlyChart() {
    final data = List.generate(12, (i) {
      return earnings
          .where((e) => e.dateEarned.month == i + 1)
          .fold(0.0, (s, e) => s + e.amount);
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Monthly Earnings"),
        content: SizedBox(
          height: 280,
          width: double.maxFinite,
          child: BarChart(
            BarChartData(
              barGroups: List.generate(
                12,
                (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: data[i],
                      color: primaryBlue,
                      width: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────── JOB PIE CHART (FIXED) ─────────────────

  void _openJobPie() {
    final map = <String, double>{};

    for (final e in earnings) {
      final name = e.jobId == 0
          ? "Other"
          : jobs.firstWhere((j) => j.id == e.jobId).title;
      map[name] = (map[name] ?? 0) + e.amount;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Job Breakdown"),
        content: SizedBox(
          height: 260,
          width: double.maxFinite,
          child: PieChart(
            PieChartData(
              sections: map.entries.map((e) {
                return PieChartSectionData(
                  value: e.value,
                  title: e.key,
                  radius: 70,
                  titleStyle:
                      const TextStyle(color: Colors.white, fontSize: 11),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────── CSV EXPORT ─────────────────

  Future<void> _exportCSV() async {
    final rows = [
      ["Date", "Job", "Category", "Amount"]
    ];

    for (final e in earnings) {
      rows.add([
        DateFormat('yyyy-MM-dd').format(e.dateEarned),
        e.jobId == 0 ? "Other" : jobs.firstWhere((j) => j.id == e.jobId).title,
        e.category,
        e.amount.toStringAsFixed(2)
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/earnings.csv");
    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("CSV exported to ${file.path}")),
    );
  }

  // ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const NavigationBars("Earning"),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [
          _header(),
          _jobDropdown(),
          _summaryRow(),
          Expanded(child: _earningList()),
        ]),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Earnings",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue)),
          Row(children: [
            IconButton(
                icon: const Icon(Icons.bar_chart),
                onPressed: _openMonthlyChart),
            IconButton(
                icon: const Icon(Icons.pie_chart), onPressed: _openJobPie),
            IconButton(icon: const Icon(Icons.download), onPressed: _exportCSV),
            IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: _addManualEarning),
          ])
        ],
      ),
    );
  }

  Widget _jobDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButton<int?>(
        value: selectedJobId,
        hint: const Text("All Jobs"),
        isExpanded: true,
        items: [
          const DropdownMenuItem(value: null, child: Text("All Jobs")),
          ...jobs
              .map((j) => DropdownMenuItem(value: j.id, child: Text(j.title))),
        ],
        onChanged: (v) {
          selectedJobId = v;
          _loadData();
        },
      ),
    );
  }

  Widget _summaryRow() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        _box("Pending", pendingTotal, Colors.orange),
        _box("Month", monthTotal, Colors.green),
        _box("Year", yearTotal, Colors.blue),
      ]),
    );
  }

  Widget _box(String label, double val, Color c) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: c.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          Text(label, style: TextStyle(color: c, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text("£${val.toStringAsFixed(2)}",
              style: TextStyle(color: c, fontSize: 16)),
        ]),
      ),
    );
  }

  Widget _earningList() {
    if (earnings.isEmpty) {
      return const Center(child: Text("No earnings yet"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: earnings.length,
      itemBuilder: (_, i) {
        final e = earnings[i];
        final jobName = e.jobId == 0
            ? "Other"
            : jobs.firstWhere((j) => j.id == e.jobId).title;

        return Card(
          child: ListTile(
            onLongPress: () async {
              final db = LocalDb.isar;
              await db.writeTxn(() async {
                await db.earnings.delete(e.id);
              });
              _loadData();
            },
            title: Text("£${e.amount.toStringAsFixed(2)}"),
            subtitle: Text(
                "$jobName • ${DateFormat('MMM dd, yyyy').format(e.dateEarned)}"),
          ),
        );
      },
    );
  }
}
