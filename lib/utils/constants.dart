import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

const String OPENWEATHERKEY = "4b38274e06a2532786df608c4a0a4322";

const TextTheme TEXT_THEME_SMALL = TextTheme(        // for small device screen
  headline1: TextStyle(
    color: Colors.white, fontSize: 86.5, fontWeight: FontWeight.w400, letterSpacing: 1.0, fontFamily: 'HindSiliguri',
  ),
  headline2: TextStyle(
    color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w600, letterSpacing: 0.7, fontFamily: 'Raleway',
  ),
  headline3: TextStyle(
    color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600, letterSpacing: 0.8, fontFamily: 'Raleway',
  ),
  headline4: TextStyle(
    color: Colors.white, fontSize: 19.5, fontWeight: FontWeight.w600, letterSpacing: 0.8, fontFamily: 'HindSiliguri',
  ),
  headline5: TextStyle(
    color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w600, letterSpacing: 0.6, fontFamily: 'HindSiliguri',
  ),
  headline6: TextStyle(
    color: Colors.white54, fontSize: 14.0, fontWeight: FontWeight.w600, letterSpacing: 0.9, fontFamily: 'HindSiliguri',
  ),
);

const TextTheme TEXT_THEME_BIG = TextTheme(          // for big device screen
  headline1: TextStyle(
    color: Colors.white, fontSize: 110.5, fontWeight: FontWeight.w400, letterSpacing: 1.2, fontFamily: 'HindSiliguri',
  ),
  headline2: TextStyle(
    color: Colors.white70, fontSize: 20.5, fontWeight: FontWeight.w600, letterSpacing: 0.7, fontFamily: 'Raleway',
  ),
  headline3: TextStyle(
    color: Colors.white54, fontSize: 16.0, fontWeight: FontWeight.w600, letterSpacing: 0.9, fontFamily: 'Raleway',
  ),
  headline4: TextStyle(
    color: Colors.white, fontSize: 22.5, fontWeight: FontWeight.w600, letterSpacing: 1.0, fontFamily: 'HindSiliguri',
  ),
  headline5: TextStyle(
    color: Colors.white70, fontSize: 19.5, fontWeight: FontWeight.w600, letterSpacing: 0.7, fontFamily: 'HindSiliguri',
  ),
  headline6: TextStyle(
    color: Colors.white54, fontSize: 17.0, fontWeight: FontWeight.w600, letterSpacing: 0.9, fontFamily: 'HindSiliguri',
  ),
);

Widget verticalSpace(double height) {
  return SizedBox(height: height);
}

Widget horizontalSpace(double width) {
  return SizedBox(width: width);
}