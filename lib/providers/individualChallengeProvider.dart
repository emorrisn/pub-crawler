import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pub_hopper_app/models/Challenge.dart';


class IndividualChallengeProvider {
  Future<List<Challenge>> getChallenges() async {
    // Load the JSON data
    String jsonString = await rootBundle.loadString('lib/assets/data/challenges/individual.json');

    // Parse the JSON string
    List<dynamic> jsonList = json.decode(jsonString);

    // Convert the JSON data into City objects
    List<Challenge> challenges = jsonList.map((json) => Challenge.fromJson(json)).toList();

    return challenges;
  }
}