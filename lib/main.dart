import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';


import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'data/db_helper.dart';
import 'screens/auth_screen.dart';
import 'screens/main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    
    sqfliteFfiInit();
    
    databaseFactory = databaseFactoryFfi;
  }

  
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key}) : super(key: key);

  Future<bool> _hasUser() async {
    final db = DBHelper();
    final user = await db.getAnyUser(); 
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
