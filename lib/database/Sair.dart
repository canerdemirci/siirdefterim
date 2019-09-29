/*
** Şair Tablosu
*/

import 'package:sqflite/sql.dart';
import './database.dart';

class Sair {
  // Tablo alanları
  int id;
  String ad;

  // Tablo adı
  static final String tableName = 'sair';

  // Sütun isimleri
  static final String colId = 'id';
  static final String colAd = 'adsoyad';

  Sair({
    this.id,
    this.ad
  });

  Sair.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    ad = map[colAd];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colAd: ad,
    };

    if (id != null) map[colId] = id;
    
    return map;
  }
}

class SairProvider {
  Veritabani _vt = Veritabani();

  Future<List<Sair>> sairler() async {
    final db = await _vt.database;

    List<Map> maps = await db.query(
      Sair.tableName,
      orderBy: '${Sair.colAd} ASC',
    );

    if (maps.length > 0) {
      return maps.map((sair) => Sair.fromMap(sair)).toList();
    }      
    
    return null;
  }

  Future<Sair> insert(Sair sair) async {
    final db = await _vt.database;

    sair.id = await db.insert(
      Sair.tableName,
      sair.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );

    return sair;
  }
}