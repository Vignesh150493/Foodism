import 'package:flutter/material.dart';

final ThemeData _androidTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.deepOrange,
    accentColor: Colors.deepPurple,
    buttonColor: Colors.deepPurple,
    fontFamily: 'Google');

final ThemeData _iOSTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.grey,
    accentColor: Colors.blue,
    buttonColor: Colors.blue,
    fontFamily: 'Google');

ThemeData getAdaptiveThemeData(BuildContext context) {
  return Theme.of(context).platform == TargetPlatform.android
      ? _androidTheme
      : _iOSTheme;
}
