import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherServices {
  final String apiKey;

  WeatherServices(this.apiKey);

  // ✅ ค้นหาด้วยชื่อเมือง
  Future<Weather> getWeatherByCity(
      String city, String countryCode, String unit) async {
    final code = _normalizeCountryCode(countryCode);
    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=$city,$code&appid=$apiKey&units=$unit";
    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      return Weather.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("❌ City not found ($city, $countryCode)");
    }
  }

  // ✅ ค้นหาด้วย ZIP (อ่าน lat/lon จาก API)
  Future<Weather> getWeatherByZip(
      String zip, String countryCode, String unit) async {
    final code = _normalizeCountryCode(countryCode);

    // ล้างรูปแบบ zip สำหรับบางประเทศ
    if (code == "JP") zip = zip.replaceAll("-", "");
    if (code == "CA") zip = zip.replaceAll(" ", "");

    // 1️⃣ ใช้ Geocoding API หา lat/lon จาก ZIP
    final geoUrl =
        "https://api.openweathermap.org/geo/1.0/zip?zip=$zip,$code&appid=$apiKey";
    final geoRes = await http.get(Uri.parse(geoUrl));

    if (geoRes.statusCode != 200) {
      throw Exception("❌ ZIP not found or unsupported in $countryCode");
    }

    final geoData = jsonDecode(geoRes.body);
    if (geoData["lat"] == null || geoData["lon"] == null) {
      throw Exception("❌ Invalid geocoding result for ZIP $zip");
    }

    final lat = geoData["lat"];
    final lon = geoData["lon"];

    // 2️⃣ ดึงข้อมูลสภาพอากาศจากพิกัดที่ได้
    return await getWeatherByLatLon(lat, lon, unit);
  }

  // ✅ ค้นหาด้วยพิกัด
  Future<Weather> getWeatherByLatLon(
      double lat, double lon, String unit) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=$unit";
    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      return Weather.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("❌ Failed to fetch weather by coordinates");
    }
  }

  // ✅ Helper แปลงชื่อประเทศเป็นรหัส 2 ตัว
  String _normalizeCountryCode(String country) {
    switch (country.toLowerCase()) {
      case "th":
      case "thailand":
        return "TH";
      case "jp":
      case "japan":
        return "JP";
      case "us":
      case "usa":
      case "united states":
        return "US";
      case "fr":
      case "france":
        return "FR";
      case "ca":
      case "canada":
        return "CA";
      case "gb":
      case "uk":
      case "united kingdom":
        return "GB";
      default:
        return country.toUpperCase();
    }
  }
}
