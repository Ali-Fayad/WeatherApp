class Favorite {
  final int? id;
  final String cityName;
  final double lat;
  final double lon;
  final String note;

  Favorite({this.id, required this.cityName, required this.lat, required this.lon, this.note = ''});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cityName': cityName,
      'lat': lat,
      'lon': lon,
      'note': note,
    };
  }

  factory Favorite.fromMap(Map<String, dynamic> m) {
    return Favorite(
      id: m['id'] as int?,
      cityName: m['cityName'] as String,
      lat: (m['lat'] as num).toDouble(),
      lon: (m['lon'] as num).toDouble(),
      note: m['note'] as String? ?? '',
    );
  }
}
