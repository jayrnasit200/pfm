import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:pfm/data/local/local_db.dart';
import 'package:pfm/data/models/shift.dart';

class rotaScreen extends StatefulWidget {
  final int id; // jobId
  const rotaScreen(this.id, {super.key});

  @override
  State<rotaScreen> createState() => _rotaScreenState();
}

class _rotaScreenState extends State<rotaScreen> {
  late DateTime selectedWeekStart;

  final List<String> dayNames = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  Map<String, TimeOfDay?> startTimes = {};
  Map<String, TimeOfDay?> endTimes = {};

  /// Existing shifts by date (yyyy-mm-dd)
  Map<DateTime, Shift> existingShifts = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedWeekStart = _dateOnly(
      now.subtract(Duration(days: now.weekday - 1)),
    );
    _initWeek();
    _loadExistingShifts();
  }

  void _initWeek() {
    startTimes = {for (var d in dayNames) d: null};
    endTimes = {for (var d in dayNames) d: null};
    existingShifts.clear();
  }

  // ───────────────── DATE & TIME HELPERS ─────────────────

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  TimeOfDay _parseTime(String t) {
    final p = t.split(":");
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  String _formatTime(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  String _formatDate(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  // ───────────────── LOAD SHIFTS FOR WEEK ─────────────────

  Future<void> _loadExistingShifts() async {
    final db = LocalDb.isar;

    final start = selectedWeekStart;
    final end = start.add(const Duration(days: 7));

    final shifts = await db.shifts
        .filter()
        .jobIdEqualTo(widget.id)
        .and()
        .dateBetween(start, end)
        .findAll();

    _initWeek();

    for (final s in shifts) {
      final index = s.date.weekday - 1;
      final day = dayNames[index];

      startTimes[day] = _parseTime(s.startTime);
      endTimes[day] = _parseTime(s.endTime);
      existingShifts[_dateOnly(s.date)] = s;
    }

    setState(() {});
  }

  // ───────────────── WEEK NAVIGATION ─────────────────

  void _changeWeek(int offsetDays) {
    setState(() {
      selectedWeekStart =
          _dateOnly(selectedWeekStart.add(Duration(days: offsetDays)));
    });
    _loadExistingShifts();
  }

  // ───────────────── TIME PICKER ─────────────────

  Future<void> _pickTime(String day, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (startTimes[day] ?? const TimeOfDay(hour: 9, minute: 0))
          : (endTimes[day] ?? const TimeOfDay(hour: 17, minute: 0)),
    );

    if (picked == null) return;

    if (!isStart && startTimes[day] != null) {
      if (_toMinutes(picked) <= _toMinutes(startTimes[day]!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("End time must be after start time"),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    setState(() {
      if (isStart) {
        startTimes[day] = picked;
        if (endTimes[day] != null &&
            _toMinutes(endTimes[day]!) <= _toMinutes(picked)) {
          endTimes[day] = null;
        }
      } else {
        endTimes[day] = picked;
      }
    });
  }

  // ───────────────── SAVE / UPDATE ─────────────────

  Future<void> _saveRota() async {
    final db = LocalDb.isar;

    await db.writeTxn(() async {
      for (int i = 0; i < dayNames.length; i++) {
        final day = dayNames[i];
        if (startTimes[day] != null && endTimes[day] != null) {
          final date = _dateOnly(selectedWeekStart.add(Duration(days: i)));

          Shift shift = existingShifts[date] ??
              (Shift()
                ..jobId = widget.id
                ..date = date
                ..status = "planned");

          shift
            ..startTime = _formatTime(startTimes[day]!)
            ..endTime = _formatTime(endTimes[day]!);

          await db.shifts.put(shift);
        }
      }
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Weekly rota saved ✅"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  // ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("Weekly Planner",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _weekHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: dayNames.length,
              itemBuilder: (_, i) => _dayCard(dayNames[i], i),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomButton(),
    );
  }

  Widget _weekHeader() {
    final end = selectedWeekStart.add(const Duration(days: 6));
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeWeek(-7),
          ),
          Column(
            children: [
              const Text("WEEK",
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              Text(
                "${_formatDate(selectedWeekStart)} - ${_formatDate(end)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeWeek(7),
          ),
        ],
      ),
    );
  }

  Widget _dayCard(String day, int index) {
    final date = selectedWeekStart.add(Duration(days: index));
    final hasShift = startTimes[day] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(_formatDate(date),
                    style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          ),
          _timeBox(day, true),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Icon(Icons.arrow_forward_rounded, size: 14),
          ),
          _timeBox(day, false),
          if (hasShift)
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.redAccent),
              onPressed: () => setState(() {
                startTimes[day] = null;
                endTimes[day] = null;
              }),
            ),
        ],
      ),
    );
  }

  Widget _timeBox(String day, bool isStart) {
    final time = isStart ? startTimes[day] : endTimes[day];
    return InkWell(
      onTap: () => _pickTime(day, isStart),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: time == null
              ? Colors.grey.shade100
              : Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          time == null ? "--:--" : _formatTime(time),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: time == null ? Colors.grey : Colors.blueAccent,
          ),
        ),
      ),
    );
  }

  Widget _bottomButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: _saveRota,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          minimumSize: const Size(double.infinity, 56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          "Save Weekly Schedule",
          style: TextStyle(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
