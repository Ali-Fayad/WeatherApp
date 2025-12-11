import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../models/user.dart';
import 'main_app.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isRegister = false;
  bool _isLoading = false;

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _submit() async {
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text;
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter username and password')));
      return;
    }
    setState(() { _isLoading = true; });

    final salt = 'STATIC_SALT_FOR_ASSIGNMENT';
    final hash = _hashPassword(password, salt);

    final db = DBHelper();
    try {
      if (_isRegister) {
        final existing = await db.getUserByUsername(username);
        if (existing != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username already exists')));
        } else {
          await db.insertUser(User(username: username, passwordHash: hash));
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainApp()));
        }
      } else {
        final user = await db.getUserByUsername(username);
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not found')));
        } else if (user.passwordHash == hash) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainApp()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect password')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegister ? 'Register' : 'Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'Username')),
                  const SizedBox(height: 8),
                  TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                  const SizedBox(height: 12),
                  if (_isLoading) const CircularProgressIndicator(),
                  if (!_isLoading) Row(
                    children: [
                      ElevatedButton(onPressed: _submit, child: Text(_isRegister ? 'Register' : 'Login')),
                      const SizedBox(width: 12),
                      TextButton(onPressed: () => setState(() => _isRegister = !_isRegister), child: Text(_isRegister ? 'Have account? Login' : 'Create account')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
