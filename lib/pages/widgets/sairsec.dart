/*
** Şair seçme kutusu
*/

import 'package:flutter/material.dart';
import '../../database/Sair.dart';

class SairSec extends StatefulWidget {
  
  final List<Sair> data;
  final Function onChanged;
  final int value;

  SairSec({ this.value, this.data, this.onChanged });

  @override
  _SairSecState createState() => _SairSecState();
}

class _SairSecState extends State<SairSec> {
  int _value;

  @override 
  void initState() {
    super.initState();

    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    _value = widget.value;
    
    return DropdownButton<int>(
      value: _value,
      onChanged: (val) {
        _value = val;
        widget.onChanged(val);
      },
      underline: DropdownButtonHideUnderline(child: Container()),
      items: _list()
    );
  }

  List<DropdownMenuItem<int>> _list() {
    List<DropdownMenuItem<int>> items = List<DropdownMenuItem<int>>();

    widget.data.forEach(
      (sair) => items.add(DropdownMenuItem<int>(
        value: sair.id,
        child: Text(sair.ad, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
      )),
    );

    return items;
  }
}