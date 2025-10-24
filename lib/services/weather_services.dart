import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherServices {
  final String apiKey;

  WeatherServices(this.apiKey);

  // ✅ ดึงอากาศจากชื่อเมือง + ประเทศ
  Future<Weather> getWeatherByCity(
      String city, String countryCode, String unit) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=$city,$countryCode&appid=$apiKey&units=$unit";
    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      return Weather.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("Failed to fetch weather by city");
    }
  }

  // ✅ ดึงอากาศจากรหัสไปรษณีย์ + ประเทศ
  Future<Weather> getWeatherByZip(
      String zip, String countryCode, String unit) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?zip=$zip,$countryCode&appid=$apiKey&units=$unit";
    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      return Weather.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("Failed to fetch weather by zip");
    }
  }

  // ✅ ดึงอากาศจาก Latitude / Longitude
  Future<Weather> getWeatherByLatLon(
      double lat, double lon, String unit) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=$unit";
    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      return Weather.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("Failed to fetch weather by coordinates");
    }
  }
}
