import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrentWeather {
  final double temperature;
  final double windSpeed;
  final String description;

  CurrentWeather({
    required this.temperature,
    required this.windSpeed,
    required this.description,
  });
}

class CurrentWeatherService {
  static Future<CurrentWeather?> fetchCurrentWeather(
      double lat, double lon) async {
    try {
      final url = Uri.parse("https://api.open-meteo.com/v1/forecast?"
          "latitude=$lat&longitude=$lon&current_weather=true");

      final response = await http.get(url);

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);

      final current = data["current_weather"];

      return CurrentWeather(
        temperature: current["temperature"],
        windSpeed: current["windspeed"],
        description: _mapWeatherCode(current["weathercode"]),
      );
    } catch (e) {
      return null;
    }
  }

  static String _mapWeatherCode(int code) {
    if (code == 0) return "Clear sky";
    if ([1, 2, 3].contains(code)) return "Cloudy";
    if ([51, 61, 80].contains(code)) return "Rainy";
    return "Unknown";
  }
}
