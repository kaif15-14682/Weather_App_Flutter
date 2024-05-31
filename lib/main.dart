import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:weather/weather.dart';
import 'package:weatherapp/consts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  Weather? _weather;
  List<Weather> _forecast = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchWeather("Dhaka");
    _fetchWeatherForecast("Dhaka");
  }

  void _fetchWeather(String location) {
    _wf.currentWeatherByCityName(location).then((w) {
      setState(() {
        _weather = w;
      });
    });
  }

  void _fetchWeatherForecast(String location) {
    _wf.fiveDayForecastByCityName(location).then((forecast) {
      setState(() {
        _forecast = forecast;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Weather App",
          style: TextStyle(
            color: Colors.white, // Set text color to white
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.blueGrey,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (_weather == null || _forecast.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _searchLocation(),
            const SizedBox(height: 20),
            _currentWeatherCard(),
            const SizedBox(height: 20),
            _extraInfoCard(),
            const SizedBox(height: 20),
            _weatherForecast(),
          ],
        ),
      ),
    );
  }

  Widget _searchLocation() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search location...',
              hintStyle: TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.teal,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.search, color: Colors.white),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () {
            String searchLocation = _searchController.text.trim();
            if (searchLocation.isNotEmpty) {
              _fetchWeather(searchLocation);
              _fetchWeatherForecast(searchLocation);
            }
          },
        ),
      ],
    );
  }

  Widget _currentWeatherCard() {
    return Card(
      color: Colors.teal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _weather?.areaName ?? "",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_city, color: Colors.white, size: 40),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat("h:mm a").format(_weather!.date!),
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    Text(
                      "${DateFormat("EEEE, d MMM y").format(_weather!.date!)}",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      "${_weather?.temperature?.celsius?.toStringAsFixed(1)}° C",
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text(
                      _weather?.weatherDescription ?? "",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          "http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _extraInfoCard() {
    return Card(
      color: Colors.tealAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _extraInfoColumn("Max Temp",
                    "${_weather?.tempMax?.celsius?.toStringAsFixed(1)}° C"),
                _extraInfoColumn("Min Temp",
                    "${_weather?.tempMin?.celsius?.toStringAsFixed(1)}° C"),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _extraInfoColumn(
                    "Wind", "${_weather?.windSpeed?.toStringAsFixed(1)} m/s"),
                _extraInfoColumn(
                    "Humidity", "${_weather?.humidity?.toStringAsFixed(1)}%"),
              ],
            ),
            const SizedBox(height: 10),
            IconButton(
              icon: Icon(FontAwesomeIcons.share,
                  color: const Color.fromARGB(255, 255, 255, 255)),
              onPressed: () {
                String shareText =
                    "Current weather in ${_weather?.areaName}:\nMax: ${_weather?.tempMax?.celsius?.toStringAsFixed(1)}° C\nMin: ${_weather?.tempMin?.celsius?.toStringAsFixed(1)}° C\nWind: ${_weather?.windSpeed?.toStringAsFixed(1)} m/s\nHumidity: ${_weather?.humidity?.toStringAsFixed(1)}%";
                Share.share(shareText);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _extraInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ],
    );
  }

  Widget _weatherForecast() {
    List<Weather> nextSevenDaysForecast = _forecast.take(7).toList();
    List<DateTime> nextSevenDays = [];
    List<Weather> uniqueForecast = [];

    for (Weather forecastItem in nextSevenDaysForecast) {
      DateTime date = forecastItem.date!;
      // Check if the date is not already in the list
      if (!nextSevenDays.contains(date) && uniqueForecast.length < 7) {
        nextSevenDays.add(date);
        uniqueForecast.add(forecastItem);
      }
    }

    return Column(
      children: [
        Text(
          "Weather Forecast for the Next 7 Days",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: uniqueForecast.length,
            itemBuilder: (context, index) {
              Weather forecastItem = uniqueForecast[index];
              return Card(
                color: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: 150,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        "http://openweathermap.org/img/wn/${forecastItem.weatherIcon}@2x.png",
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Max: ${forecastItem.tempMax?.celsius?.toStringAsFixed(1)}°C",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Min: ${forecastItem.tempMin?.celsius?.toStringAsFixed(1)}°C",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
