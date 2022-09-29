import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/centerDataRes.dart';

class SqlFavoriteUtil {
  static Future<Database> initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'favorite_database.db'),
      onCreate: (db, version) {
        return db.execute("CREATE TABLE favorite(id TEXT PRIMARY KEY, address TEXT, sido TEXT, centerName TEXT, lat TEXT, lng TEXT, phoneNumber TEXT)");
      },
      version: 1,
    );
  }

  static Future<List<CenterData>> getFavorite(Future<Database> db) async {
    final Database database = await db;
    final List<Map<String, dynamic>> maps = await database.query('favorite');
    print('maps : ${maps.length}');
    return List.generate(maps.length, (index) {
      return CenterData(
          id: maps[index]['id'].toString(),
          address: maps[index]['address'].toString(),
          sido: maps[index]['sido'].toString(),
          centerName: maps[index]['centerName'].toString(),
          lat: maps[index]['lat'].toString(),
          lng: maps[index]['lng'].toString(),
          phoneNumber: maps[index]['phoneNumber'].toString()
      );
    });
  }

  static void insertFavorite(Future<Database> db, CenterData data) async {
    Map<String, dynamic> map =
    {
      'id' : data.id,
      'address' : data.address,
      'sido' : data.sido,
      'centerName' : data.centerName,
      'lat' : data.lat,
      'lng' : data.lng,
      'phoneNumber' : data.phoneNumber
    };
    final Database database = await db;
    await database.insert('favorite', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static void deleteFavorite(Future<Database> db, CenterData data) async {
    final Database database = await db;
    await database.delete('favorite', where: 'id = ?', whereArgs: [data.id]);  // id 값으로 수정할 데이터 찾기
  }
}