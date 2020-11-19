import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/BLoC/bloc_events_states.dart';
import 'package:weather_app/weatherData/weatherDataModel.dart';
import 'package:weather_app/weatherData/weatherDataRepository.dart';

class UserBloc extends Bloc<UserEvents, UserStates> {
  WeatherDataRepository weatherDataRepository;
  UserBloc({this.weatherDataRepository});

  @override
  UserStates get initialState => UserWeatherDataEmpty();

  double latitude;
  double longitude;

  @override
  Stream<UserStates> mapEventToState(UserEvents event) async* {
    if (event is UserCurrentLocationLoadEvent) {
      yield UserLocationDataIsLoading();
      print("Location loading");
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium);
        latitude = position.latitude;
        longitude = position.longitude;
        yield UserLocationDataIsLoaded();
        print("Location loaded");
        print(latitude);
        print(longitude);
      } catch (_) {
        // throw Exception();
        print("Location error");
      }
      yield UserWeatherDataIsLoading();
      print("Weather loading");
      try {
        WeatherDataModel currentWeatherData =
            await weatherDataRepository.getCurrentWeather(latitude, longitude);
        print("current got");
        ForecastDataModel forecastWeatherData =
            await weatherDataRepository.getForecastWeather(latitude, longitude);
        print("forecast got");
        yield UserWeatherDataIsLoaded(currentWeatherData, forecastWeatherData);
        print("Weather loaded");
      } catch (_) {
        yield UserWeatherDataIsntLoaded();
      }
    }

    // if (event is UserCurrentLocationLoadEvent) {
    //   yield UserLocationDataIsLoading();
    //   try {

    //     yield UserLocationDataIsLoaded();
    //     yield UserWeatherDataIsLoading();
    //     try {
    //       WeatherDataModel weatherData =
    //           await weatherDataRepository.getWeather(_latitude, _longitude);
    //       yield UserWeatherDataIsLoaded(weatherData);
    //     } catch (_) {
    //       yield UserWeatherDataIsntLoaded();
    //     }
    //   } catch (_) {
    //     yield throw Exception("Error location fetching");
    //   }
    // }
  }
}
