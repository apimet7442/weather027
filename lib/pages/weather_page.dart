import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/weather_services.dart';
import '../models/weather_model.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherServices _weatherService =
      WeatherServices("d77fee68dbb4398aa73e433219b3ef60"); // 🔑 ใส่ API key ของคุณ

  Weather? _weather;
  String _city = "";
  String _zip = "";
  String _lat = "";
  String _lon = "";
  String _selectedUnit = "metric";
  String _selectedCountry = "Thailand";

  final List<String> _countries = [
    "Thailand",
    "Japan",
    "USA",
    "France",
    "Canada"
  ];

  final List<Map<String, String>> _units = [
    {"label": "Celsius (°C)", "value": "metric"},
    {"label": "Fahrenheit (°F)", "value": "imperial"},
    {"label": "Kelvin (K)", "value": "standard"},
  ];

  bool _isLoading = false;

  Future<void> _searchByCity() async {
    if (_city.isEmpty) return;
    await _fetchWeather(() => _weatherService.getWeatherByCity(
        _city, _selectedCountry, _selectedUnit));
  }

  Future<void> _searchByZip() async {
    if (_zip.isEmpty) return;
    await _fetchWeather(() =>
        _weatherService.getWeatherByZip(_zip, _selectedCountry, _selectedUnit));
  }

  Future<void> _searchByLatLon() async {
    if (_lat.isEmpty || _lon.isEmpty) return;
    final lat = double.tryParse(_lat);
    final lon = double.tryParse(_lon);
    if (lat == null || lon == null) {
      _showError("Invalid latitude or longitude");
      return;
    }
    await _fetchWeather(
        () => _weatherService.getWeatherByLatLon(lat, lon, _selectedUnit));
  }

  Future<void> _fetchWeather(Future<Weather> Function() fetchFn) async {
    setState(() => _isLoading = true);
    try {
      final weather = await fetchFn();
      setState(() => _weather = weather);
    } catch (e) {
      _showError("❌ ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getWeatherAnimation(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains("cloud")) return "assets/lottie/clouds.json";
    if (condition.contains("rain")) return "assets/lottie/rain.json";
    if (condition.contains("clear")) return "assets/lottie/clearday.json";
    if (condition.contains("mist") ||
        condition.contains("fog") ||
        condition.contains("haze")) {
      return "assets/lottie/mist.json";
    }
    return "assets/lottie/weather-partly-cloudy.json";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Weather Finder",
          style: TextStyle(
              color: Colors.lightBlueAccent,
              fontWeight: FontWeight.bold,
              fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildInputFields(),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator(color: Colors.lightBlueAccent),
            if (_weather != null && !_isLoading) _buildWeatherCard(),
          ],
        ),
      ),
    );
  }

  // --------------------------- Input Form --------------------------
  Widget _buildInputFields() {
    return Column(
      children: [
        TextField(
          onChanged: (v) => _city = v,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration("City Name"),
        ),
        const SizedBox(height: 10),

        DropdownButtonFormField<String>(
          value: _selectedCountry,
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration("Country"),
          items: _countries
              .map((country) =>
                  DropdownMenuItem(value: country, child: Text(country)))
              .toList(),
          onChanged: (value) =>
              setState(() => _selectedCountry = value ?? "Thailand"),
        ),
        const SizedBox(height: 10),

        DropdownButtonFormField<String>(
          value: _selectedUnit,
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration("Temperature Unit"),
          items: _units
              .map((u) =>
                  DropdownMenuItem(value: u["value"], child: Text(u["label"]!)))
              .toList(),
          onChanged: (value) =>
              setState(() => _selectedUnit = value ?? "metric"),
        ),
        const SizedBox(height: 12),

        _searchButton("Search by City", _searchByCity),
        const Divider(color: Colors.blueGrey),

        // ZIP Search
        TextField(
          onChanged: (v) => _zip = v,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration("ZIP Code"),
        ),
        const SizedBox(height: 10),
        _searchButton("Search by ZIP", _searchByZip),
        const Divider(color: Colors.blueGrey),

        // Lat/Lon
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (v) => _lat = v,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Latitude"),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: (v) => _lon = v,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Longitude"),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _searchButton("Search by Lat/Lon", _searchByLatLon),
      ],
    );
  }

  // --------------------------- Weather Card --------------------------
  Widget _buildWeatherCard() {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Lottie.asset(_getWeatherAnimation(_weather!.condition),
                width: 160, height: 160, repeat: true),
            const SizedBox(height: 10),
            Text(
              _weather!.cityName,
              style: const TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "${_weather!.temperature.round()}°",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              _weather!.condition,
              style: const TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------- Common Widgets --------------------------
  Widget _searchButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      onPressed: _isLoading ? null : onPressed,
      child: Text(text),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.blueAccent),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.lightBlueAccent, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
