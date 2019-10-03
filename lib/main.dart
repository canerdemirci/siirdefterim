import 'package:flutter/material.dart';
import './pages/home.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Şiir Defterim',
      theme: ThemeData(
        primaryColor: Colors.red[400],
      ),
      home: Home(),
    );
  }
}