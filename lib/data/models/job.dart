import 'package:isar/isar.dart';

part 'job.g.dart';

@Collection()
class job {
  Id id = Isar.autoIncrement;

  late String title;
  late double payRate;
  late String description;

  String? startTime;
  String? endTime;
  DateTime? date;
}
