import 'package:flutter/material.dart';
import 'package:siirdefterim/pages/settings.dart';
import 'package:siirdefterim/pages/siir_goster.dart';
import './siir_ekle.dart';
import '../database/Siir.dart';
import '../database/Sair.dart';
import '../sabitler.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _siirProvider = SiirProvider();
  final _sairProvider = SairProvider();

  // Sayfayı her kaydırışta en fazla 11 şiir listelenir.
  final _limit = 11;
  
  int _offset = 0; // sql sorgusu için
  bool _searchMode = false;
  bool _islemHalinde = false; // Vt'den veri çekilirken progress bar göstermek için
  FILTRELER _selection = FILTRELER.HEPSI; // Listeleme şekli seçmek için
  int _sairid; // Belli bir şairin şiirleri listelensin diye

  // Şiir listesi
  List<Siir> _siirList = List<Siir>();

  ScrollController _scrollController = ScrollController();

  GlobalKey<ScaffoldState> _scfKey = GlobalKey<ScaffoldState>();

  // Şiir yükleniyor barı
  Widget _pbar = Center(child: CircularProgressIndicator());
  // Şiir yok yazısı
  Widget _syok = Center(child: Text('Şiir Yok.'));

  /*
  ** Şairleri yan menüye getir.
  */
  ListView _sairListGetir(List<Sair> sairler) {
    return ListView.separated(
      separatorBuilder: (context, i) => Divider(),
      itemCount: sairler.length,
      itemBuilder: (context, i) {
        return ListTile(
          leading: Icon(Icons.star, color: Colors.yellow[800]),
          title: Text(sairler[i].ad, style: TextStyle(fontSize: 18.0, color: Colors.grey[900])),
          
          // Şairin şiirlerini göster
          onTap: () {
            // Şairin şiirleri alfabetik olarak listelensin. (default)
            _selection = FILTRELER.ALFABETIK;
            _siirListGuncelle(
              bastan: true,
              sairid: sairler[i].id,
            );
            _sairid = sairler[i].id;
            Navigator.pop(context);
          },

          // Şairi sil
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
              _siirListGuncelle(bastan: true);
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

  Future<void> _siirListGuncelle({bool bastan = false, int sairid, String aranacak}) async {
    if (bastan) {
      _siirList.clear();
      _offset = 0;
    }

    _islemHalinde = true;
    List<Siir> res = await _siirProvider.siirler(_limit, _offset, sairid, aranacak, _selection);
    _islemHalinde = false;

    if (res != null) {
      setState(() => _siirList.addAll(res));
    } else {
      if (bastan) setState(() { _siirList.clear(); });
    }
  }

  @override 
  void initState() {
    super.initState();

    _siirListGuncelle(bastan: true);

    // Sayfa en aşağı kadar kaydırılmışsa şiir çek ve ekle
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _offset += _limit;
        _siirListGuncelle(bastan: false, sairid: _sairid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Text title = Text(
      'Şiir Defterim',
      style: TextStyle(
        fontFamily: 'Courgette',
      ),
    );

    TextField searchBox = TextField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Şiir veya Şair adıyla ara...',
      ),
      onChanged: (val) {
        if (val != '') {
          _siirListGuncelle(
            bastan: true,
            aranacak: val,
          );
        }
      },
    );

    IconButton searchBtn = IconButton(
      icon: Icon(Icons.search),
      onPressed: () {
        setState(() {
          _siirList.clear();
          _searchMode = true;
          _selection = FILTRELER.ALFABETIK;
        });
      },
    );

    IconButton closeBtn = IconButton(
      icon: Icon(Icons.close),
      onPressed: () {
        _searchMode = false;
        _selection = FILTRELER.HEPSI;
        _siirListGuncelle(bastan: true);
      },
    );

    PopupMenuButton<FILTRELER> popupMenuBtn = PopupMenuButton<FILTRELER>(
      icon: Icon(Icons.filter_list),
      itemBuilder: (context) => <PopupMenuEntry<FILTRELER>>[
        const PopupMenuItem<FILTRELER>(
          value: FILTRELER.HEPSI,
          child: Text('Tümünü Göster'),
        ),
        const PopupMenuItem<FILTRELER>(
          value: FILTRELER.ALFABETIK,
          child: Text('Alfabetik'),
        ),
        const PopupMenuItem<FILTRELER>(
          value: FILTRELER.TARIH,
          child: Text('Yeniden-Eskiye'),
        ),
      ],
      onSelected: (selected) {
        if (selected != _selection) {
          _selection = selected;
          _siirListGuncelle(
            bastan: true,
            sairid: _sairid,
          );
        }
      },
    );
        
    AppBar appBar = AppBar(
      title: _searchMode == false ? title : searchBox,
      actions: <Widget>[
        _searchMode == false ? searchBtn : closeBtn,
        popupMenuBtn,
      ],
    );

    DrawerHeader drawerHeader = DrawerHeader(
      padding: const EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Image.asset('assets/images/nazim.png'),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Caner DEMİRCİ\n'),
                Text('Şiir Defterim'),
                Text('2019 Flutter Çalışmam'),
                SizedBox(height: 10.0),
                Container(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsPage(),
                        )
                      );
                      _siirListGuncelle(bastan: true);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    FutureBuilder sairListWidget = FutureBuilder(
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
              return _sairListGetir(snapshot.data);
            }
            
          break;
        }

        return Center(
          child: Text('Sistemde hiç şair yok.'),
        );
      },
    );

    Drawer drawer = Drawer(
      child: Column(
        children: <Widget>[
          drawerHeader,
          Expanded(child: sairListWidget),
        ],
      ),
    );

    FloatingActionButton floatingActionButton = FloatingActionButton(
      backgroundColor: Colors.red[400],
      child: Icon(Icons.add),
      onPressed: () async {
        var res = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SiireklePage(),
            fullscreenDialog: true,
          ),
        );

        if (res != null) {
          _selection = FILTRELER.HEPSI;
          _siirListGuncelle(bastan: true);
        }
      },
    );

    ListView siirListView = ListView.builder(
      controller: _scrollController,
      itemCount: _siirList.length,
      itemBuilder: (context, i) {
        return Container(
          color: i.isEven ? Colors.grey[100] : Colors.white,
          child: _islemHalinde ? _pbar : ListTile(
            title: Text(_siirList[i].ad, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_siirList[i].sairad),

            // Şiir göster
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SiirGosterPage(_siirList[i]),
                  fullscreenDialog: true,
                ),
              );
            },

            // Şiir sil
            onLongPress: () async {
              var res = await showDialog(
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
                        int res = await _siirProvider.delete(_siirList[i]);
                        Navigator.pop(context, res);
                      },
                    ),
                  ],
                ),
              );

              if (res == 1) setState(() => _siirList.removeAt(i));
            },
          ),
        );
      },
    );

    return Scaffold(
      key: _scfKey,
      appBar: appBar,
      drawer: _searchMode == false ? drawer : null,
      floatingActionButton: floatingActionButton,
      body: _islemHalinde ? _pbar : (_siirList.isEmpty ? _syok : siirListView),
    );
  }
}