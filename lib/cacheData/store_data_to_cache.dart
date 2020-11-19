import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void storeDataToLocalStorage(currentWeather) async {
  final preferences = await SharedPreferences.getInstance();
  await preferences.setDouble("currentTemperature", currentWeather.getTemperature);
  await preferences.setString("currentCity", currentWeather.currentLocationName);
  await preferences.setString("currentConditions", currentWeather.currentConditions);

  String lastTimeUpdatedString = "";

  lastTimeUpdatedString = DateTime.now().day.toString() + "." + DateTime.now().month.toString() + "-" + formatCurrentTime();
  await preferences.setString("lastTimeUpdated", lastTimeUpdatedString);
}

String formatCurrentTime() {
  return DateFormat.Hm().format(DateTime.now());
}