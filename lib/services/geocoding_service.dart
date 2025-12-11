import 'dart:async';
import '../models/city.dart';

class CitySuggestionsResult {
  final List<City> suggestions;
  final String? error;
  CitySuggestionsResult(this.suggestions, [this.error]);
}

/// Simple mock geocoding service to keep the example self-contained.
/// Replace with your real API calls as needed.
class GeocodingService {
  static Future<CitySuggestionsResult> fetchCitySuggestions(String query) async {
    await Future.delayed(const Duration(milliseconds: 500)); // simulate latency
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return CitySuggestionsResult([], null);
    if (q.contains('nowhere') || q.contains('xyznotfound')) {
      return CitySuggestionsResult([], 'No city found matching "$query"');
    }

    // Very simple fake suggestions
    final suggestions = <City>[
      City(name: query, region: 'Region', country: 'Country', lat: 12.34, lon: 56.78),
      City(name: '$query City', region: 'Region2', country: 'Country2', lat: 21.43, lon: 65.87),
    ];
    return CitySuggestionsResult(suggestions, null);
  }
}
