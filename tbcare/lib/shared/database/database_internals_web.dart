void initDatabaseFactory() {
  // SQLite (sqflite) is not supported on Flutter Web.
  // The app must run on Android/iOS/Windows/macOS/Linux, or the database
  // layer must be migrated to a web-supported storage solution.
  throw UnsupportedError(
    'Flutter Web is not supported for sqflite-based storage in this app.',
  );
}
