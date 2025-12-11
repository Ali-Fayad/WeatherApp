import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class GeocodingService {
  static Future<GeocodingResult> fetchCitySuggestions(String query) async {
    if (query.isEmpty) {
      return GeocodingResult(suggestions: [], error: null);
    }

    try {
      final url = Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=10');

      final response = await http.get(url);

      if (response.statusCode != 200) {
        return GeocodingResult(
          suggestions: [],
          error: 'Connection to the API failed. Please try again.',
        );
      }

      final data = json.decode(response.body);

      if (data['results'] == null) {
        return GeocodingResult(
          suggestions: [],
          error: 'City name is invalid. Please enter a valid city name.',
        );
      }

      final suggestions = (data['results'] as List)
          .map((item) => CitySuggestion(
                name: item['name'] ?? '',
                region: item['admin1'] ?? '',
                country: item['country'] ?? '',
                latitude: item['latitude'],
                longitude: item['longitude'],
              ))
          .toList();

      return GeocodingResult(suggestions: suggestions, error: null);
    } catch (e) {
      return GeocodingResult(
        suggestions: [],
        error: 'Connection to the API failed. Please check your internet connection.',
      );
    }
  }

  // New: search using WeatherAPI with lat,lon (you must put your own API key here)
  static Future<GeocodingResult> fetchCitySuggestionsFromLatLon(
      double lat, double lon) async {
    final apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';// TODO: replace with your real WeatherAPI key
    final query = '$lat,$lon';

    try {
      final url = Uri.parse(
          'https://api.weatherapi.com/v1/search.json?key=$apiKey&q=$query');

      final response = await http.get(url);

      if (response.statusCode != 200) {
        return GeocodingResult(
          suggestions: [],
          error: 'Connection to the API failed. Please try again.',
        );
      }

      final data = json.decode(response.body);
      if (data is! List || data.isEmpty) {
        return GeocodingResult(
          suggestions: [],
          error: 'No matching city found for your location.',
        );
      }

      final suggestions = data
          .map<CitySuggestion>((item) => CitySuggestion(
                name: item['name'] ?? '',
                region: item['region'] ?? '',
                country: item['country'] ?? '',
                latitude: (item['lat'] as num).toDouble(),
                longitude: (item['lon'] as num).toDouble(),
              ))
          .toList();

      return GeocodingResult(suggestions: suggestions, error: null);
    } catch (e) {
      return GeocodingResult(
        suggestions: [],
        error: 'Connection to the API failed. Please check your internet connection.',
      );
    }
  }
}

class GeocodingResult {
  final List<CitySuggestion> suggestions;
  final String? error;

  GeocodingResult({required this.suggestions, required this.error});
}

class CitySuggestion {
  final String name;
  final String region;
  final String country;
  final double latitude;
  final double longitude;

  CitySuggestion({
    required this.name,
    required this.region,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() => '$name, $region, $country';
}
