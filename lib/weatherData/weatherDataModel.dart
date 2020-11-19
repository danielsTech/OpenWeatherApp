class WeatherDataModel {
  final temperature;
  final currentLocationName;
  final currentConditions;

  double get getTemperature => temperature;

  WeatherDataModel({
    this.temperature,
    this.currentLocationName,
    this.currentConditions,
  });

  factory WeatherDataModel.fromJson(Map<String, dynamic> json) {
    return WeatherDataModel(
      temperature: json["main"]["temp"],
      currentLocationName: json["name"],
      currentConditions: json["weather"][0]["description"],
    );
  }
}

class ForecastDataModel {
  final List forecastHourlyList;
  final List forecastDailyList;

  ForecastDataModel({this.forecastHourlyList, this.forecastDailyList});

  factory ForecastDataModel.fromJson(Map<String, dynamic> json) {
    return ForecastDataModel(
      forecastHourlyList: json["hourly"],
      forecastDailyList: json["daily"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "hourly": this.forecastHourlyList,
      "daily": this.forecastDailyList,
    };
  }

}
