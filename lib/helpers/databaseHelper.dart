import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

class DatabaseHelper {

  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() => _instance;

  /// Getter for the [Database] object.

  /// This method retrieves a reference to the application's database.
  /// It checks if the database is already opened, and if not, it calls the
  /// [initDatabase] method to initialize it.

  /// Returns:
  ///   A [Future] that resolves to the opened [Database] object.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }


  /// Initializes the application's database.
  /// This method creates the database file if it doesn't exist and defines
  /// the tables for storing various data related to pub crawls (challenges,
  /// users, locations, crawls, etc.).
  /// Returns:
  ///   A [Future] that resolves to the opened [Database] object.
  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'pub_crawls.db');
    Database db = await openDatabase(path, version: 1, onCreate: _createDb);
    return db;
  }

  /// Internal function used to create database tables during initialization.
  /// This method is private and not intended to be called directly. It's used
  /// internally by [initDatabase] to define the structure of the tables
  /// in the database using SQL statements.
  /// Parameters:
  ///   * [db]: The [Database] object to execute the SQL statements on.
  ///   * [version]: The database version number.
  Future<void> _createDb(Database db, int version) async {
    // Existing table creation...
    await db.execute('''
    CREATE TABLE Challenges(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      forfeit TEXT,
      type TEXT
    )
  ''');
    await db.execute('''
    CREATE TABLE Users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      photo_url TEXT,
      uid TEXT,
      unsplash_api_key TEXT,
      map_api_key TEXT,
      map_layer TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE Locations(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      orderPos INTEGER,
      name TEXT,
      description TEXT,
      city TEXT,
      country TEXT,
      postcode TEXT,
      street TEXT,
      houseNumber TEXT,
      website TEXT,
      amenity TEXT,
      openingHours TEXT,
      phone TEXT,
      outdoorSeating INTEGER,
      latitude REAL,
      longitude REAL
    )
  ''');

    await db.execute('''
    CREATE TABLE Crawls(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      description TEXT,
      city TEXT,
      individualChallenges INTEGER,
      groupChallenges INTEGER,
      individualChallengeChance REAL
    )
  ''');

    await db.execute('''
    CREATE TABLE CrawlLocations(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      crawl_id INTEGER,
      location_id INTEGER,
      FOREIGN KEY(crawl_id) REFERENCES Crawls(id),
      FOREIGN KEY(location_id) REFERENCES Locations(id)
    )
  ''');

    await db.execute('''
    CREATE TABLE CrawlLocationChallenges(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      crawl_id INTEGER,
      location_id INTEGER,
      challenge_id INTEGER,
      FOREIGN KEY(crawl_id) REFERENCES Crawls(id),
      FOREIGN KEY(location_id) REFERENCES Locations(id),
      FOREIGN KEY(challenge_id) REFERENCES Challenges(id)
    )
  ''');
  }

  /// Deletes the database file.
  /// This method attempts to delete the database file from the device storage.
  /// It handles potential platform-specific exceptions and logs any errors
  /// encountered during the deletion process.
  /// Returns:
  ///   A [Future] that completes the deletion operation (no return value).
  Future<void> deleteDatabaseFile() async {
    try {
      // Get the directory where the database file is stored
      String path = join(await getDatabasesPath(), 'pub_crawls.db');

      // Check if the database file exists
      if (await File(path).exists()) {
        // Delete the database file
        await File(path).delete();
      }
    } on PlatformException catch (e) {
      // Handle platform-specific exceptions
      debugPrint("Error: ${e.message}");
    }
  }

  /// Inserts a new record into a database table.
  /// This method inserts a new record into the specified database table.
  /// It takes the table name and a map containing the data to be inserted
  /// as parameters.
  /// Parameters:
  ///   * [table]: The name of the database table to insert data into.
  ///   * [data]: A map containing key-value pairs representing the data
  ///             for the new record.
  /// Returns:
  ///   A [Future] that resolves to the ID of the inserted record.
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  /// Updates an existing record in a database table.
  /// This method updates an existing record in the specified database table.
  /// It takes the table name, a map containing the updated data, and the ID
  /// of the record to update as parameters.
  /// Parameters:
  ///   * [table]: The name of the database table to update data in.
  ///   * [data]: A map containing key-value pairs representing the updated
  ///             data for the record.
  ///   * [id]: The ID of the record to update.
  /// Returns:
  ///   A [Future] that resolves to the number of rows affected by the update.
  Future<int> update(String table, Map<String, dynamic> data, int id) async {
    final db = await database;
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  /// Deletes a record from a database table.
  /// This method deletes a record from the specified database table based on
  /// its ID. It takes the table name and the ID of the record to delete as
  /// parameters.
  /// Parameters:
  ///   * [table]: The name of the database table to delete data from.
  ///   * [id]: The ID of the record to delete.
  /// Returns:
  ///   A [Future] that resolves to the number of rows affected by the delete.
  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  /// Retrieves a record from a database table by its ID.
  /// This method retrieves a record from the specified database table based on
  /// its ID. It takes the table name and the ID of the record to retrieve as
  /// parameters.
  /// Parameters:
  ///   * [table]: The name of the database table to query.
  ///   * [id]: The ID of the record to retrieve.
  /// Returns:
  ///   A [Future] that resolves to a map containing the data for the
  ///   retrieved record, or null if no record is found.
  Future<Map<String, dynamic>?> getById(String table, int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(table, where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? maps.first : null;
  }

  /// Retrieves all records from a database table.
  /// This method retrieves all records from the specified database table.
  /// It optionally allows filtering the results based on a WHERE clause
  /// and arguments.
  /// Parameters:
  ///   * [table]: The name of the database table to query.
  ///   * [where] (optional): A SQL WHERE clause to filter the results.
  ///   * [whereArgs] (optional): A list of arguments for the WHERE clause.
  /// Example Usage:
  ///   * List<Map<String, dynamic>> allChallenges = await DatabaseHelper().getAll('Challenges');
  ///   * List<Map<String, dynamic>> filteredChallenges = await DatabaseHelper().getAll('Challenges', where: 'type = ?', whereArgs: ['individual']);
  /// Returns:
  ///   A [Future] that resolves to a list of maps, where each map
  ///   represents a record in the table. The list might be empty if no
  ///   records match the criteria.
  Future<List<Map<String, dynamic>>> getAll(String table,
      {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }
}
