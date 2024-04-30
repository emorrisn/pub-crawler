import 'package:firebase_auth/firebase_auth.dart';

import '../../helpers/databaseHelper.dart';

class UserDB {
  final int id;
  final String name;
  final String photo_url;
  final String uid;
  final String unsplash_api_key;
  final String map_api_key;
  final String map_layer;

  UserDB({
    required this.id,
    required this.name,
    required this.photo_url,
    required this.uid,
    required this.unsplash_api_key,
    required this.map_api_key,
    required this.map_layer,
  });

  // Convert CrawlLocation object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photo_url': photo_url,
      'uid': uid,
      'unsplash_api_key': unsplash_api_key,
      'map_api_key': map_api_key,
      'map_layer': map_layer,
    };
  }

  // Create CrawlLocation object from a map
  static UserDB fromMap(Map<String, dynamic> map) {
    return UserDB(
        id: map['id'],
        name: map['name'],
        photo_url: map['photo_url'],
        uid: map['uid'],
        unsplash_api_key: map['unsplash_api_key'],
        map_api_key: map['map_api_key'],
        map_layer: map['map_layer']);
  }

  // Insert method
  Future<int> insert() async {
    final Map<String, dynamic> data = toMap();
    data.remove('id');
    int id = await DatabaseHelper().insert('Users', data);
    id = id;
    return id;
  }

  // Update method
  Future<int> update() async {
    final Map<String, dynamic> data = toMap();
    return await DatabaseHelper().update('Users', data, id);
  }

  // Delete method
  Future<int> delete() async {
    return await DatabaseHelper().delete('Users', id);
  }

  // Get by ID method
  static Future<UserDB?> getById(int id) async {
    final Map<String, dynamic>? crawlLocationMap =
        await DatabaseHelper().getById('Users', id);
    return crawlLocationMap != null ? UserDB.fromMap(crawlLocationMap) : null;
  }

  static Future<UserDB?> getBySession(User? user) async {
    if(user != null)
      {
        List<Map<String, dynamic>> users = await DatabaseHelper()
            .getAll('Users', where: 'uid = ?', whereArgs: [user.uid]);

        if (users.isNotEmpty) {
          return UserDB.fromMap(users.first);
        }
      }

    return null;
  }

  static Future<List<UserDB>> getAll() async {
    final List<Map<String, dynamic>> crawlMaps =
    await DatabaseHelper().getAll('Users');
    return crawlMaps.map((map) => UserDB.fromMap(map)).toList();
  }
}
