import 'package:isar/isar.dart';

part 'shift.g.dart';

@Collection()
class Shift {
  Id id = Isar.autoIncrement;

  late int jobId;
  late DateTime date;
  late String startTime;
  late String endTime;
  late String status; // planned / completed / paid
}
