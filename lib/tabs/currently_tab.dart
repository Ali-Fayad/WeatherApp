import 'package:flutter/material.dart';
import '../services/current_weather_service.dart';
import '../services/geocoding_service.dart';

class CurrentlyTab extends StatelessWidget {
  final CitySuggestion? city;

  const CurrentlyTab({Key? key, required this.city}) : super(key: key);

  // Map simple description to emoji as image replacement
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

    return FutureBuilder<CurrentWeather?>(
      future: CurrentWeatherService.fetchCurrentWeather(
        city!.latitude,
        city!.longitude,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
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

        final weather = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${city!.name}, ${city!.region}, ${city!.country}",
                style: const TextStyle(
                  color: accentText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Emoji instead of network image
              Text(
                _emojiFor(weather.description),
                style: const TextStyle(fontSize: 96),
              ),
              const SizedBox(height: 16),
              // Big temperature like the HTML hero
              Text(
                "${weather.temperature.round()}°",
                style: const TextStyle(
                  color: pillColor,
                  fontSize: 96,
                  fontWeight: FontWeight.w900,
                  height: 0.9,
                ),
              ),
              const SizedBox(height: 32),
              // Info card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: pillColor.withOpacity(.5),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(25, 0, 0, 0),
                      blurRadius: 30,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      weather.description,
                      style: const TextStyle(
                        color: accentText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.air, color: accentText),
                        const SizedBox(width: 8),
                        Text(
                          'Wind: ${weather.windSpeed.toStringAsFixed(1)} km/h',
                          style: const TextStyle(
                            color: accentText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
