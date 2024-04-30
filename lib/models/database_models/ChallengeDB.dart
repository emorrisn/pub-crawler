import '../../helpers/databaseHelper.dart';
import '../Challenge.dart';

class ChallengeDB {
  final int id;
  final String title;
  final String description;
  final String forfeit;
  final String type;

  ChallengeDB({
    required this.id,
    required this.title,
    required this.description,
    required this.forfeit,
    required this.type,
  });

  ChallengeDB copyWith({
    int? id,
    String? title,
    String? description,
    String? forfeit,
    String? type,
  }) {
    return ChallengeDB(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      forfeit: forfeit ?? this.forfeit,
      type: type ?? this.type,
    );
  }

  // Convert Challenge object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'forfeit': forfeit,
      'type': type,
    };
  }

  // Create Challenge object from a map
  static ChallengeDB fromMap(Map<String, dynamic> map) {
    return ChallengeDB(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      forfeit: map['forfeit'],
      type: map['type'],
    );
  }

  // Insert method

  Future<int> insert({bool insertAlways = false}) async {
    // Check if insertAlways is false and if the challenge already exists in the database
    if (!insertAlways) {
      List<Map<String, dynamic>> duplicateChallenges = await DatabaseHelper().getAll(
        'Challenges',
        where: 'title = ?',
        whereArgs: [title],
      );
      if (duplicateChallenges.isNotEmpty) {
        // Challenge already exists, return its ID without inserting a new one
        return duplicateChallenges.first['id'] as int;
      }
    }

    // Insert the challenge into the database
    final Map<String, dynamic> data = toMap();
    data.remove('id');
    int id = await DatabaseHelper().insert('Challenges', data);
    id = id;
    return id;
  }


  // Update method
  Future<int> update() async {
    final Map<String, dynamic> data = toMap();
    return await DatabaseHelper().update('Challenges', data, id);
  }

  // Delete method
  Future<int> delete() async {
    return await DatabaseHelper().delete('Challenges', id);
  }

  // Get by ID method
  static Future<ChallengeDB?> getById(int id) async {
    final Map<String, dynamic>? challengeMap =
    await DatabaseHelper().getById('Challenges', id);
    return challengeMap != null ? ChallengeDB.fromMap(challengeMap) : null;
  }

  // Get position of challenge taken from group.json and individual.json
  Map<int, bool> toPos(List<Challenge> individualChallenges, List<Challenge> groupChallenges) {
    int index = 0;
    bool group = false;

    // Search in individualChallenges list
    for (Challenge challenge in individualChallenges) {
      if (challenge.title == title) {
        return {index: group};
      }
      index++;
    }

    // If not found in individualChallenges, search in groupChallenges list
    index = 0;
    group = true;
    for (Challenge challenge in groupChallenges) {
      if (challenge.title == title) {
        return {index: group};
      }
      index++;
    }

    // If not found in either list, return -1 to indicate not found
    return {-1: false};
  }
}
