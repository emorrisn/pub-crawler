import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/City.dart';

class CityProvider {
  Future<List<City>> getCities() async {
    // Load the JSON data
    String jsonString = await rootBundle.loadString('lib/assets/data/cities.json');

    // Parse the JSON string
    List<dynamic> jsonList = json.decode(jsonString);

    // Convert the JSON data into City objects
    List<City> cities = jsonList.map((json) => City.fromJson(json)).toList();

    return cities;
  }
}