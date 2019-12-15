/*
** Ayarlar sayfası
*/

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SettingsPage extends StatefulWidget {

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _yedAlShow = true;

  GlobalKey<ScaffoldState> _scfKey = GlobalKey<ScaffoldState>();

  Future<String> get _externalPath async {
    final directory = await getExternalStorageDirectory();

    return directory.path;
  }

  Future<String> get _dbPath async {
    return p.join(await getDatabasesPath(), 'siirdefteridb.db');
  }

  Future<File> get _dbFile async {
    final path = await _dbPath;

    return File(path);
  }

  Future<File> copyDb() async {
    final file = await _dbFile;
    final path = await _externalPath;
    final newfile = '$path/siirdefteridb.db';

    try {
      return file.copy(newfile);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  Future<File> copyFile(File file) async {
    final olddbpath = await _dbPath;

    try {
      return file.copy(olddbpath);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scfKey,
      appBar: AppBar(
        title: Text('Ayarlar'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _yedAlShow ? RaisedButton(
              child: Text('YEDEK AL'),
              onPressed: () async {
                setState(() => _yedAlShow = false);
                var res = await copyDb();

                if (res != null) {
                  _scfKey.currentState.showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('İşlem Başarılı'),
                    ),
                  );

                  setState(() => _yedAlShow = false);
                  await Share.file('Vt Yedek', 'yedek.db', await res.readAsBytes(), '*/*');
                  setState(() => _yedAlShow = true);
                } else {
                  _scfKey.currentState.showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('İşlem Başarısız'),
                    ),
                  );
                  setState(() => _yedAlShow = true);
                }
              },
            ) : LinearProgressIndicator(),

            RaisedButton(
              child: Text('GERİ YÜKLE'),
              onPressed: () async {
                File file = await FilePicker.getFile(type: FileType.ANY);
                var result;
                if (file != null) result = await copyFile(file);

                if (result != null) {
                  _scfKey.currentState.showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('İşlem Başarılı'),
                    ),
                  );
                } else {
                  _scfKey.currentState.showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('İşlem Başarısız'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}