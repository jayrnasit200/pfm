import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:pfm/NavigationBar.dart';
import 'package:pfm/screen/new_job.dart';
import 'package:pfm/data/local/local_db.dart';
import 'package:pfm/data/models/earning.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pfm/data/models/job.dart';

class EarningScreen extends StatefulWidget {
  const EarningScreen({super.key});

  @override
  State<EarningScreen> createState() => _EarningScreenState();
}

class _EarningScreenState extends State<EarningScreen> {
  DateTime _selectedDay = DateTime.now();
  String? _selectedJob = "all";

  List<dynamic> jobList = [];
  List<Earning> earningsList = [];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  /// Load jobs from local DB
  Future<void> _loadJobs() async {
    final db = LocalDb.isar;
    final jobs = await db.jobs.where().findAll(); // ✅ correct in Isar v3
    setState(() {
      jobList = jobs;
    });
    _loadEarnings(null); // Load all earnings initially
  }

  /// Load earnings, optionally filtered by job
  Future<void> _loadEarnings(int? jobId) async {
    final db = LocalDb.isar;

    final earnings = jobId != null
        ? await db.earnings.filter().jobIdEqualTo(jobId).findAll()
        : await db.earnings.where().findAll(); // ✅ use where() for all

    setState(() {
      earningsList = earnings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBars("Earning"),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildJobDropdown(),
              const SizedBox(height: 20),
              _buildCalendar(),
              const SizedBox(height: 20),
              Expanded(child: _buildEarningsSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobDropdown() {
    return DropdownButton<String>(
      value: _selectedJob,
      isExpanded: true,
      items: [
        const DropdownMenuItem(
          value: "all",
          child: Text("All Jobs"),
        ),
        ...jobList.map((job) => DropdownMenuItem(
              value: job.title,
              child: Text(job.title),
            )),
        const DropdownMenuItem(
          value: "Add New Job",
          child: Text("➕ Add New Job"),
        ),
      ],
      onChanged: (String? newValue) {
        if (newValue == "Add New Job") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewJobScreen()),
          ).then((_) => _loadJobs()); // reload jobs after adding new
        } else {
          setState(() {
            _selectedJob = newValue;
          });

          if (newValue == "all") {
            _loadEarnings(null);
          } else {
            final job = jobList.firstWhere((j) => j.title == newValue);
            _loadEarnings(job.id);
          }
        }
      },
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _selectedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
        });
      },
    );
  }

  Widget _buildEarningsSection() {
    if (earningsList.isEmpty) {
      return const Center(child: Text("No earnings available"));
    }

    return ListView.builder(
      itemCount: earningsList.length,
      itemBuilder: (context, index) {
        final earning = earningsList[index];
        return _buildEarningCard(
          earning.category,
          earning.amount,
          earning.dateEarned,
        );
      },
    );
  }

  Widget _buildEarningCard(String category, double amount, DateTime date) {
    return InkWell(
      onTap: () {
        print("Earning tapped: $category, $amount, $date");
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Amount: £${amount.toStringAsFixed(2)}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Category: $category",
                    style: const TextStyle(color: Colors.grey)),
                Text("Date: ${date.toLocal().toString().split(' ')[0]}",
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
