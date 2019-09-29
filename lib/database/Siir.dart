/*
** Şiir Tablosu Modeli
*/

import 'package:sqflite/sqflite.dart';
import './database.dart';

class Siir {
  // Tablo alanları
  int id;
  String ad;
  String metin;
  int sairId;
  String createdAt;

  // Tablo adı
  static final String tableName = 'siir';

  // Sütun isimleri
  static final String colId = 'id';
  static final String colAd = 'ad';
  static final String colMetin = 'metin';
  static final String colSairid = 'sair_id';
  static final String colCreatedat = 'created_at';

  // Veritabanı
  Veritabani _vt = Veritabani();

  Siir({
    this.id,
    this.ad,
    this.metin,
    this.sairId,
    this.createdAt
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colAd: ad,
      colMetin: metin,
      colSairid: sairId,
    };

    if (id != null) map[colId] = id;

    return map;
  }
}

class SiirProvider {
  Veritabani _vt = Veritabani();

  Future<Siir> insert(Siir siir) async {
    final db = await _vt.database;

    siir.id = await db.insert(
      Siir.tableName,
      siir.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );

    return siir;
  }
}