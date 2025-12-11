import 'dart:convert';
import 'package:http/http.dart' as http;

class HourlyWeather {
  final DateTime time; // changed to DateTime for easier filtering and charting
  final double temperature;
  final double windSpeed;
  final String description;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.windSpeed,
    required this.description,
  });
}

class TodayWeatherService {
  static Future<List<HourlyWeather>> fetchTodayWeather(
      double lat, double lon) async {
    try {
      final url = Uri.parse(
          "https://api.open-meteo.com/v1/forecast?"
          "latitude=$lat&longitude=$lon"
          "&hourly=temperature_2m,weathercode,windspeed_10m");

      final response = await http.get(url);

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final hours = data["hourly"];

      List<dynamic> times = hours["time"];
      List<dynamic> temps = hours["temperature_2m"];
      List<dynamic> codes = hours["weathercode"];
      List<dynamic> winds = hours["windspeed_10m"];

      final now = DateTime.now().toUtc();
      final todayDate = DateTime.utc(now.year, now.month, now.day);

      List<HourlyWeather> list = [];

      for (int i = 0; i < times.length; i++) {
        final dt = DateTime.parse(times[i]).toUtc();
        final dtDate = DateTime.utc(dt.year, dt.month, dt.day);

        // keep only entries for "today"
        if (dtDate == todayDate) {
          list.add(HourlyWeather(
            time: dt,
            temperature: (temps[i] as num).toDouble(),
            windSpeed: (winds[i] as num).toDouble(),
            description: _mapWeatherCode(codes[i]),
          ));
        }
      }

      return list;
    } catch (e) {
      return [];
    }
  }

  static String _mapWeatherCode(int code) {
    if (code == 0) return "Clear sky";
    if ([1, 2, 3].contains(code)) return "Cloudy";
    if ([51, 61, 80].contains(code)) return "Rainy";
    return "Unknown";
  }
}
