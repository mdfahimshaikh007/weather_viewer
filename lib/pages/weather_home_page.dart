import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as Geo;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:weather_viewer/pages/settings_page.dart';

import '../providers/weather_provider.dart';
import '../utils/constants.dart';
import '../utils/helper_functions.dart';

class WeatherHomePage extends StatefulWidget {
  static const String routeName = '/home';
  const WeatherHomePage({Key? key}) : super(key: key);

  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  late WeatherProvider _provider;
  bool _isInit = true;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      _provider = Provider.of<WeatherProvider>(context);
      _provider.getStatus();
      _init();
    }
    super.didChangeDependencies();
  }

  void _init() {
    determinePosition().then((position) {
      _provider.setNewPosition(position.latitude, position.longitude);
      _provider.getData();
      print('lat: ${position.latitude}, lon: ${position.longitude}');
      _isInit = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Weather Viewer'),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: () {
              _init();
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final city = await showSearch(
                  context: context, delegate: _CitySearchDelegate());
              if (city != null && city.isNotEmpty) {
                print(city);
                try {
                  final locationList = await Geo.locationFromAddress(city);
                  if (locationList.isNotEmpty) {
                    final location = locationList.first;
                    _provider.setNewPosition(
                        location.latitude, location.longitude);
                    _provider.getData();
                  }
                } catch (error) {
                  print(error.toString());
                }
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () =>
                Navigator.pushNamed(context, SettingsPage.routeName),
          ),
        ],
      ),
      body: _provider.currentModel != null && _provider.forecastModel != null
          ? Stack(
              children: [
                Image.asset(
                  'images/sunset.jpg',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                Center(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const SizedBox(
                        height: 80,
                      ),
                      Column(
                        children: [
                          Text(
                            getFormattedDate(_provider.currentModel!.dt!,
                                'EEE MMM dd, yyyy'),
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${_provider.currentModel!.name}, ${_provider.currentModel!.sys!.country!}',
                            style: TextStyle(fontSize: 22),
                          ),
                          Text(
                            '${_provider.currentModel!.main!.temp!.toStringAsFixed(1)}\u00B0',
                            style: TextStyle(fontSize: 80),
                          ),
                          Text(
                            'feels like ${_provider.currentModel!.main!.feelsLike!.round()}\u00B0',
                            style: TextStyle(fontSize: 20),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                '$icon_prefix${_provider.currentModel!.weather![0].icon}$icon_suffix',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              Text(
                                  '${_provider.currentModel!.weather![0].description}')
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: double.maxFinite,
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _provider.forecastModel!.list!.length,
                          itemBuilder: (context, i) {
                            final item = _provider.forecastModel!.list![i];
                            return Card(
                              color: Colors.black.withOpacity(0.3),
                              //elevation: 10,
                              margin: EdgeInsets.all(4),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(getFormattedDate(
                                          item.dt!, 'EEE HH:mm')),
                                      Image.network(
                                        '$icon_prefix${item.weather![0].icon}$icon_suffix',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                      Text(
                                          '${item.main!.tempMax!.round()}/${item.main!.tempMin!.round()}\u00B0'),
                                      Text(item.weather![0].description!),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: Text('Please wait...'),
            ),
    );
  }
}

class _CitySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, "");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      onTap: () {
        close(context, query);
      },
      leading: const Icon(Icons.search),
      title: Text(query),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = query.isEmpty
        ? cities
        : cities
            .where((element) =>
                element.toLowerCase().startsWith(query.toLowerCase()))
            .toList();
    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          query = filteredList[index];
          close(context, query);
        },
        title: Text(filteredList[index]),
      ),
    );
  }
}
