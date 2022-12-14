import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_viewer/pages/settings_page.dart';
import 'package:weather_viewer/pages/weather_home_page.dart';
import 'package:weather_viewer/providers/weather_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WeatherProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Weather Viewer',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'RobotoSlab',
            brightness: Brightness.dark),
        home: const WeatherHomePage(),
        routes: {
          WeatherHomePage.routeName: (context) => const WeatherHomePage(),
          SettingsPage.routeName: (context) => const SettingsPage(),
        },
      ),
    );
  }
}
