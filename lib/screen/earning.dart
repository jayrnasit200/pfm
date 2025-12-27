import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

import 'package:pfm/NavigationBar.dart';
import 'package:pfm/data/local/local_db.dart';
import 'package:pfm/data/models/earning.dart';
import 'package:pfm/data/models/shift.dart';
import 'package:pfm/data/models/job.dart';

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
        if (e.dateEarned.month == now.month) {
          month += e.amount;
        }
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

  // ───────────────── AMOUNT CALCULATION ─────────────────

  int _toMinutes(String time) {
    final p = time.split(":");
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  double _shiftAmount(Shift s, List<Job> jobsList) {
    final job = jobsList.firstWhere((j) => j.id == s.jobId);
    final start = _toMinutes(s.startTime);
    final end = _toMinutes(s.endTime);
    return ((end - start) / 60) * job.payRate;
  }

  // ───────────────── PENDING POPUP (MODERN UI, OLD LOGIC) ─────────────────

  Future<void> _openPendingPopup() async {
    Set<Shift> selected = {};
    double total = 0;
    final controller = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModal) {
            void recalc() {
              total = selected.fold(
                0,
                (sum, s) => sum + _shiftAmount(s, jobs),
              );
              controller.text = total.toStringAsFixed(2);
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Pending Shifts",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 220,
                    child: ListView(
                      children: pendingShifts.map((s) {
                        final job = jobs.firstWhere((j) => j.id == s.jobId);
                        return CheckboxListTile(
                          value: selected.contains(s),
                          onChanged: (v) {
                            setModal(() {
                              v! ? selected.add(s) : selected.remove(s);
                              recalc();
                            });
                          },
                          title: Text(job.title),
                          subtitle: Text(
                            "${DateFormat('MMM dd').format(s.date)} • "
                            "${s.startTime} - ${s.endTime}",
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: "Amount (£)",
                      prefixIcon: const Icon(Icons.attach_money_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selected.isEmpty
                          ? null
                          : () async {
                              final amount =
                                  double.tryParse(controller.text) ?? total;

                              final db = LocalDb.isar;

                              await db.writeTxn(() async {
                                final earning = Earning()
                                  ..amount = amount
                                  ..jobId = selectedJobId ?? 0
                                  ..category = "Shift Payment"
                                  ..dateEarned = DateTime.now()
                                  ..status = "paid";

                                await db.earnings.put(earning);

                                for (final s in selected) {
                                  s.status = "paid";
                                  await db.shifts.put(s);
                                }
                              });

                              Navigator.pop(context);
                              _loadData();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "ADD EARNING",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const NavigationBars("Earning"),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            _jobDropdown(),
            _summaryRow(),
            Expanded(child: _earningList()),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        "Earnings",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: primaryBlue,
        ),
      ),
    );
  }

  Widget _jobDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: primaryBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int?>(
            value: selectedJobId,
            hint: const Text("All Jobs"),
            isExpanded: true,
            items: [
              const DropdownMenuItem(value: null, child: Text("All Jobs")),
              ...jobs.map(
                (j) => DropdownMenuItem(value: j.id, child: Text(j.title)),
              ),
            ],
            onChanged: (v) {
              selectedJobId = v;
              _loadData();
            },
          ),
        ),
      ),
    );
  }

  Widget _summaryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _summaryBox(
            "Pending",
            pendingTotal,
            Colors.orange,
            onTap: pendingShifts.isEmpty ? null : _openPendingPopup,
          ),
          const SizedBox(width: 8),
          _summaryBox("Month", monthTotal, Colors.green),
          const SizedBox(width: 8),
          _summaryBox("Year", yearTotal, Colors.blue),
        ],
      ),
    );
  }

  Widget _summaryBox(String label, double value, Color color,
      {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 6),
              Text("£${value.toStringAsFixed(2)}",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _earningList() {
    if (earnings.isEmpty) {
      return const Center(child: Text("No earnings yet"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: earnings.length,
      itemBuilder: (_, i) {
        final e = earnings[i];
        if (selectedJobId != null && e.jobId != selectedJobId) {
          return const SizedBox.shrink();
        }

        final jobName = e.jobId == 0
            ? "Other Income"
            : jobs.firstWhere((j) => j.id == e.jobId).title;

        return Card(
          child: ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text("£${e.amount.toStringAsFixed(2)}"),
            subtitle: Text(
              "$jobName • ${DateFormat('MMM dd, yyyy').format(e.dateEarned)}",
            ),
          ),
        );
      },
    );
  }
}
