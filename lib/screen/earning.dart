import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:pfm/NavigationBar.dart';
import 'package:pfm/screen/new_job.dart';
import 'package:pfm/data/local/local_db.dart';
import 'package:pfm/data/models/earning.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pfm/data/models/job.dart';
import 'package:intl/intl.dart';

class EarningScreen extends StatefulWidget {
  const EarningScreen({super.key});

  @override
  State<EarningScreen> createState() => _EarningScreenState();
}

class _EarningScreenState extends State<EarningScreen> {
  // Calendar State
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat =
      CalendarFormat.twoWeeks; // Start compact for Earnings

  // Data State
  String? _selectedJob = "all";
  List<dynamic> jobList = [];
  List<Earning> earningsList = [];

  final Color primaryBlue = Colors.blue;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final db = LocalDb.isar;
    final jobs = await db.jobs.where().findAll();
    setState(() {
      jobList = jobs;
    });
    _loadEarnings(null);
  }

  Future<void> _loadEarnings(int? jobId) async {
    final db = LocalDb.isar;
    final earnings = jobId != null
        ? await db.earnings.filter().jobIdEqualTo(jobId).findAll()
        : await db.earnings.where().findAll();

    setState(() {
      earningsList = earnings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const NavigationBars("Earning"),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Job Filter
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Earnings",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildJobDropdown(),
                ],
              ),
            ),

            // Expandable Calendar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _buildCalendar(),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Income History",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(Icons.trending_up_rounded,
                      color: Colors.green.withOpacity(0.7)),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Scrollable List
            Expanded(child: _buildEarningsSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildJobDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedJob,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryBlue),
          items: [
            const DropdownMenuItem(
                value: "all", child: Text("All Revenue Sources")),
            ...jobList.map((job) => DropdownMenuItem(
                  value: job.title,
                  child: Text(job.title),
                )),
            const DropdownMenuItem(
              value: "Add New Job",
              child: Text("➕ Add New Job",
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ],
          onChanged: (String? newValue) {
            if (newValue == "Add New Job") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewJobScreen()),
              ).then((_) => _loadJobs());
            } else {
              setState(() => _selectedJob = newValue);
              if (newValue == "all") {
                _loadEarnings(null);
              } else {
                final job = jobList.firstWhere((j) => j.title == newValue);
                _loadEarnings(job.id);
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _selectedDay,

      // LOGIC: These lines handle the expansion/contraction
      calendarFormat: _calendarFormat,
      onFormatChanged: (format) => setState(() => _calendarFormat = format),
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
        CalendarFormat.twoWeeks: 'Compact',
      },

      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() => _selectedDay = selectedDay);
      },

      // Theming
      calendarStyle: CalendarStyle(
        selectedDecoration:
            BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
        todayDecoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.3), shape: BoxShape.circle),
        markerDecoration:
            BoxDecoration(color: Colors.green, shape: BoxShape.circle),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonDecoration: BoxDecoration(
          color: primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        formatButtonTextStyle:
            TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEarningsSection() {
    if (earningsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 60, color: Colors.grey[200]),
            const SizedBox(height: 10),
            const Text("No earnings found for this filter",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: earningsList.length,
      itemBuilder: (context, index) {
        final earning = earningsList[index];
        return _buildEarningCard(earning);
      },
    );
  }

  Widget _buildEarningCard(Earning earning) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.add_chart_rounded, color: Colors.green),
        ),
        title: Text(
          earning.category,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(DateFormat('MMM dd, yyyy').format(earning.dateEarned)),
        trailing: Text(
          "+ £${earning.amount.toStringAsFixed(2)}",
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () {
          // Handle tap logic
        },
      ),
    );
  }
}
