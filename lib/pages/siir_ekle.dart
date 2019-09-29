import 'package:flutter/material.dart';
import './widgets/sairsec.dart';
import '../database/Sair.dart';
import '../database/Siir.dart';

class SiireklePage extends StatefulWidget {
  @override
  _SiireklePageState createState() => _SiireklePageState();
}

class _SiireklePageState extends State<SiireklePage> {
  final _formKey = GlobalKey<FormState>();
  final _bosMsg = 'Bu alan boş bırakılamaz.';
  final TextEditingController _sairAdiController = TextEditingController();
  final _sairProvider = SairProvider();
  final _siirProvider = SiirProvider();

  final TextEditingController _siirAdiController = TextEditingController();
  final TextEditingController _siirMetniController = TextEditingController();

  List<Sair> _sairler;

  int _seciliSairId;

  Future<void> _sairleriGetir() async {
    var s = await _sairProvider.sairler();
    setState(() => _sairler = s);
  }

  @override
  void initState() {
    super.initState();
    
    _sairleriGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Şiir Ekle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            // Şiir adı
            TextFormField(
              controller: _siirAdiController,
              decoration: InputDecoration(
                hintText: 'Şiir Adı',
              ),
              maxLength: 150,
              validator: (text) {
                if (text.isEmpty) return _bosMsg;
                else return null;
              },
            ),

            // Şiir metni
            TextFormField(
              controller: _siirMetniController,
              decoration: InputDecoration(
                hintText: 'Şiir Metni',
              ),
              keyboardType: TextInputType.multiline,
              validator: (text) {
                if (text.isEmpty) return _bosMsg;
                else return null;
              },
            ),

            // Şair
            _sairler == null ? Container() : SairSec(data: _sairler),

            // Kaydet butonu
            RaisedButton(
              child: Text('Kaydet'),
              onPressed: () async {
                if (_seciliSairId == null) {
                  // Şair seçilmemiş
                  //#burada uyarı mesajı ver
                } else {
                  // Şair seçilmişse ve form hatasız ise şiiri sisteme kaydet
                  if (_formKey.currentState.validate()) {
                    await _siirProvider.insert(Siir(
                      ad: _siirAdiController.text.trim(),
                      metin: _siirMetniController.text.trim(),
                      sairId: _seciliSairId,
                    ))
                  } else {
                    // Form hatalı uyarı mesajı
                  }
                }
              },
            ),

            // Şair ekle butonu
            RaisedButton(
              child: Text('Şair Ekle'),
              onPressed: () async {
                await showDialog(
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
                      RaisedButton(
                        child: Text('KAPAT'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      RaisedButton(
                        child: Text('KAYDET'),
                        onPressed: () async {
                          String text = _sairAdiController.text.trim();
                          if (text.length > 0) {
                            await _sairProvider.insert(Sair(ad: _sairAdiController.text));
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  )
                );

                _sairleriGetir();
              },
            ),
          ],
        ),
      ),
    );
  }
}