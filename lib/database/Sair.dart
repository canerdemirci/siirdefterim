/*
** Veritabanı sair tablosu modeli ve veri sağlayıcısı
*/

import 'package:sqflite/sql.dart';
import './database.dart';
import './Siir.dart';

/*
** sair tablosu modeli
*/
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

  // Veritabanından map olarak alınan veriyi Sair nesnesine dönüştür.
  Sair.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    ad = map[colAd];
  }

  // Veritabanına kaydetmek için Sair nesnesini map 'e dönüştür.
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colAd: ad,
    };

    // id bilgisi bazen gerekmeyebilir.
    if (id != null) map[colId] = id;
    
    return map;
  }
}

/*
** sair tablosunda vt işlemleri yapabilmek
** için Sair sınıfını kullanan sınıf.
*/
class SairProvider {

  Veritabani _vt = Veritabani();

  /*
  ** Tüm şairleri getirir.
  */
  Future<List<Sair>> sairler() async {
    final db = await _vt.database;

    List<Map> maps = await db.query(
      Sair.tableName,
      orderBy: '${Sair.colAd} ASC',
    );

    if (maps.length > 0) {
      // Map olarak gelen satırları Sair nesnelerinden oluşan listeye çevir.
      return maps.map((sair) => Sair.fromMap(sair)).toList();
    }      
    
    return null;
  }

  /*
  ** sair tablosuna satır ekler.
  */
  Future<Sair> insert(Sair sair) async {
    final db = await _vt.database;

    sair.id = await db.insert(
      Sair.tableName,
      sair.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );

    return sair;
  }

  /*
  ** sair tablosundan satır siler.
  ** Önce şairin tüm şiirlerini siler. Sonra şairi.
  ** transaction da hata olursa false döndürür.
  */
  Future<bool> delete(Sair sair) async {
    final db = await _vt.database;

    try {
      await db.transaction(
        (txn) async {
          await txn.delete(Siir.tableName, where: '${Siir.colSairid}=?', whereArgs: [sair.id]);
          await txn.delete(Sair.tableName, where: '${Sair.colId}=?', whereArgs: [sair.id]);
        }
      );
    } catch(_) {
      return false;
    }

    return true;
  }
}