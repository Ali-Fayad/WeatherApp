import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../models/favorite.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DBHelper _db = DBHelper();
  List<Favorite> _favorites = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final favs = await _db.getFavorites();
    setState(() => _favorites = favs);
  }

  Future<void> _addFavoriteDialog() async {
    final cityCtrl = TextEditingController();
    final latCtrl = TextEditingController();
    final lonCtrl = TextEditingController();

    final res = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Favorite'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City')),
            TextField(controller: latCtrl, decoration: const InputDecoration(labelText: 'Latitude')),
            TextField(controller: lonCtrl, decoration: const InputDecoration(labelText: 'Longitude')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (res == true) {
      final fav = Favorite(
        cityName: cityCtrl.text.trim(),
        lat: double.tryParse(latCtrl.text.trim()) ?? 0.0,
        lon: double.tryParse(lonCtrl.text.trim()) ?? 0.0,
      );
      await _db.insertFavorite(fav);
      await _load();
    }
  }

  Future<void> _deleteFavorite(int id) async {
    await _db.deleteFavorite(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFavoriteDialog,
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _favorites.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final f = _favorites[i];
          return ListTile(
            title: Text(f.cityName),
            subtitle: Text('Lat: ${f.lat}, Lon: ${f.lon}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteFavorite(f.id!),
            ),
            onTap: () {
              // Optional: propagate favorite selection to main app
            },
          );
        },
      ),
    );
  }
}
