import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:weather_app/BLoC/bloc_main.dart';
import 'package:weather_app/localization/app_localizations.dart';
import 'package:weather_app/screens/splash_screen.dart';
import 'package:weather_app/systemChrome/chrome_config.dart';
import 'package:weather_app/utils/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/utils/global_variables.dart';
import 'package:weather_app/weatherData/weatherDataRepository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MaterialAppClass());
  systemChromeConfigSet();
}

class MaterialAppClass extends StatelessWidget {

  WeatherDataRepository weatherDataRepository = WeatherDataRepository();

  @override
  Widget build(BuildContext context) {
    double physicalScreenWidth = window.physicalSize.width;
    return BlocProvider(
      create: (context) => UserBloc(weatherDataRepository: weatherDataRepository),
      child: MaterialApp(
        title: 'OpenWeather',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: physicalScreenWidth >= 1080.0 ? TEXT_THEME_BIG : TEXT_THEME_SMALL,
        ),
        themeMode: ThemeMode.light,

        supportedLocales: [
          Locale('en', 'US'),
          Locale('ru', "RU"),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for(var supportedLocale in supportedLocales) {
            if(supportedLocale.languageCode == locale.languageCode && supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },

        home: SplashScreen(),
      ),
    );
  }
}
