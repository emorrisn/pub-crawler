import '../../helpers/databaseHelper.dart';
import 'ChallengeDB.dart';

class LocationDB {
  final int id;
  final int orderPos;
  final String name;
  final String description;
  final String city;
  final String country;
  final String postcode;
  final String street;
  final String houseNumber;
  final String website;
  final String amenity;
  final String openingHours;
  final String phone;
  final bool outdoorSeating;
  final double longitude;
  final double latitude;

  LocationDB({
    required this.id,
    required this.orderPos,
    required this.name,
    required this.description,
    required this.city,
    required this.country,
    required this.postcode,
    required this.street,
    required this.houseNumber,
    required this.website,
    required this.amenity,
    required this.openingHours,
    required this.phone,
    required this.outdoorSeating,
    required this.longitude,
    required this.latitude,
  });

  LocationDB copyWith({
    int? id,
    int? orderPos,
    String? name,
    String? description,
    String? city,
    String? country,
    String? postcode,
    String? street,
    String? houseNumber,
    String? website,
    String? amenity,
    String? openingHours,
    String? phone,
    bool? outdoorSeating,
    double? longitude,
    double? latitude,
  }) {
    return LocationDB(
      id: id ?? this.id,
      orderPos: orderPos ?? this.orderPos,
      name: name ?? this.name,
      description: description ?? this.description,
      city: city ?? this.city,
      country: country ?? this.country,
      postcode: postcode ?? this.postcode,
      street: street ?? this.street,
      houseNumber: houseNumber ?? this.houseNumber,
      website: website ?? this.website,
      amenity: amenity ?? this.amenity,
      openingHours: openingHours ?? this.openingHours,
      phone: phone ?? this.phone,
      outdoorSeating: outdoorSeating ?? this.outdoorSeating,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
    );
  }

  // Convert CrawlLocation object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderPos': orderPos,
      'name': name,
      'description': description,
      'city': city,
      'country': country,
      'postcode': postcode,
      'street': street,
      'houseNumber': houseNumber,
      'website': website,
      'amenity': amenity,
      'openingHours': openingHours,
      'phone': phone,
      'outdoorSeating': outdoorSeating ? 1 : 0, // Convert bool to int
      'longitude': longitude,
      'latitude': latitude,
    };
  }

  // Create CrawlLocation object from a map
  static LocationDB fromMap(Map<String, dynamic> map) {
    return LocationDB(
      id: map['id'],
      orderPos: map['orderPos'],
      name: map['name'],
      description: map['description'],
      city: map['city'],
      country: map['country'],
      postcode: map['postcode'],
      street: map['street'],
      houseNumber: map['houseNumber'],
      website: map['website'],
      amenity: map['amenity'],
      openingHours: map['openingHours'],
      phone: map['phone'],
      outdoorSeating: map['outdoorSeating'] == 1, // Convert int to bool
      longitude: map['longitude'],
      latitude: map['latitude'],
    );
  }

  // Insert method

  Future<int> insert({bool insertAlways = false}) async {
    // Check if insertAlways is false and if the challenge already exists in the database
    if (!insertAlways) {
      List<Map<String, dynamic>> duplicateLocations = await DatabaseHelper().getAll(
        'Locations',
        where: 'latitude = ? AND longitude = ?',
        whereArgs: [latitude, longitude],
      );
      if (duplicateLocations.isNotEmpty) {
        // Location already exists, return its ID without inserting a new one
        return duplicateLocations.first['id'] as int;
      }
    }

    // Insert the challenge into the database
    final Map<String, dynamic> data = toMap();
    data.remove('id');
    int id = await DatabaseHelper().insert('Locations', data);
    id = id;
    return id;
  }

  // Update method
  Future<int> update() async {
    final Map<String, dynamic> data = toMap();
    return await DatabaseHelper().update('Locations', data, id);
  }

  // Delete method
  Future<int> delete() async {
    return await DatabaseHelper().delete('Locations', id);
  }

  // Get by ID method
  static Future<LocationDB?> getById(int localID) async {
    final Map<String, dynamic>? locationMap =
    await DatabaseHelper().getById('Locations', localID);
    return locationMap != null ? LocationDB.fromMap(locationMap) : null;
  }

  Future<List<ChallengeDB>> getAllChallenges() async {
    final List<Map<String, dynamic>> crawlLocationChallengeMaps =
    await DatabaseHelper().getAll('CrawlLocationChallenges',
        where: 'location_id = ?', whereArgs: [id]);

    final List<ChallengeDB> challenges = [];
    for (final crawlLocationChallengeMap in crawlLocationChallengeMaps) {
      final int challengeId = crawlLocationChallengeMap['challenge_id'];
      final ChallengeDB? challenge = await ChallengeDB.getById(challengeId);
      if (challenge != null) {
        challenges.add(challenge);
      }
    }

    return challenges;
  }
}
