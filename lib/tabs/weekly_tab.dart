import 'package:flutter/material.dart';

class WeeklyTab extends StatelessWidget {
  final void Function(bool)? onLoadingChanged;
  const WeeklyTab({Key? key, this.onLoadingChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example weekly list; in real app replace with API data and charts (fl_chart)
    final days = List.generate(7, (i) => {
          'weekday': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i % 7],
          'desc': 'Sunny',
          'min': 15 + i,
          'max': 25 + i,
        });

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Weekly forecast', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: ListView.separated(
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final d = days[i];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Text('☀️', style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(d['weekday'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(d['desc'] as String),
                        ]),
                      ),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('Min: ${(d['min'] as int).toString()}°C', style: const TextStyle(color: Colors.blue)),
                        const SizedBox(height: 4),
                        Text('Max: ${(d['max'] as int).toString()}°C', style: const TextStyle(color: Colors.red)),
                      ]),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
