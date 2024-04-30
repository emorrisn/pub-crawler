import '../helpers/databaseHelper.dart';
import 'database_models/ChallengeDB.dart';

class Challenge {
  final String title;
  final String description;
  final String forfeit;
  final String type; // individual or group
  late bool remain; // option which determines if challenge should remain for the remainder of the crawl.

  Challenge({
    required this.title,
    required this.description,
    required this.forfeit,
    required this.type,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      title: json['title'],
      description: json['description'],
      forfeit: json['forfeit'],
      type: json['type'],
    );
  }

  Challenge.copy(Challenge other)
      : title = other.title,
        description = other.description,
        forfeit = other.forfeit,
        type = other.type;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Challenge &&
        other.title == title &&
        other.description == description &&
        other.forfeit == forfeit &&
        other.type == type;
  }

  @override
  int get hashCode {
    return title.hashCode ^
    description.hashCode ^
    forfeit.hashCode ^
    type.hashCode;
  }

  static Future<ChallengeDB?> getByTitle(String title) async {
    final List<Map<String, dynamic>> maps = await DatabaseHelper()
        .getAll('Challenges', where: 'title = ?', whereArgs: [title]);
    return maps.isNotEmpty ? ChallengeDB.fromMap(maps.first) : null;
  }

  // Function to save the challenge to the database and return a ChallengeDB object
  Future<ChallengeDB> saveToDatabase() async {
    // Check if a challenge with the same title already exists
    final existingChallenge = await Challenge.getByTitle(title);

    if (existingChallenge != null) {
      // Challenge already exists, return the existing object
      return existingChallenge;
    } else {
      // Create a ChallengeDB object from the current Challenge instance
      final challengeDB = ChallengeDB(
        id: 0, // Set to 0 for now since it will be generated by the database
        title: title,
        description: description,
        forfeit: forfeit,
        type: type,
      );

      // Insert the ChallengeDB object into the database
      final int challengeId = await challengeDB.insert();

      // Return the updated ChallengeDB object with the assigned ID
      return challengeDB.copyWith(id: challengeId);
    }
  }

  // From JSON file
  factory Challenge.fromPos(int pos, bool group, List<Challenge> individualChallenges, List<Challenge> groupChallenges) {
    if (group) {
      if (pos >= 0 && pos < groupChallenges.length) {
        return groupChallenges[pos];
      }
    } else {
      if (pos >= 0 && pos < individualChallenges.length) {
        return individualChallenges[pos];
      }
    }

    return Challenge(
      title: "",
      description: "",
      forfeit: "",
      type: "",
    );
  }

}

