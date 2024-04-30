import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/Location.dart';

class OverpassApiService {
  static const String _baseUrl = 'https://overpass-api.de/api/interpreter';

  Future<dynamic> queryAmenity(double minLat, double minLon, double maxLat, double maxLon, String amenity) async {
    // amenity = pub
    final query = '''
      [out:json];
      (
        node["amenity"="pub"]($minLat,$minLon,$maxLat,$maxLon);
        way["amenity"="pub"]($minLat,$minLon,$maxLat,$maxLon);
        relation["amenity"="$amenity"]($minLat,$minLon,$maxLat,$maxLon);
      );
      out center;
    ''';

    debugPrint('Sending API Request...');
    final response = await http.post(Uri.parse(_baseUrl), body: {'data': query});

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      final jsonData = jsonDecode(response.body);
      return _parseLocations(jsonData);
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to load data from Overpass API');
    }
  }

  List<Location> _parseLocations(dynamic jsonData) {
    final List<Location> locations = [];
    if (jsonData['elements'] != null) {
      for (final element in jsonData['elements']) {

        final tags = element['tags'];

        // Attempt to accommodate non-nodes
        double? lat = element['lat'];
        double? lon = element['lon'];

        if(lon == null || lat == null)
        {
          lon = element['center']['lon'];
          lat = element['center']['lat'];
        }

        // If it's still null then we just set to 0.0
        if(lon == null || lat == null)
        {
          lon = 0.0;
          lat = 0.0;
        }

        final location = Location(
          apiID: element['id'] ?? 0,
          localID: locations.length,
          name: tags['name'] ?? 'Unknown',
          position: 0,
          houseNumber: tags['addr:housenumber'] ?? '?',
          description: tags['description'] ?? '',
          city: tags['addr:city'] ?? '',
          country: tags['addr:country'] ?? 'GB',
          postcode: tags['addr:postcode'] ?? '',
          street: tags['addr:street'] ?? '',
          website: tags['website'] ?? '',
          amenity: tags['amenity'] ?? 'pub',
          openingHours: tags['opening_hours'] ?? 'Unknown',
          phone: tags['phone'] ?? 'Unknown',
          outdoorSeating: tags['outdoor_seating'] == 'yes',
          longitude: lon,
          latitude: lat,
        );

        locations.add(location);
      }
    }
    return locations;
  }
}
