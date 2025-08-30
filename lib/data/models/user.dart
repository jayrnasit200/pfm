// File: lib/data/models/user.dart
import 'package:isar/isar.dart';

part 'user.g.dart';

@Collection()
class User {
  Id id = Isar.autoIncrement; // Required by Isar

  late String name;
  late String email;
  late String password; // hash ideally, not plain text
  late DateTime createdAt;
}
