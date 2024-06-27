import 'package:flutter/material.dart';
import 'main1.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fish Finder',
      home: const MainPage(),
      routes: {
        '/main1': (context) => const ScatterChartSample2(),
      },
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fish Finder'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Mulai mencari ikan"),
          onPressed: () {
            Navigator.pushNamed(context, '/main1');
          },
        ),
      ),
    );
  }
}
