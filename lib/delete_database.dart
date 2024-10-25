import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:ui' as ui;

Future<void> deleteDatabaseFile() async {
  // Get the path to the database
  String databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'user_database.db');

  // Check if the file exists and delete it
  if (await File(path).exists()) {
    await File(path).delete();
    print('Database deleted successfully.');
  } else {
    print('Database file not found.');
  }
}

void main() async {
  await deleteDatabaseFile();
}
