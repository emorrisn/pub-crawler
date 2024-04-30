import 'package:pub_hopper_app/models/database_models/ChallengeDB.dart';
import 'package:pub_hopper_app/models/database_models/CrawlLocationChallengeDB.dart';

import '../../helpers/databaseHelper.dart';
import 'LocationDB.dart';

class CrawlDB {
  final int id;
  late final String name;
  final String city;
  final String description;
  final bool individualChallenges;
  final bool groupChallenges;
  final double individualChallengeChance;

  CrawlDB({
    required this.id,
    required this.name,
    required this.city,
    required this.description,
    required this.individualChallenges,
    required this.groupChallenges,
    required this.individualChallengeChance,
  });

  CrawlDB copyWith({
    int? id,
    String? name,
    String? city,
    String? description,
    bool? individualChallenges,
    bool? groupChallenges,
    double? individualChallengeChance,
  }) {
    return CrawlDB(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      description: description ?? this.description,
      individualChallenges: individualChallenges ?? this.individualChallenges,
      groupChallenges: groupChallenges ?? this.groupChallenges,
      individualChallengeChance:
          individualChallengeChance ?? this.individualChallengeChance,
    );
  }

  // Convert Crawl object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'description': description,
      'individualChallenges': individualChallenges ? 1 : 0,
      'groupChallenges': groupChallenges ? 1 : 0,
      'individualChallengeChance': individualChallengeChance,
    };
  }

  // Create Crawl object from a map
  static CrawlDB fromMap(Map<String, dynamic> map) {
    return CrawlDB(
      id: map['id'],
      name: map['name'],
      city: map['city'],
      description: map['description'],
      individualChallenges: map['individualChallenges'] == 1,
      groupChallenges: map['groupChallenges'] == 1,
      individualChallengeChance: map['individualChallengeChance'],
    );
  }

  // Insert method
  Future<int> insert() async {
    final Map<String, dynamic> data = toMap();
    data.remove('id');
    int id = await DatabaseHelper().insert('Crawls', data);
    id = id;
    return id;
  }

  // Update method
  Future<int> update() async {
    final Map<String, dynamic> data = toMap();
    return await DatabaseHelper().update('Crawls', data, id);
  }

  // Delete method
  Future<int> delete() async {
    final db = await DatabaseHelper().database;
    return await db.transaction((txn) async {
      // Delete Crawl with the provided ID
      final deletedRows =
          await txn.delete('Crawls', where: 'id = ?', whereArgs: [id]);

      if (deletedRows > 0) {
        //
        // Challenges
        //

        // Find all challenges
        final List<Map<String, dynamic>> crawlLocationChallengeMaps =
            await txn.query(
          'CrawlLocationChallenges',
          where: 'crawl_id = ?',
          whereArgs: [id],
        );

        final List<int> challengeIds = crawlLocationChallengeMaps
            .map((map) => map['challenge_id'] as int)
            .toList();

        // Delete all challenges that are linked to the crawl
        if (challengeIds.isNotEmpty) {
          String whereClause = 'id IN (';

          for (int i = 0; i < challengeIds.length; i++) {
            whereClause += '?,';
          }

          whereClause = whereClause.substring(0, whereClause.length - 1); // Remove trailing comma
          whereClause += ')';

          await txn.delete(
            'Challenges',
            where: whereClause,
            whereArgs: challengeIds,
          );
        }

        // Delete linked CrawlLocationChallenges entries
        await txn.delete(
          'CrawlLocationChallenges',
          where: 'crawl_id = ?',
          whereArgs: [id],
        );

        //
        // Locations
        //

        // Find all locations that are linked to crawl
        final List<Map<String, dynamic>> crawlLocationMaps = await txn.query(
          'CrawlLocations',
          where: 'crawl_id = ?',
          whereArgs: [id],
        );

        final List<int> locationIds =
            crawlLocationMaps.map((map) => map['location_id'] as int).toList();

        // Delete Locations
        // Consider/Future: filtering/checking for usage in other crawls
        for (final locationId in locationIds) {
          await txn
              .delete('Locations', where: 'id = ?', whereArgs: [locationId]);
        }

        // Delete linked CrawlLocations entries
        await txn.delete(
          'CrawlLocations',
          where: 'crawl_id = ?',
          whereArgs: [id],
        );
      }
      return deletedRows;
    });
  }

  // Get by ID method
  static Future<CrawlDB?> getById(int id) async {
    final Map<String, dynamic>? crawlMap =
        await DatabaseHelper().getById('Crawls', id);
    return crawlMap != null ? CrawlDB.fromMap(crawlMap) : null;
  }

  Future<List<CrawlLocationChallengeDB>> getLinkedChallenges() async {
    final List<Map<String, dynamic>> crawlLocationChallenges = await DatabaseHelper()
        .getAll('CrawlLocationChallenges', where: 'crawl_id = ?', whereArgs: [id]);

    final List<CrawlLocationChallengeDB> challenges = [];
    for (final map in crawlLocationChallenges) {
      challenges.add(CrawlLocationChallengeDB.fromMap(map));
    }

    return challenges;
  }

  Future<List<ChallengeDB>> getChallenges(List<CrawlLocationChallengeDB> linkedChallenges) async {
    final List<ChallengeDB> challenges = [];
    List<int> challengeIds = [];

    for (final linkedChallenge in linkedChallenges) {
      if(linkedChallenge.crawlId == id)
        {
          // We only want the challenges a crawl has, we don't want to add them as many times as they're used.
          int chID = linkedChallenge.challengeId;
          if(!challengeIds.contains(chID))
            {
              challengeIds.add(chID);
            }
        }
    }

    for(final challengeId in challengeIds)
      {
        final ChallengeDB? challenge = await ChallengeDB.getById(challengeId);
        if (challenge != null && !challenges.contains(challenge)) {
          challenges.add(challenge);
        }
      }


    return challenges;
  }

  Future<List<LocationDB>> getAllLocations() async {
    final List<Map<String, dynamic>> crawlLocationMaps = await DatabaseHelper()
        .getAll('CrawlLocations', where: 'crawl_id = ?', whereArgs: [id]);

    final List<LocationDB> locations = [];
    for (final crawlLocationMap in crawlLocationMaps) {
      final int locationId = crawlLocationMap['location_id'];
      final LocationDB? location = await LocationDB.getById(locationId);
      if (location != null) {
        locations.add(location);
      }
    }

    return locations;
  }

  // Get all crawl records as CrawlDB objects
  static Future<List<CrawlDB>> getAllCrawls() async {
    final List<Map<String, dynamic>> crawlMaps =
        await DatabaseHelper().getAll('Crawls');
    return crawlMaps.map((map) => CrawlDB.fromMap(map)).toList();
  }

  static Future<CrawlDB?> getByDetails(String name, String city, String description) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('Crawls',
        where: 'name = ? AND city = ? AND description = ?',
        whereArgs: [name, city, description]);
    return maps.isNotEmpty ? CrawlDB.fromMap(maps.first) : null;
  }

}
