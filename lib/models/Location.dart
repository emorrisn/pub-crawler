import 'database_models/LocationDB.dart';

class Location {
  final int apiID;
  final int localID;
  late int position;
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


  Location({
    required this.apiID,
    required this.localID,
    required this.name,
    required this.position,
    this.description = "",
    this.city = "",
    this.country = "GB",
    this.postcode = "",
    this.street = "",
    this.houseNumber = "",
    this.website = "",
    this.amenity = "pub",
    this.openingHours = "Unknown",
    this.phone = "Unknown",
    this.outdoorSeating = false,
    required this.longitude,
    required this.latitude,
  });

  @override
  String toString() {
    return 'Location(apiID: $apiID, localID: $localID, name: $name, position: $position, description: $description, city: $city, country: $country, postcode: $postcode, street: $street, website: $website, amenity: $amenity, openingHours: $openingHours, phone: $phone, outdoorSeating: $outdoorSeating, longitude: $longitude, latitude: $latitude)';
  }

  Future<LocationDB> saveToDatabase() async {
    // Create a LocationDB object from the current Location instance
    final locationDB = LocationDB(
      id: 0,
      orderPos: position,
      name: name,
      description: description,
      city: city,
      country: country,
      postcode: postcode,
      street: street,
      houseNumber: houseNumber,
      website: website,
      amenity: amenity,
      openingHours: openingHours,
      phone: phone,
      outdoorSeating: outdoorSeating,
      longitude: longitude,
      latitude: latitude,
    );

    // Insert the LocationDB object into the database
    final int locationId = await locationDB.insert();

    // Return the updated LocationDB object with the assigned ID
    return locationDB.copyWith(id: locationId);
  }
}