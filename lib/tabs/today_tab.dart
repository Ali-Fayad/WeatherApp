import 'package:flutter/material.dart';

class TodayTab extends StatelessWidget {
  final void Function(bool)? onLoadingChanged;
  const TodayTab({Key? key, this.onLoadingChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hours = List.generate(12, (i) => {
          'time': '${i + 8}:00',
          'temp': 15 + i.toDouble(),
          'desc': 'Clear',
        });

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Today\'s hourly forecast', style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(
          child: ListView.separated(
            itemCount: hours.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final h = hours[i];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Text('🌤', style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(h['time'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(h['desc'] as String),
                      ]),
                    ),
                    Text('${(h['temp'] as double).toStringAsFixed(1)} °C', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
