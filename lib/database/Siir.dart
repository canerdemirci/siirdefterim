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
  Future<Map<String, dynamic>> siirler(int limit, int sairid, String aranacak, FILTRELER order) async {
    
    final db = await _vt.database;
    
    // Sql şartları için.
    String whereClause = '';
    String orderBy = '';
    String limitClause = '';

    // Dönecek olan şiir satırları için
    List<Map> maps;

    // Sorgudan dönen satır sayısı
    int siirsayisi = 0;

    // limit verilmişse sql 'e limit ifadesi ekle
    if (limit != null) {
      limitClause = 'LIMIT $limit OFFSET 0';
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
    if (order == FILTRELER.SAIRADI) orderBy = 'ORDER BY ${Siir.tableName}.${Siir.colAd} ASC';

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

    // İlk sql ifadesine benzer sadece satır sayısını döndürür.
    // Ayrı bir ifade yapmamın sebebi ilk sorguda limit kullanılıyor bu yüzden toplam şiir sayısını vermez.
    String sql2 = '''SELECT COUNT(*) FROM ${Siir.tableName} INNER JOIN ${Sair.tableName} on 
    ${Sair.tableName}.${Sair.colId}=${Siir.tableName}.${Siir.colSairid} $whereClause''';

    // Veritabanındaki şiirleri ve toplam şiir sayısını çeker.
    // transaction başarısız olursa null döndürür.
    try {
      await db.transaction(
        (txn) async {
          // Query fonksiyonlarında bug olduğundan fazlaca if kullanmak zorunda kaldım.
          if (whereClause != '' && sairid != null) {
            maps = await txn.rawQuery(sql, [sairid]);
            siirsayisi = Sqflite.firstIntValue(await txn.rawQuery(sql2, [sairid]));
          } else {
            maps = await txn.rawQuery(sql);
            siirsayisi = Sqflite.firstIntValue(await txn.rawQuery(sql2));
          }
        }
      );
    } catch(ex) {
      print(ex.toString());
      return null;
    }

    // Vt'de şiir varsa şiir listesi ve şiir sayısını döndür.
    if (maps.length > 0) {
      return {
        'siirler': maps.map((siir) => Siir.fromMap(siir)).toList(),
        'siirsayisi': siirsayisi,
      };
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