import 'package:flutter/material.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/detail_screen.dart';
import 'src/screens/scanning_screen.dart';

void main() => runApp(MyApp());


//Intial Point for the App
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ticket Check-in',
      theme: ThemeData(
        primarySwatch: Colors.red,
        canvasColor: Colors.transparent,
      ),
      home: LoginPage(),
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/Home': return new MaterialPageRoute(
            builder: (BuildContext context) => new HomeScreen(),
            settings: settings,
          );
          case '/Detail': return new MaterialPageRoute(
            builder: (BuildContext context) => new DetailScreen(),
            settings: settings,
          );
          case '/Scanning': return new MaterialPageRoute(
            builder: (BuildContext context) => new ScanningScreen(),
            settings: settings,
          );
        }
        assert(false);
      },
    );
  }
}
