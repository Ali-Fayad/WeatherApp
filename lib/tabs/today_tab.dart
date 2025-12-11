import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/today_weather_service.dart';
import '../services/geocoding_service.dart';

class TodayTab extends StatelessWidget {
  final CitySuggestion? city;

  const TodayTab({Key? key, required this.city}) : super(key: key);

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

    return FutureBuilder<List<HourlyWeather>>(
      future: TodayWeatherService.fetchTodayWeather(
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

        final List<HourlyWeather> today = snapshot.data ?? [];

        if (today.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No data available for today.',
                style: TextStyle(fontSize: 16, color: Colors.red[700]),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

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
            // Temperature chart for today using fl_chart
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
                      'Temperature today',
                      style: TextStyle(
                        color: accentText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: LineChart(
                        _buildLineChartData(today, accentText),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Hour of day',
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
                'Today\'s hourly forecast',
                style: TextStyle(
                  color: accentText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // Scrollable list with time, temperature, condition, wind speed
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: today.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final hour = today[i];
                  final temp = hour.temperature;
                  final wind = hour.windSpeed;
                  final desc = hour.description;

                  final timeLabel =
                      "${hour.time.hour.toString().padLeft(2, '0')}:00";

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: pillColor.withOpacity(.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Text(_emojiFor(desc),
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                timeLabel,
                                style: const TextStyle(
                                  color: accentText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                desc,
                                style: const TextStyle(color: accentText),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${temp.toStringAsFixed(1)} °C",
                              style: const TextStyle(
                                color: accentText,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.air,
                                    size: 16, color: accentText),
                                const SizedBox(width: 4),
                                Text(
                                  "${wind.toStringAsFixed(1)} km/h",
                                  style:
                                      const TextStyle(color: accentText),
                                ),
                              ],
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

  LineChartData _buildLineChartData(
      List<HourlyWeather> hours, Color accentText) {
    final spots = <FlSpot>[];

    double minTemp = double.infinity;
    double maxTemp = -double.infinity;

    for (int i = 0; i < hours.length; i++) {
      final h = hours[i];
      final hour = h.time.hour.toDouble();
      final temp = h.temperature;
      spots.add(FlSpot(hour, temp));

      if (temp < minTemp) minTemp = temp;
      if (temp > maxTemp) maxTemp = temp;
    }

    if (minTemp == double.infinity) {
      minTemp = 0;
      maxTemp = 1;
    }

    final rangePadding = 1.0;

    return LineChartData(
      minX: hours.first.time.hour.toDouble(),
      maxX: hours.last.time.hour.toDouble(),
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
            interval: 3,
            getTitlesWidget: (value, meta) => Text(
              '${value.toInt().toString().padLeft(2, '0')}h',
              style: TextStyle(color: accentText, fontSize: 10),
            ),
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: accentText,
          barWidth: 3,
          dotData: FlDotData(show: false),
        ),
      ],
    );
  }
}
