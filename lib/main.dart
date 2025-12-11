import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'tabs/currently_tab.dart';
import 'tabs/today_tab.dart';
import 'tabs/weekly_tab.dart';
import 'services/geocoding_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherHome(),
    );
  }
}

class WeatherHome extends StatefulWidget {
  @override
  _WeatherHomeState createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  String userInput = "";
  final TextEditingController _controller = TextEditingController();
  List<CitySuggestion> suggestions = [];
  String? errorMessage;

  CitySuggestion? selectedCity;

  void submitSearch(String value) async {
    final result = await GeocodingService.fetchCitySuggestions(value);
    setState(() {
      suggestions = result.suggestions.length > 5
          ? result.suggestions.sublist(0, 5)
          : result.suggestions;
      errorMessage = result.error;
    });
  }

  void onCitySelected(CitySuggestion city) {
    setState(() {
      selectedCity = city;
      userInput = '${city.name}, ${city.region}, ${city.country}';
      _controller.text = userInput;
      suggestions = [];
      errorMessage = null;
    });
  }

  Future<void> _fetchCityFromLatLon(double lat, double lon) async {
    try {
      final result =
          await GeocodingService.fetchCitySuggestionsFromLatLon(lat, lon);
      setState(() {
        if (result.error != null) {
          errorMessage = result.error;
          suggestions = [];
          selectedCity = null;
          return;
        }

        suggestions = result.suggestions.length > 5
            ? result.suggestions.sublist(0, 5)
            : result.suggestions;

        selectedCity = null;
      });
    } catch (_) {
      setState(() {
        errorMessage =
            'Connection to the API failed. Please check your internet connection.';
        suggestions = [];
        selectedCity = null;
      });
    }
  }

  void useGeolocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      setState(() {
        userInput =
            "Geolocation is not available, please enable it in your App settings.";
        _controller.clear();
      });
      return;
    }

    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await _fetchCityFromLatLon(position.latitude, position.longitude);

    setState(() {
      userInput = "${position.latitude}, ${position.longitude}";
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    const pillColor = Color(0xFFFFF2E0);
    const accentText = Color(0xFF898AC4);

    return DefaultTabController(
      length: 3,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/weather.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(72),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: useGeolocation,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.location_on,
                        color: pillColor,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: pillColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(Icons.search, color: accentText),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(
                                color: accentText,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Search for a city',
                                hintStyle: TextStyle(
                                  color: Color(0xFFA2AADB),
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (value) async {
                                final result = await GeocodingService
                                    .fetchCitySuggestions(value);
                                setState(() {
                                  suggestions = result.suggestions.length > 5
                                      ? result.suggestions.sublist(0, 5)
                                      : result.suggestions;
                                  errorMessage = result.error;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              if (errorMessage != null)
                Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[100]?.withOpacity(.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[900]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(
                            color: Colors.red[900],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (suggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: pillColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      final city = suggestions[index];
                      return ListTile(
                        title: Text(
                          city.name,
                          style: const TextStyle(
                            color: accentText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${city.region}, ${city.country}',
                          style: const TextStyle(color: accentText),
                        ),
                        onTap: () => onCitySelected(city),
                      );
                    },
                  ),
                ),
              Expanded(
                child: TabBarView(
                  children: [
                    CurrentlyTab(city: selectedCity),
                    WeeklyTab(city: selectedCity),
                    TodayTab(city: selectedCity),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.transparent,
            elevation: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: pillColor.withOpacity(.5),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: const TabBar(
                indicatorColor: Colors.transparent,
                labelColor: accentText,
                unselectedLabelColor: accentText,
                tabs: [
                  Tab(icon: Icon(Icons.calendar_today), text: 'Currently'),
                  Tab(icon: Icon(Icons.calendar_month), text: 'Weekly'),
                  Tab(icon: Icon(Icons.waves), text: 'Today'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
