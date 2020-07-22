import 'package:flutter/material.dart';
import 'system_configuration.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
    initSystemConfiguration();  //open System configuration database
    setAppReady();  //use this method when the app is fully opened
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    );
  }
}
