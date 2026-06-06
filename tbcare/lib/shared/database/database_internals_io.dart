import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart' show databaseFactory;

void initDatabaseFactory() {
  // Initialize ffi implementation for desktop (Windows/Mac/Linux)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
