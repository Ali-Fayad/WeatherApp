import 'dart:convert';
import 'package:http/http.dart' as http;

class DailyWeather {
  final String date;
  final double minTemp;
  final double maxTemp;
  final String description;

  DailyWeather({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
  });
}

class WeeklyWeatherService {
  static Future<List<DailyWeather>> fetchWeeklyWeather(
      double lat, double lon) async {
    try {
      final url = Uri.parse(
          "https://api.open-meteo.com/v1/forecast?"
          "latitude=$lat&longitude=$lon"
          "&daily=temperature_2m_min,temperature_2m_max,weathercode");

      final response = await http.get(url);

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final daily = data["daily"];

      List<dynamic> dates = daily["time"];
      List<dynamic> tMin = daily["temperature_2m_min"];
      List<dynamic> tMax = daily["temperature_2m_max"];
      List<dynamic> codes = daily["weathercode"];

      List<DailyWeather> result = [];

      for (int i = 0; i < dates.length; i++) {
        result.add(DailyWeather(
          date: dates[i],
          minTemp: tMin[i],
          maxTemp: tMax[i],
          description: _mapWeatherCode(codes[i]),
        ));
      }

      return result;
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
