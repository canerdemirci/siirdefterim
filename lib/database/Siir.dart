/*
** Veritabanı siir tablosu modeli ve veri sağlayıcısı
*/

import 'package:sqflite/sqflite.dart';
import './database.dart';
import './Sair.dart';
import '../sabitler.dart';

/*
** siir tablosu modeli
*/
class Siir {

  // Tablo alanları
  int id;
  String ad;
  String metin;
  int sairId;
  String createdAt;

  // sair tablosuyla birleşiminden dolayı gelen şairadı alanı
  String sairad;

  // Tablo adı
  static final String tableName = 'siir';

  // Sütun isimleri
  static final String colId = 'id';
  static final String colAd = 'ad';
  static final String colMetin = 'metin';
  static final String colSairid = 'sair_id';
  static final String colCreatedat = 'created_at';
  // Şair tablosuyla birleşiminden dolayı gelen şair adı sütun ismi
  static final String colSairAd = 'sairad';

  Veritabani _vt = Veritabani();

  Siir({
    this.id,
    this.ad,
    this.metin,
    this.sairId,
    this.createdAt
  });

  // Veritabanından map olarak alınan veriyi Siir nesnesine dönüştür.
  Siir.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    ad = map[colAd];
    metin = map[colMetin];
    sairId = map[colSairid];
    createdAt = map[colCreatedat];

    // Sql de join işlemi varsa şairadı verisi alınır.
    if (map[colSairAd] != null) sairad = map[colSairAd];
  }

  // Veritabanına göndermek için sınıfı map 'e çevir.
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

/*
** siir tablosunda vt işlemleri yapabilmek
** için Siir sınıfını kullanan sınıf.
*/
class SiirProvider {

  Veritabani _vt = Veritabani();

  /*
  ** Bazı kriterlere göre vt'den şiirleri ve sorgudan dönen satır sayısını çeker ve
  ** Map nesnesi olarak döndürür.
  */
  Future<List<Siir>> siirler(int limit, int offset, int sairid, String aranacak, FILTRELER order) async {
    
    final db = await _vt.database;
    
    // Sql şartları için.
    String whereClause = '';
    String orderBy = 'ORDER BY ${Siir.tableName}.${Siir.colCreatedat} DESC';
    String limitClause = '';

    // Dönecek olan şiir satırları için
    List<Map> maps;

    // limit verilmişse sql 'e limit ifadesi ekle
    if (limit != null) {
      limitClause = 'LIMIT $limit OFFSET $offset';
    }

    // Bir şair id'si verilmişse sql'e where koşulu ekle.
    // Seçilen şairin şiirlerini döndürür.
    if (sairid != null) {
      whereClause = 'WHERE ${Siir.tableName}.${Siir.colSairid}=?';
    }

    // Şair veya Şiir adıyla arama yapılmak isteniyorsa where koşulunu ayarla.
    if (aranacak != null && aranacak.trim() != '') {
      whereClause = '''WHERE ${Siir.tableName}.${Siir.colAd} LIKE \'%$aranacak%\' 
      OR ${Sair.tableName}.${Sair.colAd} LIKE \'%$aranacak%\'''';
    }

    // Gelen satırların alfabetik veya tarihsel sıraya konması için orderby ifadesini ayarla
    // HEPSI filtresi seçilmişse where ifadesini boş tut, böylece tüm satırları çek.
    if (order == FILTRELER.HEPSI) whereClause = '';
    if (order == FILTRELER.TARIH) orderBy = 'ORDER BY ${Siir.tableName}.${Siir.colCreatedat} DESC';
    if (order == FILTRELER.ALFABETIK) orderBy = 'ORDER BY ${Siir.tableName}.${Siir.colAd} ASC';

    // Veritabanına yollanacak sql ifadesi.
    // siir ve sair tablosunu birleştirerek sonuç döndürür.
    String sql = '''
      SELECT 
      ${Siir.tableName}.${Siir.colId},
      ${Siir.tableName}.${Siir.colAd},
      ${Siir.tableName}.${Siir.colMetin},
      ${Siir.tableName}.${Siir.colCreatedat},
      ${Siir.tableName}.${Siir.colSairid}, 
      ${Sair.tableName}.${Sair.colAd} AS ${Siir.colSairAd} 
      FROM ${Siir.tableName} 
      INNER JOIN ${Sair.tableName} on ${Sair.tableName}.${Sair.colId}=${Siir.tableName}.${Siir.colSairid} 
      $whereClause 
      $orderBy 
      $limitClause
    ''';

    // Veritabanındaki şiirleri çeker.
    if (whereClause != '' && sairid != null) {
      maps = await db.rawQuery(sql, [sairid]);
    } else {
      maps = await db.rawQuery(sql);
    }
        

    // Vt'de şiir varsa şiir listesi ve şiir sayısını döndür.
    if (maps.length > 0) {
      return maps.map((siir) => Siir.fromMap(siir)).toList();
    }   
    
    return null;
  }

  /*
  ** Siir tablosuna satır ekler.
  ** İşlem başarılıysa eklenen satırın id'si alınır ve
  ** Siir nesnesi döndürülür. Aksi halde null.
  */
  Future<Siir> insert(Siir siir) async {

    final db = await _vt.database;

    siir.id = await db.insert(
      Siir.tableName,
      siir.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );

    if (siir.id != null) return siir;

    return null;
  }

  /*
  ** Belirtilen şiiri siler.
  ** int döndürür. 0 = başarısız, 1 = başarılı
  */
  Future<int> delete(Siir siir) async {

    final db = await _vt.database;

    int result = await db.delete(Siir.tableName, where: '${Siir.colId}=?', whereArgs: [siir.id]);

    return result;
  }
}