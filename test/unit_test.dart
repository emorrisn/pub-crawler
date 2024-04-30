import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pub_hopper_app/helpers/notificationHelper.dart';
import 'package:pub_hopper_app/models/Challenge.dart';
import 'package:pub_hopper_app/models/City.dart';
import 'package:pub_hopper_app/models/database_models/ChallengeDB.dart';
import 'package:pub_hopper_app/providers/cityProvider.dart';
import 'package:pub_hopper_app/providers/groupChallengeProvider.dart';
import 'package:pub_hopper_app/providers/individualChallengeProvider.dart';
import 'package:pub_hopper_app/screens/new_crawl/newCrawlDetailsScreen.dart';
import 'package:pub_hopper_app/services/overpassAPI.dart';
import 'package:pub_hopper_app/services/unsplashAPI.dart';


void main() {

  Map<String, String?> testEnv = {'UNSPLASH_API_KEY': null};

  // Helpers

  group('Helpers testing', () {
    group('Notification Helper', () {
      // Test that showNotification throws assertion error for scheduled notification without interval
      test('showNotification - throws error for scheduled notification without interval', () async {
        expect(() => NotificationHelper.showNotification(
          title: 'Test Title',
          body: 'Test Body',
          scheduled: true,
        ), throwsA(isA<AssertionError>()));
      });

      // Test that showNotification accepts valid inputs
      test('showNotification - accepts valid inputs', () async {
        // Arrange
        final title = 'Test Title';
        final body = 'Test Body';

        // Act & Assert
        await expectLater(
            NotificationHelper.showNotification(title: title, body: body),
            completes);
      });
    });
  });

  // Models

  group('Models testing', () {
    group('Challenge Model Tests (Non-database)', () {
      test('Challenge - constructor creates object with required fields', () {
        final challenge = Challenge(
          title: 'Test Title',
          description: 'Test Description',
          forfeit: 'Test Forfeit',
          type: 'individual',
        );

        expect(challenge.title, 'Test Title');
        expect(challenge.description, 'Test Description');
        expect(challenge.forfeit, 'Test Forfeit');
        expect(challenge.type, 'individual');
      });

      test('Challenge.fromJson - creates object from JSON data', () {
        final json = {'title': 'Test Title', 'description': 'Test Description', 'forfeit': 'Test Forfeit', 'type': 'group'};
        final challenge = Challenge.fromJson(json);

        expect(challenge.title, json['title']);
        expect(challenge.description, json['description']);
        expect(challenge.forfeit, json['forfeit']);
        expect(challenge.type, json['type']);
      });

      test('Challenge.copy - creates a copy of the object', () {
        final originalChallenge = Challenge(
          title: 'Original Title',
          description: 'Original Description',
          forfeit: 'Original Forfeit',
          type: 'individual',
        );

        final copiedChallenge = Challenge.copy(originalChallenge);

        expect(copiedChallenge, equals(originalChallenge));
        expect(copiedChallenge == originalChallenge, false); // Checks for reference equality
      });
    });
    group('Challenge Model Tests (Database)', () {
      test('ChallengeDB - constructor creates object with required fields', () {
        final challengeDB = ChallengeDB(
          id: 1,
          title: 'Test Title',
          description: 'Test Description',
          forfeit: 'Test Forfeit',
          type: 'individual',
        );

        expect(challengeDB.id, 1);
        expect(challengeDB.title, 'Test Title');
        expect(challengeDB.description, 'Test Description');
        expect(challengeDB.forfeit, 'Test Forfeit');
        expect(challengeDB.type, 'individual');
      });

      test('ChallengeDB.copyWith - creates a copy of the object', () {
        final originalChallengeDB = ChallengeDB(
          id: 1,
          title: 'Original Title',
          description: 'Original Description',
          forfeit: 'Original Forfeit',
          type: 'group',
        );

        final copiedChallengeDB = originalChallengeDB.copyWith(
          title: 'Updated Title',
          description: 'Updated Description',
        );

        expect(copiedChallengeDB, isNot(same(originalChallengeDB))); // Checks for reference equality
        expect(copiedChallengeDB.id, originalChallengeDB.id);
        expect(copiedChallengeDB.title, 'Updated Title');
        expect(copiedChallengeDB.description, 'Updated Description');
        expect(copiedChallengeDB.forfeit, originalChallengeDB.forfeit);
        expect(copiedChallengeDB.type, originalChallengeDB.type);
      });

      test('ChallengeDB.toMap - converts object to a map', () {
        final challengeDB = ChallengeDB(
          id: 1,
          title: 'Test Title',
          description: 'Test Description',
          forfeit: 'Test Forfeit',
          type: 'individual',
        );

        final map = challengeDB.toMap();

        expect(map['id'], challengeDB.id);
        expect(map['title'], challengeDB.title);
        expect(map['description'], challengeDB.description);
        expect(map['forfeit'], challengeDB.forfeit);
        expect(map['type'], challengeDB.type);
      });

      test('ChallengeDB.fromMap - creates object from a map', () {
        final map = {
          'id': 1,
          'title': 'Test Title',
          'description': 'Test Description',
          'forfeit': 'Test Forfeit',
          'type': 'group',
        };

        final challengeDB = ChallengeDB.fromMap(map);

        expect(challengeDB.id, map['id']);
        expect(challengeDB.title, map['title']);
        expect(challengeDB.description, map['description']);
        expect(challengeDB.forfeit, map['forfeit']);
        expect(challengeDB.type, map['type']);
      });
    });
  });

  // Providers

  group('Providers testing', () {
    test('CityProvider.getCities - returns a list of City objects', () async {
      final cityProvider = CityProvider(); // Use real CityProvider

      final cities = await cityProvider.getCities();

      expect(cities, isA<List<City>>());
    });
    test('GroupChallengeProvider.getChallenges - returns a list of Challenge objects', () async {
      final provider = GroupChallengeProvider(); // Use real GroupChallengeProvider

      final challenges = await provider.getChallenges();

      expect(challenges, isA<List<Challenge>>());
    });
    test('IndividualChallengeProvider.getChallenges - returns a list of Challenge objects', () async {
      final provider = IndividualChallengeProvider(); // Use real IndividualChallengeProvider

      final challenges = await provider.getChallenges();

      expect(challenges, isA<List<Challenge>>());
    });
  });


  // Services

  group('Services testing', () {
    group('OverpassApiService testing', () {
      test('queryAmenity - fetches pubs for valid coordinates (Integration Test)', () async {
        final service = OverpassApiService();
        final locations = await service.queryAmenity(51.505, -0.09, 51.515, -0.1, 'pub');

        expect(locations, isNotEmpty); // Check if some pubs are found
      });
    });
    group('UnsplashAPIService testing', () {
      test('getRandomPhoto - fetches random photo (Integration Test)', () async {
        final apiKey = testEnv["UNSPLASH_API_KEY"];
        if (apiKey != null) { // Check if key is not null
          final service = UnsplashAPIService();
          final photo = await service.getRandomPhoto(apikey: apiKey); // Use key twice (avoid redundancy in future options)
          print(photo.imageUrl);
          expect(photo.imageUrl, isNotNull); // Check if a photo is retrieved
        } else {
          // Handle the case where the environment variable is missing
          fail('UNSPLASH_API_KEY environment variable is missing');
        }
      });
    });
  });
}