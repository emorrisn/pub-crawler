import '../../helpers/databaseHelper.dart';

class CrawlLocationDB {
  final int id;
  final int crawlId;
  final int locationId;

  CrawlLocationDB({
    required this.id,
    required this.crawlId,
    required this.locationId,
  });

  // Convert CrawlLocation object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'crawl_id': crawlId,
      'location_id': locationId,
    };
  }

  // Create CrawlLocation object from a map
  static CrawlLocationDB fromMap(Map<String, dynamic> map) {
    return CrawlLocationDB(
      id: map['id'],
      crawlId: map['crawlId'],
      locationId: map['locationId'],
    );
  }

  // Insert method
  Future<int> insert() async {
    final Map<String, dynamic> data = toMap();
    data.remove('id');
    int id = await DatabaseHelper().insert('CrawlLocations', data);
    id = id;
    return id;
  }


  // Update method
  Future<int> update() async {
    final Map<String, dynamic> data = toMap();
    return await DatabaseHelper().update('CrawlLocations', data, id);
  }

  // Delete method
  Future<int> delete() async {
    return await DatabaseHelper().delete('CrawlLocations', id);
  }

  // Get by ID method
  static Future<CrawlLocationDB?> getById(int id) async {
    final Map<String, dynamic>? crawlLocationMap =
    await DatabaseHelper().getById('CrawlLocations', id);
    return crawlLocationMap != null ? CrawlLocationDB.fromMap(crawlLocationMap) : null;
  }
}
