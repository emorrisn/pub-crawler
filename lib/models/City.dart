class City {
  final String name;
  final String country;
  final double longitude;
  final double latitude;

  City({required this.name, required this.country, required this.longitude, required this.latitude});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'],
      country: json['country'],
      longitude: json['longitude'],
      latitude: json['latitude'],
    );
  }

}