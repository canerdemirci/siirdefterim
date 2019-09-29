import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import './Sair.dart';
import './Siir.dart';

class Veritabani {
  static final Veritabani _vtInstance = Veritabani.internal();

  factory Veritabani() => _vtInstance;
  static Database _db;

  Veritabani.internal();

  final String _dbName = 'siirdefteridb.db';
  
  final String _siirTableSql = '''
    CREATE TABLE ${Siir.tableName}(
      ${Siir.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${Siir.colAd} VARCHAR(150) NOT NULL,
      ${Siir.colMetin} TEXT NOT NULL,
      ${Siir.colSairid} INT NOT NULL,
      ${Siir.colCreatedat} TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(${Siir.colSairid}) REFERENCES sair(id)
    );
  ''';

  final String _sairTableSql = '''
    CREATE TABLE ${Sair.tableName}(
      ${Sair.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${Sair.colAd} VARCHAR(100) NOT NULL
    );
  ''';

  Future<Database> get database async {
    // Cihazın veritabanı saklama yolu
    final databasesPath = await getDatabasesPath();

    // Veritabanı klasörü mevcut değilse yarat
    try {
      await Directory(databasesPath).create(recursive: true);
    } catch(_) {}

    // Veritabanı dosyamızın tam adresi
    final String path = p.join(databasesPath, _dbName);

    if (_db != null) {
      return _db;
    } else {
      _db = await openDatabase(
        path,
        
        // Veritabanı ilk defa açıldığında
        onCreate: _onCreate,

        version: 1,
      );

      return _db;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabloları oluştur.
    await db.execute(_siirTableSql);
    await db.execute(_sairTableSql);
  }
}