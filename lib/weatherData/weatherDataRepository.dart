import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/utils/constants.dart';
import 'package:weather_app/utils/global_variables.dart';
import 'package:weather_app/weatherData/weatherDataModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherDataRepository {
  // ignore: missing_return
  Future<WeatherDataModel> getCurrentWeather(latitude, longitude) async {
    var currentWeatherResponse = await http.Client().get(
        "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&lang=" + currentWeatherLanguageResponse + "&appid=" +
            OPENWEATHERKEY);

    if (currentWeatherResponse.statusCode == 200) {
      print("parsing current weather");
      return parseCurrentWeatherJson(currentWeatherResponse.body);
    }
  }

  // ignore: missing_return
  Future<ForecastDataModel> getForecastWeather(latitude, longitude) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var forecastWeatherResponse = await http.Client().get(
        "https://api.openweathermap.org/data/2.5/onecall?lat=$latitude&lon=$longitude&units=metric&exclude=minutely,alerts&lang=" + currentWeatherLanguageResponse + "&appid=" +
            OPENWEATHERKEY);

    if (forecastWeatherResponse.statusCode == 200) {
      print("parsing forecast weather");
      Map decodeData = json.decode(forecastWeatherResponse.body);
      if (decodeData != null) {
        String forecastData = jsonEncode(ForecastDataModel.fromJson(decodeData));
        preferences.setString("forecastData", forecastData);
        return ForecastDataModel.fromJson(decodeData);
      }
    }
  }

  WeatherDataModel parseCurrentWeatherJson(final response) {
    Map jsonDecode = json.decode(response);
    return WeatherDataModel.fromJson(jsonDecode);
  }
}
