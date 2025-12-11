import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// If you use sqflite_common_ffi on desktop, import it:
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'data/db_helper.dart';
import 'screens/auth_screen.dart';
import 'screens/main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite ffi for desktop platforms.
  // Do NOT do this for web; kIsWeb prevents it.
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    // Initialize ffi implementation
    sqfliteFfiInit();
    // Set the global databaseFactory to the ffi one so openDatabase works
    databaseFactory = databaseFactoryFfi;
  }

  // Now safe to open DB or call DB helpers that use global openDatabase
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key}) : super(key: key);

  Future<bool> _hasUser() async {
    final db = DBHelper();
    final user = await db.getAnyUser(); // safe now: databaseFactory initialized when needed
    return user != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.indigo, scaffoldBackgroundColor: const Color(0xFFF5F7FB)),
      home: FutureBuilder<bool>(
        future: _hasUser(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final hasUser = snap.data ?? false;
          return hasUser ? const MainApp() : const AuthScreen();
        },
      ),
    );
  }
}
