import 'package:equatable/equatable.dart';
import 'package:weather_app/weatherData/weatherDataModel.dart';

class UserEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class UserFetchWeatherDataEvent extends UserEvents {}

class UserCurrentLocationLoadEvent extends UserEvents {

  @override
  List<Object> get props => [];
}

class UserStates extends Equatable {
  @override
  List<Object> get props => [];
}

class UserLocationDataIsLoading extends UserStates {}

class UserLocationDataIsLoaded extends UserStates {}

class UserWeatherDataEmpty extends UserStates {}

class UserWeatherDataIsLoading extends UserStates {}

class UserWeatherDataIsLoaded extends UserStates {
  final currentWeather;
  final forecastWeather;
  UserWeatherDataIsLoaded(this.currentWeather, this.forecastWeather);
  WeatherDataModel get getCurrentWeather => currentWeather;
  ForecastDataModel get getForecastWeather => forecastWeather;

  @override
  List<Object> get props => [currentWeather, forecastWeather];
}

class UserWeatherDataIsntLoaded extends UserStates {}
