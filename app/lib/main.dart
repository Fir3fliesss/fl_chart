import 'package:flutter/material.dart';
import 'main1.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FishFinderApp(title: 'Fishfinder'),
    );
  }
}
