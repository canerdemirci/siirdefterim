import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './widgets/sairsec.dart';
import '../database/Sair.dart';
import '../database/Siir.dart';
import '../string_helper.dart';

class SiireklePage extends StatefulWidget {
  @override
  _SiireklePageState createState() => _SiireklePageState();
}

class _SiireklePageState extends State<SiireklePage> {
  final _formKey = GlobalKey<FormState>();
  final _scfKey = GlobalKey<ScaffoldState>();
  final _bosMsg = 'Bu alan boş bırakılamaz.';
  final TextEditingController _sairAdiController = TextEditingController();
  final _sairProvider = SairProvider();
  final _siirProvider = SiirProvider();

  final TextEditingController _siirAdiController = TextEditingController();
  final TextEditingController _siirMetniController = TextEditingController();

  List<Sair> _sairler;

  int _seciliSairId;

  Future<void> _sairleriGetir(int istenenid) async {
    var s = await _sairProvider.sairler();
    setState(() {
      _sairler = s;
      if (istenenid == null) 
        _seciliSairId = s.first.id;
      else
        _seciliSairId = istenenid;
    });
  }

  void _sairOnchanged(int val) {
    setState(() {
      _seciliSairId = val;
    });
  }

  @override
  void initState() {
    super.initState();
    
    _sairleriGetir(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scfKey,
      appBar: AppBar(
        title: Text('Şiir Ekle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            // Şiir adı
            TextFormField(
              controller: _siirAdiController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(8.0),
                hintText: 'Şiir Adı',
                hintStyle: TextStyle(color: Colors.red[400]),
                suffix: InkWell(
                  child: Icon(Icons.content_paste),
                  onTap: () async {
                    ClipboardData d = await Clipboard.getData('text/plain');
                    _siirAdiController.text = d.text;
                  },
                ),
              ),
              maxLength: 150,
              maxLines: 1,
              expands: false,
              validator: (text) {
                if (text.isEmpty) return _bosMsg;
                else return null;
              },
            ),

            SizedBox(height: 30.0),

            // Şiir metni
            Container(
              height: 500.0,
              child: TextFormField(expands: true,
                controller: _siirMetniController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(8.0),
                  hintText: 'Şiir Metni',
                  hintStyle: TextStyle(color: Colors.red[400]),
                  suffix: InkWell(
                    child: Icon(Icons.content_paste),
                    onTap: () async {
                      ClipboardData d = await Clipboard.getData('text/plain');
                      _siirMetniController.text = d.text;
                    },
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                validator: (text) {
                  if (text.isEmpty) return _bosMsg;
                  else return null;
                },
              ),
            ),

            SizedBox(height: 30.0),

            // Şair
            _sairler == null ? 
              Text('Hiç şair yok. Bir şair ekleyin.') : 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(flex: 9, child: SairSec(value: _seciliSairId, data: _sairler, onChanged: _sairOnchanged)),
                  SizedBox(width: 5.0),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      child: Icon(Icons.add, size: 35.0, color: Colors.red[400]),
                      onTap: () async {
                        int id = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Şair Ekle'),
                            content: TextField(
                              decoration: InputDecoration(
                                hintText: 'Şair adı giriniz.',
                              ),
                              maxLength: 100,
                              controller: _sairAdiController,
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('KAPAT'),
                                onPressed: () => Navigator.pop(context),
                              ),
                              FlatButton(
                                child: Text('KAYDET'),
                                onPressed: () async {
                                  String text = _sairAdiController.text.trim();
                                  if (text.length > 0) {
                                    Sair sair = await _sairProvider.insert(Sair(ad: basHarfleriBuyult(text)));
                                    Navigator.pop(context, sair.id);
                                  }
                                },
                              ),
                            ],
                          )
                        );

                        _sairleriGetir(id == null ? null : id);
                      },
                    ),
                  ),
                ],
              ),

            SizedBox(height: 30.0),

            // Kaydet butonu
            RaisedButton(
              child: Text('Kaydet', style: TextStyle(color: Colors.white, fontSize: 20.0)),
              color: Colors.red[400],
              onPressed: () async {
                if (_seciliSairId == null) {
                  // Şair seçilmemiş
                  _scfKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text('Şair Seçmelisiniz'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  // Şair seçilmişse ve form hatasız ise şiiri sisteme kaydet
                  if (_formKey.currentState.validate()) {
                    Siir siir = await _siirProvider.insert(Siir(
                      ad: basHarfleriBuyult(_siirAdiController.text.trim()),
                      metin: _siirMetniController.text.trim(),
                      sairId: _seciliSairId,
                    ));

                    Navigator.pop(context, siir);
                  } else {
                    // Form hatalı uyarı mesajı
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}