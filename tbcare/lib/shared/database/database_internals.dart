// Conditional export selects implementation based on platform (IO vs Web).
export 'database_internals_io.dart'
    if (dart.library.html) 'database_internals_web.dart';
