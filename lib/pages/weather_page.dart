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
      WeatherServices("d77fee68dbb4398aa73e433219b3ef60");

  Weather? _weather;
  String _city = "", _zip = "", _lat = "", _lon = "";
  String _selectedUnit = "metric";
  String _selectedCountry = "Thailand";
  bool _isLoading = false;

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


  Future<void> _fetchWeather(Future<Weather> Function() fetchFn) async {
    setState(() => _isLoading = true);
    try {
      final weather = await fetchFn();
      setState(() => _weather = weather);
    } catch (e) {
      _showError("ไม่สามารถดึงข้อมูลได้: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchByCity() async {
    if (_city.isEmpty) return;
    await _fetchWeather(() =>
        _weatherService.getWeatherByCity(_city, _selectedCountry, _selectedUnit));
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
      _showError("กรุณากรอกพิกัดให้ถูกต้อง");
      return;
    }
    await _fetchWeather(
        () => _weatherService.getWeatherByLatLon(lat, lon, _selectedUnit));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }

  String _getWeatherAnimation(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains("cloud")) return "assets/lottie/clouds.json";
    if (condition.contains("rain")) return "assets/lottie/rain.json";
    if (condition.contains("clear")) return "assets/lottie/clear-day.json";
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
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        elevation: 6,
        backgroundColor: const Color(0xFF1A1A1A),
        shadowColor: Colors.pinkAccent.withOpacity(0.3),
        centerTitle: true,
        title: const Text(
          "Weather Finder",
          style: TextStyle(
            color: Colors.pinkAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildSearchCard(),
              const SizedBox(height: 25),
              if (_isLoading)
                const CircularProgressIndicator(color: Colors.pinkAccent),
              if (_weather != null && !_isLoading) _buildWeatherCard(),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildSearchCard() {
    return Card(
      color: const Color(0xFF1C1C1C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 10,
      shadowColor: Colors.pinkAccent.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "🔎 ค้นหาสภาพอากาศ",
              style: TextStyle(
                color: Colors.pinkAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            
            TextField(
              onChanged: (v) => _city = v,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("City Name"),
            ),
            const SizedBox(height: 12),

            
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Country"),
              items: _countries
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _selectedCountry = v ?? "Thailand"),
            ),
            const SizedBox(height: 12),

            
            DropdownButtonFormField<String>(
              value: _selectedUnit,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Temperature Unit"),
              items: _units
                  .map((u) =>
                      DropdownMenuItem(value: u["value"], child: Text(u["label"]!)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _selectedUnit = v ?? "metric"),
            ),
            const SizedBox(height: 20),

            
            _searchButton("Search by City", _searchByCity),
            _divider(),

            TextField(
              onChanged: (v) => _zip = v,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("ZIP Code"),
            ),
            const SizedBox(height: 12),
            _searchButton("Search by ZIP", _searchByZip),
            _divider(),

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
                const SizedBox(width: 10),
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
            const SizedBox(height: 12),
            _searchButton("Search by Lat/Lon", _searchByLatLon),
          ],
        ),
      ),
    );
  }


  Widget _buildWeatherCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: Card(
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadowColor: Colors.pinkAccent.withOpacity(0.4),
        elevation: 12,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(_getWeatherAnimation(_weather!.condition),
                  width: 180, height: 180, repeat: true),
              const SizedBox(height: 12),
              Text(
                _weather!.cityName,
                style: const TextStyle(
                  color: Colors.pinkAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${_weather!.temperature.round()}°",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _weather!.condition,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 18, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _searchButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.black,
        shadowColor: Colors.pinkAccent.withOpacity(0.4),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: _isLoading ? null : onPressed,
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: 16),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.pinkAccent),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.pinkAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.pinkAccent, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Divider(color: Colors.grey, height: 20, thickness: 0.6),
      );
}
