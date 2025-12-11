import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/weekly_weather_service.dart';
import '../services/geocoding_service.dart';

class WeeklyTab extends StatelessWidget {
  final CitySuggestion? city;

  const WeeklyTab({Key? key, required this.city}) : super(key: key);

  String _emojiFor(String desc) {
    final d = desc.toLowerCase();
    if (d.contains('clear')) return '☀️';
    if (d.contains('rain')) return '🌧️';
    if (d.contains('snow')) return '❄️';
    if (d.contains('cloud')) return '☁️';
    if (d.contains('storm') || d.contains('thunder')) return '⛈️';
    return '🌤️';
  }

  @override
  Widget build(BuildContext context) {
    const pillColor = Color(0xFFFFF2E0);
    const accentText = Color(0xFF898AC4);

    if (city == null) {
      return Center(
        child: Text(
          "No city selected",
          style: TextStyle(color: accentText, fontWeight: FontWeight.w600),
        ),
      );
    }

    return FutureBuilder<List<DailyWeather>>(
      future: WeeklyWeatherService.fetchWeeklyWeather(
        city!.latitude,
        city!.longitude,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Connection to the API failed. Please check your internet connection.',
                style: TextStyle(fontSize: 16, color: Colors.red[700]),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final List<DailyWeather> weekly = snapshot.data ?? [];

        if (weekly.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Connection to the API failed. Please check your internet connection.',
                style: TextStyle(fontSize: 16, color: Colors.red[700]),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Only keep next 7 days
        final days = weekly.length > 7 ? weekly.sublist(0, 7) : weekly;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                "${city!.name}, ${city!.region}, ${city!.country}",
                style: const TextStyle(
                  color: accentText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Chart with min/max temperatures for each day
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: pillColor.withOpacity(.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Next 7 days temperatures',
                      style: TextStyle(
                        color: accentText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: LineChart(
                        _buildWeeklyChartData(days, accentText),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Day of week',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: accentText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: Text(
                'Weekly forecast',
                style: TextStyle(
                  color: accentText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: days.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final day = days[i];

                  final date = DateTime.parse(day.date);
                  final weekdayLabel = _weekdayShort(date.weekday);

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: pillColor.withOpacity(.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Text(_emojiFor(day.description),
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weekdayLabel,
                                style: const TextStyle(
                                  color: accentText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                day.description,
                                style: const TextStyle(color: accentText),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Min: ${day.minTemp.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Max: ${day.maxTemp.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _weekdayShort(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  LineChartData _buildWeeklyChartData(
      List<DailyWeather> days, Color accentText) {
    final minSpots = <FlSpot>[];
    final maxSpots = <FlSpot>[];

    double minTemp = double.infinity;
    double maxTemp = -double.infinity;

    for (int i = 0; i < days.length; i++) {
      final x = i.toDouble();
      final tMin = days[i].minTemp;
      final tMax = days[i].maxTemp;

      minSpots.add(FlSpot(x, tMin));
      maxSpots.add(FlSpot(x, tMax));

      if (tMin < minTemp) minTemp = tMin;
      if (tMax > maxTemp) maxTemp = tMax;
    }

    if (minTemp == double.infinity) {
      minTemp = 0;
      maxTemp = 1;
    }

    final rangePadding = 1.0;

    return LineChartData(
      minX: 0,
      maxX: (days.length - 1).toDouble(),
      minY: minTemp - rangePadding,
      maxY: maxTemp + rangePadding,
      gridData: FlGridData(show: true, drawVerticalLine: false),
      borderData: FlBorderData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text(
              '${value.toStringAsFixed(0)}°',
              style: TextStyle(color: accentText, fontSize: 10),
            ),
          ),
          axisNameWidget: const Padding(
            padding: EdgeInsets.only(right: 4.0),
            child: Text(
              'Temperature (°C)',
              style: TextStyle(fontSize: 11),
            ),
          ),
          axisNameSize: 24,
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            getTitlesWidget: (value, meta) {
              // Only show title when value is very close to an integer tick
              final index = value.round();
              if ((value - index).abs() > 0.01) {
                return const SizedBox.shrink();
              }
              if (index < 0 || index >= days.length) {
                return const SizedBox.shrink();
              }
              final date = DateTime.parse(days[index].date);
              return Text(
                _weekdayShort(date.weekday),
                style: TextStyle(color: accentText, fontSize: 10),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: minSpots,
          isCurved: true,
          color: Colors.blue, // min in blue
          barWidth: 3,
          dotData: FlDotData(show: false),
        ),
        LineChartBarData(
          spots: maxSpots,
          isCurved: true,
          color: Colors.red, // max in red
          barWidth: 3,
          dotData: FlDotData(show: false),
        ),
      ],
    );
  }
}
