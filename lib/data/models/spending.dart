import 'package:isar/isar.dart';

part 'spending.g.dart';

@collection
class Spending {
  Id id = Isar.autoIncrement;

  late double amount;
  late String description;
  late int categoryId;
  late DateTime date;
}
