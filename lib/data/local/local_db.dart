import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pfm/data/models/spending.dart';

import '../models/expense.dart';
import '../models/category.dart';
import '../models/task.dart';
import '../models/job.dart';
import '../models/goal.dart';
import '../models/earning.dart';
import '../models/user.dart';
import '../models/shift.dart'; // ✅ ADD THIS
import '../models/Spending.dart'; // ✅ ADD THIS

class LocalDb {
  static Isar? _isar;

  /// Safe access
  static Isar get isar {
    if (_isar == null) {
      throw Exception('Isar is not initialized. Call LocalDb.init() first.');
    }
    return _isar!;
  }

  static Future<void> init() async {
    if (_isar != null) return;

    try {
      if (kIsWeb) {
        _isar = await Isar.open(
          [
            ExpenseSchema,
            CategorySchema,
            TaskSchema,
            UserSchema,
            JobSchema,
            GoalSchema,
            EarningSchema,
            ShiftSchema,
            SpendingSchema, // ✅ REQUIRED
          ],
          directory: '',
        );
      } else {
        final dir = await getApplicationDocumentsDirectory();
        _isar = await Isar.open(
          [
            ExpenseSchema,
            CategorySchema,
            TaskSchema,
            UserSchema,
            JobSchema,
            GoalSchema,
            EarningSchema,
            ShiftSchema, // ✅ REQUIRED
          ],
          directory: dir.path,
        );
      }

      await _seedCategoriesIfNeeded();
    } catch (e) {
      debugPrint('❌ Isar init error: $e');
      rethrow;
    }
  }

  static Future<void> _seedCategoriesIfNeeded() async {
    final count = await isar.categorys.count();
    if (count > 0) return;

    await isar.writeTxn(() async {
      await isar.categorys.putAll([
        Category(name: 'Food'),
        Category(name: 'Transport'),
        Category(name: 'Bills'),
        Category(name: 'Shopping'),
        Category(name: 'Other'),
      ]);
    });
  }
}
