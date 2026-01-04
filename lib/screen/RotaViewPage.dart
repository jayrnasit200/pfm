import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:FINEXA/data/local/local_db.dart';
import 'package:FINEXA/data/models/shift.dart';
import 'package:FINEXA/screen/rota.dart';

class RotaViewPage extends StatefulWidget {
  final int jobId;
  const RotaViewPage(this.jobId, {super.key});

  @override
  State<RotaViewPage> createState() => _RotaViewPageState();
}

class _RotaViewPageState extends State<RotaViewPage> {
  bool isLoading = true;
  List<Shift> rotaRecords = [];

  @override
  void initState() {
    super.initState();
    _loadRota();
  }

  // ───────────────── LOAD FROM LOCAL DB ─────────────────

  Future<void> _loadRota() async {
    final db = LocalDb.isar;

    final data = await db.shifts
        .filter()
        .jobIdEqualTo(widget.jobId)
        .sortByDate()
        .findAll();

    setState(() {
      rotaRecords = data;
      isLoading = false;
    });
  }

  // ───────────────── TIME HELPERS ─────────────────

  TimeOfDay _parseTime(String t) {
    final p = t.split(":");
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  String _formatTime(TimeOfDay t) =>
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

  // ───────────────── EDIT / COMPLETE ─────────────────

  void _editShift(Shift shift) {
    TimeOfDay start = _parseTime(shift.startTime);
    TimeOfDay end = _parseTime(shift.endTime);
    bool isCompleted = shift.status == "completed";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Edit Shift",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  ListTile(
                    title: const Text("Start Time"),
                    subtitle: Text(start.format(context)),
                    onTap: () async {
                      final picked = await showTimePicker(
                          context: context, initialTime: start);
                      if (picked != null) setModal(() => start = picked);
                    },
                  ),
                  ListTile(
                    title: const Text("End Time"),
                    subtitle: Text(end.format(context)),
                    onTap: () async {
                      final picked = await showTimePicker(
                          context: context, initialTime: end);
                      if (picked != null) setModal(() => end = picked);
                    },
                  ),
                  SwitchListTile(
                    title: const Text("Mark as Completed"),
                    value: isCompleted,
                    onChanged: (v) => setModal(() => isCompleted = v),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final db = LocalDb.isar;

                        await db.writeTxn(() async {
                          shift
                            ..startTime = _formatTime(start)
                            ..endTime = _formatTime(end)
                            ..status = isCompleted ? "completed" : "planned";
                          await db.shifts.put(shift);
                        });

                        Navigator.pop(context);
                        _loadRota();
                      },
                      child: const Text("Save Changes"),
                    ),
                  ),
                  const SizedBox(height: 20),
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
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("Shift Schedule",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => rotaScreen(widget.jobId)),
            ).then((_) => _loadRota()),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : rotaRecords.isEmpty
              ? const Center(child: Text("No shifts found"))
              : RefreshIndicator(
                  onRefresh: _loadRota,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: rotaRecords.length,
                    itemBuilder: (_, i) => _buildShiftCard(rotaRecords[i]),
                  ),
                ),
    );
  }

  Widget _buildShiftCard(Shift shift) {
    final bool isCompleted = shift.status == "completed";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy').format(shift.date),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isCompleted ? "COMPLETED" : "PLANNED",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.schedule_rounded,
                color: isCompleted ? Colors.green : Colors.blueAccent,
                size: 26,
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _timeColumn("START", shift.startTime),
              const Icon(Icons.arrow_forward_rounded, size: 16),
              _timeColumn("END", shift.endTime),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.edit, size: 20),
              color: Colors.blueAccent,
              onPressed: () => _editShift(shift),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeColumn(String label, String time) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(time,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
