import 'dart:async';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/BLoC/bloc_events_states.dart';
import 'package:weather_app/BLoC/bloc_main.dart';
import 'package:weather_app/cacheData/store_data_to_cache.dart';
import 'package:weather_app/localization/app_localizations.dart';
import 'package:weather_app/routes/fade_route.dart';
import 'package:weather_app/screens/home_screen.dart';
import 'package:weather_app/utils/constants.dart';
import 'package:weather_app/utils/global_variables.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isFirstTimeAppLaunched = false;

  @override
  void initState() {
    super.initState();
    _isFirstAppLaunch();
    _getLocationPermissionAndService();
  }

  Future<void> _isFirstAppLaunch() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool isStartUp = preferences.getBool('firstLaunch');
    if (isStartUp == null)
      _isFirstTimeAppLaunched = false;
    else
      _isFirstTimeAppLaunched = true;
  }

  _getLocationPermissionAndService() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      if (await Geolocator.isLocationServiceEnabled() == true) {
        BlocProvider.of<UserBloc>(context).add(UserCurrentLocationLoadEvent());
      } else {
        await Geolocator.openLocationSettings();
        BlocProvider.of<UserBloc>(context).add(UserCurrentLocationLoadEvent());
      }
    }
  }

  _loadPageSwitchWithNetwork(currentWeather, forecastWeather) async {
    return Timer(Duration(milliseconds: 50), () {
      Navigator.push(
          context,
          CustomPageRouteFade(HomeScreenPage(
            currentWeather: currentWeather,
            getDataFromStorage: false,
            forecastWeather: forecastWeather,
            isAppFirstLaunched: _isFirstTimeAppLaunched,
          )));
    });
  }

  _loadPageSwitchWithoutNetwork() async {
    return Timer(Duration(milliseconds: 50), () {
      Navigator.push(context,
          CustomPageRouteFade(HomeScreenPage(getDataFromStorage: true)));
    });
  }

  @override
  Widget build(BuildContext context) {
    currentWeatherLanguageResponse = AppLocalizations.of(context).translate('weather_lang_type_string');
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _splashScreenBackground,
          _logoAnimationBlock,
          BlocBuilder<UserBloc, UserStates>(
            builder: (context, state) {
              if (state is UserLocationDataIsLoading) {
                return _circularProgressIndicator();
              } else if (state is UserWeatherDataIsLoading) {
                return _circularProgressIndicator();
              } else if (state is UserWeatherDataIsLoaded) {
                storeDataToLocalStorage(state.getCurrentWeather);
                _loadPageSwitchWithNetwork(
                    state.getCurrentWeather, state.getForecastWeather);
              } else if (state is UserWeatherDataIsntLoaded) {
                if (_isFirstTimeAppLaunched) {
                  _loadPageSwitchWithoutNetwork();
                } else {
                  return _noInternetConnectivityWidgetBlock();
                }
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }

  Widget _noInternetConnectivityWidgetBlock() {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 45.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).translate('no_internet_line_first_string'),
            style: Theme.of(context).textTheme.headline3,
          ),
          verticalSpace(10.0),
          Text(
            AppLocalizations.of(context).translate('no_internet_line_second_string'),
            style: Theme.of(context).textTheme.headline3,
          ),
          verticalSpace(20.0),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                BlocProvider.of<UserBloc>(context)
                    .add(UserCurrentLocationLoadEvent());
              },
              borderRadius: BorderRadius.circular(35.0),
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.05),
              child: Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(color: Colors.white38, width: 0.8),
                ),
                child: Center(
                  child: Icon(Icons.refresh, size: 26.0, color: Colors.white54),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circularProgressIndicator() {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 55.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30.0,
            height: 30.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white38),
            ),
          ),
        ],
      ),
    );
  }

  Positioned get _logoAnimationBlock => Positioned(
        left: 15.0,
        right: 0.0,
        bottom: MediaQuery.of(context).size.height / 2 - 100.0,
        child: Container(
          alignment: Alignment.center,
          width: 260.0,
          height: 260.0,
          child: FlareActor(
            "assets/logo_animation.flr",
            fit: BoxFit.contain,
            animation: "sunAnimationProgress",
          ),
        ),
      );

  Container get _splashScreenBackground => Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff3B4886),
              Colors.indigo.withOpacity(0.8),
              Color(0xff2B4889),
            ],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
      );
}
