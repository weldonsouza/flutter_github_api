import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/profile.dart';

class DatabaseRepositories {
  static List<Profile> favoritesProfiles = [];

  static const String login = 'login';
  static const String email = 'email';
  static const String nickname = 'nickname';
  static const String location = 'location';
  static const String bio = 'bio';
  static const String avatarUrl = 'avatarUrl';
  static const String TABLE = 'profiles';

  static Future<Database> _open() async {
    final Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'database.db'),
      onCreate: (db, version) {
        db.execute(
          "CREATE TABLE $TABLE($login TEXT, $email TEXT, $nickname TEXT, "
              "$location TEXT, $bio TEXT, $avatarUrl TEXT)",
        );
      },
      version: 1,
    );

    return database;
  }

  static Future<void> insertFavoriteProfile(Profile profile) async {
    final Database db = await _open();
    try {
      await db.insert(
        '$TABLE',
        profile.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      favoritesProfiles.add(profile);
    } catch (e) {}
  }

  static Future<List<Profile>> getProfiles() async {
    final Database db = await _open();

    final List<Map<String, dynamic>> maps = await db.query('$TABLE');

    return List.generate(
      maps.length,
      (i) {
        return Profile(
          nickname: maps[i]['nickname'],
          bio: maps[i]['bio'],
          email: maps[i]['email'],
          location: maps[i]['location'],
          login: maps[i]['login'],
          avatarUrl: maps[i]['avatarUrl'],
        );
      },
    );
  }

  static Future<void> removeFavoriteProfile(Profile profile) async {
    final Database db = await _open();

    try {
      await db.delete(
        '$TABLE',
        where: '$login = ?',
        whereArgs: [profile.login],
      );

      favoritesProfiles.remove(profile);
    } catch (e) {}
  }
}
