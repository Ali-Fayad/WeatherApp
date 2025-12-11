import 'package:flutter/material.dart';
import 'package:advanced_weather_app01/widgets/loading_overlay.dart';
import 'package:advanced_weather_app01/tabs/currently_tab.dart' as t_currently;
import 'package:advanced_weather_app01/tabs/weekly_tab.dart' as t_weekly;
import 'package:advanced_weather_app01/tabs/today_tab.dart' as t_today;
import 'package:advanced_weather_app01/screens/favorites_screen.dart' as s_fav;
import 'package:advanced_weather_app01/screens/settings_screen.dart' as s_settings;

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isLoading = false;

  void setLoading(bool v) => setState(() => _isLoading = v);

  @override
  Widget build(BuildContext context) {
    // Use a solid background color instead of a background image.
    // The app-level scaffoldBackgroundColor is already set in MaterialApp theme.
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Weather'),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const s_fav.FavoritesScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const s_settings.SettingsScreen()),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.cloud), text: 'Currently'),
              Tab(icon: Icon(Icons.calendar_view_week), text: 'Weekly'),
              Tab(icon: Icon(Icons.access_time), text: 'Today'),
            ],
          ),
        ),
        body: LoadingOverlay(
          isLoading: _isLoading,
          child: TabBarView(
            children: [
              const t_currently.CurrentlyTab(),
              const t_weekly.WeeklyTab(),
              const t_today.TodayTab(),
            ],
          ),
        ),
      ),
    );
  }
}
