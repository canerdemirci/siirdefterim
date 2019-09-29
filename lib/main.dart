import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import './pages/home.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Şiir Defterim',
      home: Home(),
    );
  }
}