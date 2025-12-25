// TODO Implement this library.
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../data/local/local_db.dart';
import '../data/models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final Isar _isar = LocalDb.isar;

  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  /// Load all expenses (call on app start)
  Future<void> loadExpenses() async {
    _expenses = await _isar.expenses.where().sortByDateDesc().findAll();
    notifyListeners();
  }

  /// Add new expense
  Future<void> addExpense(Expense expense) async {
    await _isar.writeTxn(() async {
      await _isar.expenses.put(expense);
    });
    await loadExpenses();
  }

  /// Update existing expense
  Future<void> updateExpense(Expense expense) async {
    expense.touch();
    await _isar.writeTxn(() async {
      await _isar.expenses.put(expense);
    });
    await loadExpenses();
  }

  /// Delete expense
  Future<void> deleteExpense(Id id) async {
    await _isar.writeTxn(() async {
      await _isar.expenses.delete(id);
    });
    await loadExpenses();
  }
}
