import 'package:isar/isar.dart';

part 'job.g.dart';

@collection
class Job {
  Id id = Isar.autoIncrement;

  late String title;
  late double payRate;
  String? description;

  String? startTime;
  String? endTime;
  DateTime? date;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  /// ✅ THIS CONSTRUCTOR IS THE FIX
  Job({
    required this.title,
    required this.payRate,
    this.description,
    this.startTime,
    this.endTime,
    this.date,
  });
}
