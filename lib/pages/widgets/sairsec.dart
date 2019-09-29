import 'package:flutter/material.dart';
import '../../database/Sair.dart';

class SairSec extends StatefulWidget {
  final List<Sair> data;

  SairSec({ this.data });

  @override
  _SairSecState createState() => _SairSecState();
}

class _SairSecState extends State<SairSec> {
  int _value;

  @override 
  void initState() {
    super.initState();

    _value = widget.data.first.id;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: _value,
      icon: Icon(Icons.arrow_downward),
      onChanged: (int newValue) {
        setState(() {
         _value = newValue; 
        });
      },
      items: _list()
    );
  }

  List<DropdownMenuItem<int>> _list() {
    List<DropdownMenuItem<int>> items = List<DropdownMenuItem<int>>();

    widget.data.forEach(
      (sair) => items.add(DropdownMenuItem<int>(
        value: sair.id,
        child: Text(sair.ad),
      ))
    );

    return items;
  }
}