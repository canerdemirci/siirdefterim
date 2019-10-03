import 'package:flutter/material.dart';
import 'package:siirdefterim/pages/siir_goster.dart';
import './siir_ekle.dart';
import '../database/Siir.dart';
import '../database/Sair.dart';
import '../sabitler.dart';

class Home extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SiirProvider _siirProvider = SiirProvider();
  SairProvider _sairProvider = SairProvider();

  final _scfKey = GlobalKey<ScaffoldState>();

  int _siirLimit = 2;
  int _defaultSiirLimit = 2;
  int _siirArtis = 2;
  var _saireGore;
  String _aranacak;

  bool _searchMode = false;

  FILTRELER _selection = FILTRELER.TARIH;
  PopupMenuButton<FILTRELER> _popupMenuButton;

  @override
  void initState() {
    super.initState();

    _popupMenuButton = PopupMenuButton<FILTRELER>(
      icon: Icon(Icons.filter_list),
      onSelected: (FILTRELER res) {
        if (res != _selection) {
          setState(() {
            _selection = res; 

            // Tümünü göster seçilirse arama kriteri ve şair kriteri olmasın.
            if (_selection == FILTRELER.HEPSI) {
              _siirLimit = _defaultSiirLimit;
              _aranacak = null;
              _saireGore = null;
            }
          });
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<FILTRELER>>[
        const PopupMenuItem<FILTRELER>(
          value: FILTRELER.HEPSI,
          child: Text('Tümünü Göster'),
        ),
        const PopupMenuItem<FILTRELER>(
          value: FILTRELER.TARIH,
          child: Text('Yeniden-Eskiye'),
        ),
        const PopupMenuItem<FILTRELER>(
          value: FILTRELER.SAIRADI,
          child: Text('Alfabetik'),
        ),
      ],
    );
  }

  void _searchModeOnOff(bool onoff) {
    if (onoff) {
      // On
      _searchMode = true;
      _saireGore = null;
      _siirLimit = null;
    } else {
      // Off
      _searchMode = false;
      _aranacak = null;
      _siirLimit = _defaultSiirLimit;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scfKey,
      appBar: AppBar(
        title: _searchMode == false ? Text('Şiir Defterim', style: TextStyle(fontFamily: 'Courgette')) : TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Şiir veya Şair adıyla ara...',
          ),
          onChanged: (val) {
            if (val.trim() != '') {
              setState(() {
                _aranacak = val;
                _searchModeOnOff(true);
              });
            }
          },
        ),
        actions: _searchMode == false ? <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => setState(() => _searchMode = true),
          ),
          _popupMenuButton,
        ] : <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => setState(() {
              _searchModeOnOff(false);
            }),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              padding: const EdgeInsets.all(0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Image.asset(
                      'assets/images/nazim.png',
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Caner Demirci\n'),
                        Text('Şiir Defterim'),
                        Text('2019 Flutter Çalışmam')
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _sairProvider.sairler(),
                builder: (context, snapshot) {
                  switch(snapshot.connectionState) {
                    case ConnectionState.active: break;
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    break;
                    case ConnectionState.none: break;
                    case ConnectionState.done:
                      if (snapshot.data != null) {
                        List<Sair> sairler = snapshot.data;

                        return ListView.separated(
                          separatorBuilder: (context, i) => Divider(),
                          itemCount: sairler.length,
                          itemBuilder: (context, i) {
                            return ListTile(
                              leading: Icon(Icons.star, color: Colors.yellow[800]),
                              title: Text(sairler[i].ad, style: TextStyle(fontSize: 18.0, color: Colors.grey[900])),
                              onTap: () {
                                setState(() {
                                  _searchMode = false;
                                  _saireGore = sairler[i].id;
                                  _siirLimit = _defaultSiirLimit;
                                  _aranacak = null;
                                  _selection = FILTRELER.TARIH;
                                });
                                Navigator.pop(context); // Drawer i kapatır
                              },
                              onLongPress: () async {
                                var result = await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => AlertDialog(
                                    title: Text('Şair Sil'),
                                    content: Text('Şairi silerseniz tüm şiirleri de silinecek. Emin misiniz?'),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('HAYIR'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      FlatButton(
                                        child: Text('EVET'),
                                        onPressed: () async {
                                          bool res = await _sairProvider.delete(sairler[i]);
                                          Navigator.pop(context, res);
                                        },
                                      ),
                                    ],
                                  ),
                                );

                                if (result) {
                                  setState(() {});
                                } else {
                                  _scfKey.currentState.showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text('Bir hata oluştu.'),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        );
                      }
                    break;
                  }

                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red[400],
        child: Icon(Icons.add),
        onPressed: () async {
          var res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SiireklePage(),
              fullscreenDialog: true,
            )
          );

          if (res != null) setState(() {});
        },
      ),
      body: _siirListWidget(),
    );
  }

  Widget _siirListWidget() {
    return FutureBuilder(
      future: _siirProvider.siirler(_siirLimit, _saireGore, _aranacak, _selection),
      builder: (context, snapshot) {
        switch(snapshot.connectionState) {
          case ConnectionState.active: break;
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          break;
          case ConnectionState.none: break;
          case ConnectionState.done:
            if (snapshot.data != null) {
              List<Siir> siirler = snapshot.data['siirler'];
              int siirsayisi = snapshot.data['siirsayisi'];

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 100.0),
                itemCount: siirler.length + 1, // +1 dahası butonu için
                itemBuilder: (context, i) {
                  if (i < siirler.length) {
                    return Container(
                      color: i.isEven ? Colors.grey[100] : Colors.white,
                      child: ListTile(
                        title: Text(siirler[i].ad, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(siirler[i].sairad),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {                              
                              return SiirGosterPage(siirler[i]);
                            },
                            fullscreenDialog: true,
                          ),
                        ),
                        onLongPress: () async {
                          var result = await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AlertDialog(
                              title: Text('Şiiri Sil'),
                              content: Text('Silmek istediğinizden emin misiniz?'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('HAYIR'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                FlatButton(
                                  child: Text('EVET'),
                                  onPressed: () async {
                                    int result = await _siirProvider.delete(siirler[i]);
                                    Navigator.pop(context, result);
                                  }
                                ),
                              ],
                            ),
                          );

                          if (result == 1) setState((){});
                        },
                      ),
                    );
                  }

                  return (siirler.length < siirsayisi) && (_searchMode == false) ? IconButton(
                    icon: Icon(Icons.keyboard_arrow_down, size: 100.0, color: Colors.grey[300]),
                    iconSize: 100.0,
                    onPressed: () => setState(() => _siirLimit += _siirArtis),
                  ) : Container();
                },
              );
            }
          break;
        }

        return Center(
          child: Text('Hiç Şiir Yok'),
        );
      },
    );
  }
}