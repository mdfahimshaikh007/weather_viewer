import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> setTempStatus(bool status) async {
  final preference = await SharedPreferences.getInstance();
  return preference.setBool('status', status);
}

Future<bool> getTempStatus() async {
  final preference = await SharedPreferences.getInstance();
  return preference.getBool('status') ?? false;
}

String getFormattedDate(num dt, String format) {
  return DateFormat(format).format(DateTime.fromMillisecondsSinceEpoch(dt.toInt() * 1000));
}

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {

    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition();
}