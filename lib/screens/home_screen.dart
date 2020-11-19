import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/BLoC/bloc_events_states.dart';
import 'package:weather_app/BLoC/bloc_main.dart';
import 'package:weather_app/localization/app_localizations.dart';
import 'package:weather_app/utils/constants.dart';
import 'package:weather_app/weatherData/weatherDataModel.dart';

// ignore: must_be_immutable
class HomeScreenPage extends StatefulWidget {
  WeatherDataModel currentWeather;
  ForecastDataModel forecastWeather;
  bool isAppFirstLaunched;
  bool getDataFromStorage;

  HomeScreenPage({
    this.currentWeather,
    this.forecastWeather,
    this.getDataFromStorage,
    this.isAppFirstLaunched,
  });

  @override
  _HomeScreenPageState createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage>
    with TickerProviderStateMixin {
  AnimationController _toastController;

  final _hourlyListController = ScrollController();
  final _dailyListController = ScrollController();
  TabController _tabController;

  double currentTemperature = 0.0;
  String currentCity = "";
  String currentConditions = "";
  List forecastHourlyList;
  List forecastDailyList;
  String lastTimeUpdatedText = "";

  GlobalKey<RefreshIndicatorState> refreshKey;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _toastController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    if (widget.isAppFirstLaunched == false) {
      storeAppFirstLaunchedVariable();
    }
    if (widget.getDataFromStorage == true) {
      getDataFromLocalStorage();
    } else {
      setDataFromNetwork();
    }
    _toastController.addListener(() {
      setState(() {});
    });
    if (widget.getDataFromStorage) _hideToastAnimationBegin();
  }

  @override
  void dispose() {
    super.dispose();
    _toastController.dispose();
  }

  void storeAppFirstLaunchedVariable() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool('firstLaunch', true);
  }

  void setDataFromNetwork() {
    currentTemperature = widget.currentWeather.getTemperature;
    currentCity = widget.currentWeather.currentLocationName;
    currentConditions = widget.currentWeather.currentConditions;
    forecastHourlyList = widget.forecastWeather.forecastHourlyList;
    forecastDailyList = widget.forecastWeather.forecastDailyList;
  }

  Future<void> getDataFromLocalStorage() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    lastTimeUpdatedText = preferences.getString("lastTimeUpdated");
    currentTemperature = preferences.getDouble("currentTemperature");
    currentCity = preferences.getString("currentCity");
    currentConditions = preferences.getString("currentConditions");
    Map forecastMap = jsonDecode(preferences.getString("forecastData"));
    forecastHourlyList = forecastMap["hourly"];
    forecastDailyList = forecastMap["daily"];
    setState(() {});
  }

  _hideToastAnimationBegin() async {
    return Timer(Duration(milliseconds: 2500), () {
      _toastController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _homeScreenBackground,
          _homeScreenAppBar,
          _currentConditionsBlock,
          _weatherBlock,
          widget.getDataFromStorage == true
              ? _lastTimeUpdatedToast
              : Container(),
        ],
      ),
    );
  }

  Positioned get _homeScreenAppBar => Positioned(
    left: 0.0,
    right: 0.0,
    top: 25.0,
    child: Container(
      width: MediaQuery.of(context).size.width,
      height: 50.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(currentCity, style: Theme.of(context).textTheme.headline2),
        ],
      ),
    ),
  );


  Positioned get _lastTimeUpdatedToast => Positioned(
        left: 0.0,
        right: 0.0,
        bottom: 0.0 + -_toastController.value * 55.0,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 45.0,
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0.0, -2.0),
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              AppLocalizations.of(context).translate('last_updated_string') + ": " + lastTimeUpdatedText,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
      );

  Container get _homeScreenBackground => Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff2B4780).withOpacity(0.95),
              Color(0xff386992).withOpacity(0.94),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      );

  Positioned get _currentConditionsBlock => Positioned(
        left: 0.0,
        right: 0.0,
        top: 80.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 30.0),
              alignment: Alignment.center,
              height: 125.0,
              child: Text(currentTemperature.round().toString() + "°",
                  style: Theme.of(context).textTheme.headline1),
            ),
            verticalSpace(10.0),
            Text(currentConditions,
                style: Theme.of(context).textTheme.headline2),
          ],
        ),
      );

  Positioned get _weatherBlock => Positioned(
        left: 0.0,
        right: 0.0,
        top: 290.0,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 280.0,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(38.0),
              topLeft: Radius.circular(38.0),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 68.0,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white.withOpacity(0.25),
                  indicatorSize: TabBarIndicatorSize.tab,
                  unselectedLabelColor: Colors.grey[500].withOpacity(0.2),
                  labelPadding: EdgeInsets.all(22.0),
                  indicatorWeight: 1.8,
                  tabs: [
                    Text(
                      AppLocalizations.of(context).translate('hourly_string'),
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    Text(
                      AppLocalizations.of(context).translate('daily_string'),
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _hourlyListOfWeather,
                    _dailyListOfWeather,
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Container get _hourlyListOfWeather => Container(
        child: RefreshIndicator(
          onRefresh: refreshWeather,
          key: refreshKey,
          backgroundColor: Colors.black87,
          color: Colors.white,
          strokeWidth: 2.0,
          child: FadingEdgeScrollView.fromScrollView(
            gradientFractionOnEnd: 0.25,
            child: ListView.separated(
              controller: _hourlyListController,
              padding:
                  EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 8.0),
              itemCount:
                  forecastHourlyList == null ? 0 : forecastHourlyList.length,
              cacheExtent: 50.0,
              separatorBuilder: (context, index) =>
                  Divider(height: 0.8, color: Colors.white.withOpacity(0.1)),
              itemBuilder: (context, index) {
                return hourlyRowBlock(forecastHourlyList[index], index);
              },
            ),
          ),
        ),
      );

  Future<Null> refreshWeather() async {
    BlocProvider.of<UserBloc>(context).add(UserCurrentLocationLoadEvent());
    await Future.delayed(Duration(milliseconds: 800));
  }

  Widget hourlyRowBlock(data, index) {
    return ExpansionTileCard(
      baseColor: Colors.transparent,
      expandedColor: Colors.transparent,
      shadowColor: Colors.transparent,
      duration: Duration(milliseconds: 150),
      contentPadding: EdgeInsets.only(bottom: 0.0),
      borderRadius: BorderRadius.zero,
      initialPadding: EdgeInsets.zero,
      // finalPadding: EdgeInsets.zero,
      trailing: Padding(
        padding: const EdgeInsets.only(top: 14.0, right: 15.0),
        child: Icon(
          Icons.keyboard_arrow_down,
          size: 26.0,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
      // animateTrailing: true,
      children: [
        Divider(color: Colors.white.withOpacity(0.1), height: 0.8),
        hourlyDetailsBlock(data),
      ],
      title: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: 78.0,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.00),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 20.0,
              top: 0.0,
              bottom: 0.0,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  index == 0
                      ? "${DateFormat.Hm().format(DateTime.now())}"
                      : getHourlyTime(data),
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
            ),
            Positioned(
              right: 10.0,
              top: 0.0,
              bottom: 0.0,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  data["temp"].round().toString() + "°",
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
            ),
            Positioned(
              right: 54.0,
              top: 0.0,
              bottom: 0.0,
              child: CachedNetworkImage(
                width: 68.0,
                height: 68.0,
                imageUrl: ("http://openweathermap.org/img/wn/" +
                    data["weather"][0]["icon"] +
                    "@2x.png"),
                errorWidget: (context, url, error) => Icon(Icons.error,
                    size: 24.0, color: Colors.white.withOpacity(0.8)),
                fadeOutDuration: new Duration(milliseconds: 500),
                fadeInDuration: new Duration(milliseconds: 300),
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getHourlyTime(data) {
    DateTime now =
        DateTime.fromMillisecondsSinceEpoch(data["dt"] * 1000, isUtc: false);
    return DateFormat.Hm().format(now);
  }

  Widget hourlyDetailsBlock(data) => Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.cloud,
                      size: 14.0, color: Colors.white.withOpacity(0.6)),
                  horizontalSpace(12.0),
                  Text(
                    data["weather"][0]["description"],
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Icon(FontAwesomeIcons.temperatureLow,
                        size: 14.0, color: Colors.white.withOpacity(0.6)),
                  ),
                  horizontalSpace(12.0),
                  Text(
                    data["feels_like"].round().toString() + "°",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
              verticalSpace(4.0),
              Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 2.5, bottom: 2.0),
                      child: Icon(FontAwesomeIcons.cloudscale,
                          size: 14.0, color: Colors.white.withOpacity(0.6))),
                  horizontalSpace(12.0),
                  Text(
                    data["pressure"].toString() + " Pa",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Spacer(),
                  Padding(
                      padding: const EdgeInsets.only(left: 2.0, bottom: 2.0),
                      child: Icon(FontAwesomeIcons.tint,
                          size: 14.0, color: Colors.white.withOpacity(0.6))),
                  horizontalSpace(12.0),
                  Text(
                    data["humidity"].toString() + "%",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
              verticalSpace(4.0),
              Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 2.5, bottom: 2.0),
                      child: Icon(FontAwesomeIcons.wind,
                          size: 14.0, color: Colors.white.withOpacity(0.6))),
                  horizontalSpace(12.0),
                  Text(
                    data["wind_speed"].toString() + " m/s",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Spacer(),
                  Padding(
                      padding: const EdgeInsets.only(left: 2.0, bottom: 2.0),
                      child: Icon(FontAwesomeIcons.locationArrow,
                          size: 11.0, color: Colors.white.withOpacity(0.6))),
                  horizontalSpace(12.0),
                  Text(
                    data["wind_deg"].toString(),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Container get _dailyListOfWeather => Container(
        child: RefreshIndicator(
          onRefresh: refreshWeather,
          key: refreshKey,
          backgroundColor: Colors.black87,
          color: Colors.white,
          strokeWidth: 2.0,
          child: FadingEdgeScrollView.fromScrollView(
            child: ListView.separated(
              controller: _dailyListController,
              padding:
                  EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 8.0),
              itemCount:
                  forecastDailyList == null ? 0 : forecastDailyList.length,
              cacheExtent: 7,
              separatorBuilder: (context, index) =>
                  Divider(height: 0.8, color: Colors.white.withOpacity(0.1)),
              itemBuilder: (context, index) {
                return dailyRowBlock(forecastDailyList[index]);
              },
            ),
          ),
        ),
      );

  Widget dailyRowBlock(data) {
    return ExpansionTileCard(
      baseColor: Colors.transparent,
      expandedColor: Colors.transparent,
      shadowColor: Colors.transparent,
      duration: Duration(milliseconds: 150),
      contentPadding: EdgeInsets.only(bottom: 0.0),
      borderRadius: BorderRadius.zero,
      initialPadding: EdgeInsets.zero,
      // finalPadding: EdgeInsets.zero,
      trailing: Padding(
        padding: const EdgeInsets.only(top: 14.0, right: 15.0),
        child: Icon(
          Icons.keyboard_arrow_down,
          size: 26.0,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
      // animateTrailing: true,
      children: [
        Divider(color: Colors.white.withOpacity(0.1), height: 0.8),
        dailyDetailsBlock(data),
      ],
      title: Container(
        width: MediaQuery.of(context).size.width,
        height: 78.0,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.00),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 10.0,
              top: 0.0,
              bottom: 0.0,
              child: Container(
                child: CachedNetworkImage(
                  width: 68.0,
                  height: 68.0,
                  imageUrl: "http://openweathermap.org/img/wn/" +
                      data["weather"][0]["icon"] +
                      "@2x.png",
                  errorWidget: (context, url, error) => Icon(Icons.error,
                      size: 24.0, color: Colors.white.withOpacity(0.8)),
                  fadeOutDuration: new Duration(milliseconds: 500),
                  fadeInDuration: new Duration(milliseconds: 300),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left: 85.0,
              top: 0.0,
              bottom: 0.0,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  data["temp"]["min"].round().toString() +
                      "°" +
                      "/" +
                      data["temp"]["max"].round().toString() +
                      "°",
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
            ),
            Positioned(
              right: 30.0,
              top: 0.0,
              bottom: 0.0,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "${getDailyTime(data).day}.${getDailyTime(data).month}",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime getDailyTime(data) {
    return DateTime.fromMillisecondsSinceEpoch(data["dt"] * 1000, isUtc: false);
  }

  Widget dailyDetailsBlock(data) => Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.cloud,
                      size: 14.0, color: Colors.white.withOpacity(0.6)),
                  horizontalSpace(12.0),
                  Text(
                    data["weather"][0]["description"],
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Icon(FontAwesomeIcons.temperatureLow,
                        size: 14.0, color: Colors.white.withOpacity(0.6)),
                  ),
                  horizontalSpace(12.0),
                  Text(
                    data["feels_like"]["day"].round().toString() + "°",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
              verticalSpace(4.0),
              Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 2.5, bottom: 2.0),
                      child: Icon(FontAwesomeIcons.cloudscale,
                          size: 14.0, color: Colors.white.withOpacity(0.6))),
                  horizontalSpace(12.0),
                  Text(
                    data["pressure"].toString() + " Pa",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Spacer(),
                  Padding(
                      padding: const EdgeInsets.only(left: 2.0, bottom: 2.0),
                      child: Icon(FontAwesomeIcons.tint,
                          size: 14.0, color: Colors.white.withOpacity(0.6))),
                  horizontalSpace(12.0),
                  Text(
                    data["humidity"].toString() + "%",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
              verticalSpace(4.0),
              Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 2.5, bottom: 2.0),
                      child: Icon(FontAwesomeIcons.wind,
                          size: 14.0, color: Colors.white.withOpacity(0.6))),
                  horizontalSpace(12.0),
                  Text(
                    data["wind_speed"].toString() + " m/s",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Spacer(),
                  Padding(
                      padding: const EdgeInsets.only(left: 2.0, bottom: 2.0),
                      child: Icon(FontAwesomeIcons.locationArrow,
                          size: 11.0, color: Colors.white.withOpacity(0.6))),
                  horizontalSpace(12.0),
                  Text(
                    data["wind_deg"].toString(),
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
