class City {
  final String name;
  final String region;
  final String country;
  final double lat;
  final double lon;

  City({required this.name, this.region = '', this.country = '', required this.lat, required this.lon});

  @override
  String toString() => '$name, $region, $country';
}
