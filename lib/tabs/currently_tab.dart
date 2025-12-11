import 'package:flutter/material.dart';
import '../services/geocoding_service.dart';
import '../services/location_service.dart';

class CurrentlyTab extends StatefulWidget {
  final void Function(bool)? onLoadingChanged;
  const CurrentlyTab({Key? key, this.onLoadingChanged}) : super(key: key);

  @override
  State<CurrentlyTab> createState() => _CurrentlyTabState();
}

class _CurrentlyTabState extends State<CurrentlyTab> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;
  List suggestions = [];

  void _setLoading(bool v) {
    setState(() => _isLoading = v);
    widget.onLoadingChanged?.call(v);
  }

  Future<void> _search(String q) async {
    _setLoading(true);
    final res = await GeocodingService.fetchCitySuggestions(q);
    _setLoading(false);

    if (res.error != null || res.suggestions.isEmpty) {
      final msg = res.error ?? 'City not found';
      setState(() {
        suggestions = [];
        _error = msg;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
      return;
    }

    setState(() {
      suggestions = res.suggestions;
      _error = null;
    });
  }

  Future<void> _useCurrentLocation() async {
    try {
      _setLoading(true);
      final pos = await LocationService.getCurrentPosition();
      _setLoading(false);
      final snack = 'Current location: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(snack)));
    } catch (e) {
      _setLoading(false);
      final msg = e.toString();
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Location error'),
            content: Text(msg),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.location_on), onPressed: _useCurrentLocation),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(999)),
                  child: Row(
                    children: [
                      const Icon(Icons.search),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search for a city'),
                          onChanged: (v) {
                            if (v.trim().isEmpty) return;
                            _search(v.trim());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red[100],
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!)),
                ],
              ),
            ),
          if (suggestions.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, i) {
                  final c = suggestions[i];
                  return ListTile(
                    title: Text(c.name),
                    subtitle: Text('${c.region}, ${c.country}'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selected ${c.name}')));
                    },
                  );
                },
              ),
            ),
          if (suggestions.isEmpty && _error == null)
            const Expanded(child: Center(child: Text('No suggestions yet'))),
        ],
      ),
    );
  }
}
