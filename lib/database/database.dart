import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import './Sair.dart';
import './Siir.dart';

class Veritabani {
  final String _dbName = 'siirdefteridb.db';
  
  final String _siirTableSql = '''
    CRETAE TABLE siir(
      ${Siir.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${Siir.colAd} VARCHAR(150) NOT NULL,
      ${Siir.colMetin} TEXT NOT NULL,
      ${Siir.colSairid} INT NOT NULL,
      ${Siir.colCreatedat} TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(${Siir.colSairid}) REFERENCES sair(id)
    );
  ''';
  final String _sairTableSql = '''
    CREATE TABLE sair(
      ${Sair.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${Sair.colAd} VARCHAR(100) NOT NULL,
    );
  ''';

  static final Veritabani _vt = Veritabani._internal();

  factory Veritabani() {
    return _vt;
  }

  Veritabani._internal();

  /*
  ** Veritabanı elde et
  */
  Future<Database> get database async {
    // Cihazın veritabanı saklama yolu
    final databasesPath = await getDatabasesPath();
    // Veritabanı dosyamızın tam adresi
    final String path = p.join(databasesPath, _dbName);

    // Veritabanı klasörü mevcut değilse yarat
    try {
      await Directory(databasesPath).create(recursive: true);
    } catch(_) {}

    // Veritabanını elde et
    var db = await openDatabase(
      path,
      
      // Veritabanı ilk defa açıldığında
      onCreate: _onCreate,

      version: 1,
    );

    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabloları oluştur.
    await db.execute(_siirTableSql);
    await db.execute(_sairTableSql);
  }
}