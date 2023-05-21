import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDB();
    return _database;
  }

  Future<Database> _initDB() async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    var path = join(documentsDirectory.path, 'medication.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE Medication (id INTEGER PRIMARY KEY, name TEXT, startDate TEXT, endDate TEXT, timesPerDay INTEGER, dose INTEGER, timing TEXT, type TEXT)');

    await db.execute('''
      CREATE TABLE MedicationDose (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicationId INTEGER,
        dose INTEGER,
        date TEXT
      )
    ''');
  }

  Future<void> insertMedication(Map<String, dynamic> medication) async {
    final db = await database;
    await db?.insert('Medication', medication);
  }

  Future<List<Map<String, Object?>>>? getMedications() async {
    final db = await database;
    return db?.query('Medication') as Future<List<Map<String, Object?>>>;
  }

  Future<Map<String, dynamic>?> getMedicationById(String id) async {
  final db = await database;
  final List<Map<String, dynamic>>? results = await db?.query(
    'Medication',
    where: 'id = ?',
    whereArgs: [id],
  );
    return results?.isNotEmpty == true ? results!.first : null;;
  }

  Future<void> updateMedication(Map<String, dynamic> medication) async {
    final db = await database;
    await db?.update('Medication', medication, where: 'id = ?', whereArgs: [medication['id']]);
  }

  Future<void> deleteMedication(int id) async {
    final db = await database;
    await db?.delete('Medication', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertOrUpdateMedicationDose(Map<String, dynamic> medicationDose) async {
    final db = await database;
    
    final medicationId = medicationDose['medicationId'];
    
    final List<Map<String, dynamic>>? existingRecords = await db?.query(
      'MedicationDose',
      where: 'medicationId = ?',
      whereArgs: [medicationId],
    );
    
    if (existingRecords != null && existingRecords.isNotEmpty) {
      await db?.update(
        'MedicationDose',
        medicationDose,
        where: 'medicationId = ?',
        whereArgs: [medicationId],
      );
    } else {
      await db?.insert('MedicationDose', medicationDose);
    }
  }

  Future<int?> getMedicationDose(int medicationId) async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(Duration(days: 1)).subtract(Duration(microseconds: 1));

    final result = await db!.query(
      'MedicationDose',
      where: 'medicationId = ? AND date >= ? AND date < ?',
      whereArgs: [medicationId, startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    if (result.isNotEmpty) {
      return result.first['dose'] as int;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMedicationDosesBetween(DateTime start, DateTime end) async {
    final db = await database;
    
    final result = await db!.query(
      'MedicationDose',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );

    return result;
  }

  Future<void> saveMedication(Map<String, dynamic> medication) async {
    Database? db = await this.database;
    if (medication['id'] != null) {
      await this.updateMedication(medication);
    } else {
      await this.insertMedication(medication);
    }
  }
}

