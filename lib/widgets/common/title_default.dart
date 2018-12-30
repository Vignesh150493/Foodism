import 'package:flutter/material.dart';

class TitleDefault extends StatelessWidget {
  final String _title;

  TitleDefault(this._title);

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Text(
      _title,
      softWrap: true,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: deviceWidth > 700 ? 26.0 : 15.0,
          fontWeight: FontWeight.bold),
    );
  }
}
