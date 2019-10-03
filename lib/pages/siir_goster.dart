// Şiiri gösteren sayfa.

import 'dart:ui';
import 'package:flutter/material.dart';
import '../database/Siir.dart';
import 'package:simple_animations/simple_animations.dart';

class SiirGosterPage extends StatelessWidget {

  // Gösterilecek şiir.
  final Siir siir;

  SiirGosterPage(this.siir);

  // Şiir başlık ve metninde kullanılacak yazı stili.
  TextStyle _tstyle(String tur) {
    return TextStyle(
      color: Colors.white,
      fontSize: tur == 'baslik' ? 28.0 : 18.0,
      fontWeight: FontWeight.bold,
      fontFamily: 'Mukta',
      shadows: [
        Shadow(
          blurRadius: 1.0,
          color: Colors.black.withOpacity(0.8),
          offset: Offset(1.0, 1.0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    // Arkaplan gradient animasyonu için.
    final tween = MultiTrackTween([
      Track("color1").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xffD38312), end: Colors.lightBlue.shade900)),
      Track("color2").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xffA83279), end: Colors.blue.shade600))
    ]);

    var _controlledAnimation = ControlledAnimation(
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (context, animation) => Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [animation["color1"], animation["color2"]],
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.0)
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      body: Stack(
        children: <Widget>[

          _controlledAnimation,

          Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 40.0),
                  Text(siir.ad, style: _tstyle('baslik')),
                  SizedBox(height: 10.0),
                  Text(siir.metin, style: _tstyle(null)),
                  SizedBox(height: 10.0),
                  Text(siir.sairad, style: _tstyle(null)),
                  SizedBox(height: 40.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}