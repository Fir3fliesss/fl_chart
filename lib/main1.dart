// Import package yang dibutuhkan {async: Timer, math: Random, fl_chart: Chart}
import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Fungsi utama untuk menampilkan Widget utama
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ScatterChartSample2(),
  ));
}

class ScatterChartSample2 extends StatefulWidget {
  const ScatterChartSample2({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ScatterChartSample2State createState() => _ScatterChartSample2State();
}

class _ScatterChartSample2State extends State<ScatterChartSample2> {
  final Color circleColor = const Color(0xFF123456); // Warna lingkaran pada chart
  List<Fish> fishData = []; // List untuk menyimpan data ikan
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mengambil data setiap detik
    startFetchingData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Fungsi untuk mengambil data posisi x, y dari modul atau API
  void fetchData() {
    var random = Random();
    // Update posisi ikan
    setState(() {
      for (Fish fish in fishData) {
        // Update posisi ikan dengan kecepatan dan arah
        fish.x += fish.vx;
        fish.y += fish.vy;
      }

      // Hapus ikan yang keluar dari batas chart
      fishData.removeWhere((fish) => fish.x < 0 || fish.x > 10 || fish.y < 0 || fish.y > 10);

      // Tambahkan ikan baru secara acak
      if (random.nextDouble() < 0.1) { // Sesuaikan probabilitas munculnya ikan baru
        double x = random.nextBool() ? 0 : 10; // Muncul dari kiri atau kanan
        double y = random.nextDouble() * 10;
        double vx = (random.nextDouble() * 0.2) - 0.1; // Kecepatan x (-0.1 hingga 0.1)
        double vy = (random.nextDouble() * 0.2) - 0.1; // Kecepatan y (-0.1 hingga 0.1)
        fishData.add(Fish(x: x, y: y, vx: vx, vy: vy));
      }
    });
  }

  // Fungsi fetching data setiap {periode} detik
  void startFetchingData() {
    const period = Duration(seconds: 1); // Update setiap detik
    Timer.periodic(period, (Timer t) {
      fetchData();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        _seconds += 10;
      });
    });
  }

  List<String> _generateTimeLabels(int seconds) {
    List<String> labels = [];
    int start = seconds ~/ 10 * 10;

    for (int i = start - 50; i <= start; i += 10) {
      if (i <= 0) {
        labels.add('...');
      } else if (i < 60) {
        labels.add('${i}s');
      } else {
        int minutes = i ~/ 60;
        int seconds = i % 60;
        labels.add('${minutes}m${seconds.toString().padLeft(2, '0')}s');
      }
    }
    return labels.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    List<ScatterSpotWithColor> spotsWithColors = fishData.map((fish) {
      return ScatterSpotWithColor(
        spot: ScatterSpot(
          fish.x,
          fish.y,
          dotPainter: FlDotCirclePainter(
            color: circleColor,
            radius: 10.0,
          ),
        ),
        color: circleColor,
        xLabel: '${fish.x.toStringAsFixed(2)}, ${fish.y.toStringAsFixed(2)}',
      );
    }).toList();

    List<String> _timeLabels = _generateTimeLabels(_seconds);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 35, 178, 255),
        title: const Text('Fish Finder'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 25.0, right: 40.0, bottom: 50.0, left: 16.0),
                  child: ScatterChart(
                    ScatterChartData(
                      scatterSpots: spotsWithColors.map((e) => e.spot).toList(),
                      minX: 0,
                      maxX: 10,
                      minY: 0,
                      maxY: 10,
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          left: BorderSide(color: Colors.black, width: 3),
                          bottom: BorderSide(color: Colors.black, width: 3),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        checkToShowHorizontalLine: (value) => value % 1 == 0,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey[300]!,
                        ),
                        drawVerticalLine: true,
                        checkToShowVerticalLine: (value) => false,
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Text(
                                  "${(100 - value * 10).toStringAsFixed(0)} m",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 2,
                            getTitlesWidget: (value, meta) {
                              return Text(_timeLabels[(value ~/ 2) % _timeLabels.length]);
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      scatterTouchData: ScatterTouchData(
                        enabled: false,
                        handleBuiltInTouches: false,
                      ),
                    ),
                  ),
                ),
                // Menambahkan bottom container
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.white,
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/images/fish.png', width: 24, height: 24), // Ganti dengan ikon ikan Anda
                            const SizedBox(width: 8),
                            const Text('18m', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        const Text('Confident: 80%', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Fish {
  double x, y, vx, vy;

  Fish({required this.x, required this.y, required this.vx, required this.vy});
}

// Class untuk menyimpan data titik dengan warna dan label X
class ScatterSpotWithColor {
  final ScatterSpot spot;
  final Color color;
  final String xLabel;

  ScatterSpotWithColor({
    required this.spot,
    required this.color,
    required this.xLabel,
  });
}
