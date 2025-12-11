import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _unit = 'Celsius';
  bool _notifications = true;
  bool _dailySummary = false;
  String _updateFrequency = 'Hourly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Units'),
            trailing: DropdownButton<String>(
              value: _unit,
              items: const [
                DropdownMenuItem(value: 'Celsius', child: Text('°C')),
                DropdownMenuItem(value: 'Fahrenheit', child: Text('°F')),
              ],
              onChanged: (v) => setState(() => _unit = v!),
            ),
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            value: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
          ),
          CheckboxListTile(
            title: const Text('Daily summary email (example Checkbox)'),
            value: _dailySummary,
            onChanged: (v) => setState(() => _dailySummary = v ?? false),
          ),
          const Divider(),
          const Text('Update frequency (RadioListTile example):'),
          RadioListTile<String>(
            title: const Text('Every 30 minutes'),
            value: '30min',
            groupValue: _updateFrequency,
            onChanged: (v) => setState(() => _updateFrequency = v ?? 'Hourly'),
            selected: _updateFrequency == '30min',
          ),
          RadioListTile<String>(
            title: const Text('Hourly'),
            value: 'Hourly',
            groupValue: _updateFrequency,
            onChanged: (v) => setState(() => _updateFrequency = v ?? 'Hourly'),
            selected: _updateFrequency == 'Hourly',
          ),
        ],
      ),
    );
  }
}
