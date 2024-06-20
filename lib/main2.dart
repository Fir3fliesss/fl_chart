import 'dart:async'; // Import untuk Future dan Timer
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ScatterChartSample2(), // Menampilkan widget utama
  ));
}

class ScatterChartSample2 extends StatefulWidget {
  const ScatterChartSample2({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ScatterChartSample2State createState() => _ScatterChartSample2State();
}

class _ScatterChartSample2State extends State<ScatterChartSample2> {
  final Color circleColor = const Color(0xFF123456); // Warna lingkaran titik pada chart
  List<(double, double, double)> data = []; // List untuk menyimpan data titik

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mengambil data setiap detik
    startFetchingData();
  }

  // Fungsi untuk mengambil data posisi x, y dari modul atau API
  void fetchData() {
    // Simulasi data dinamis, bisa diganti dengan logika pengambilan data dari API
    var random = Random();
    double x = random.nextDouble() * 10; // Nilai x antara 0 dan 10
    double y = random.nextDouble() * 10; // Nilai y antara 0 dan 10
    double size = 10.0; // Ukuran tetap untuk contoh ini

    // Perbarui state dengan data baru
    setState(() {
      data.add((x, y, size)); // Tambahkan data baru ke dalam list
    });
  }

  // Fungsi untuk memulai fetching data setiap detik
  void startFetchingData() {
    const period = Duration(seconds: 1); // Periode polling data (contoh: setiap 1 detik)
    Timer.periodic(period, (Timer t) {
      fetchData(); // Panggil fungsi fetchData setiap periode
    });
  }

  @override
  Widget build(BuildContext context) {
    List<ScatterSpotWithColor> spotsWithColors = data.map((e) {
      final (double x, double y, double size) = e;
      return ScatterSpotWithColor(
        spot: ScatterSpot(
          x,
          y,
          dotPainter: FlDotCirclePainter(
            color: circleColor,
            radius: size,
          ),
        ),
        color: circleColor,
        xLabel: '${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)}',
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tes dinamis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Tambahkan navigasi ke halaman sebelumnya
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Padding untuk scatter chart
                Padding(
                  padding: const EdgeInsets.only(top: 25.0, right: 40.0, bottom: 45.0, left: 16.0),
                  child: ScatterChart(
                    ScatterChartData(
                      scatterSpots: spotsWithColors.map((e) => e.spot).toList(),
                      minX: 0,
                      maxX: 10,
                      minY: 0,
                      maxY: 10,
                      // Data untuk border
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(
                          left: BorderSide(color: Colors.black, width: 3),
                          bottom: BorderSide(color: Colors.black, width: 3),
                        ),
                      ),
                      // Data untuk grid
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
                      // Data untuk titles
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
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Text('...');
                                case 2:
                                  return const Padding(
                                    padding: EdgeInsets.only(right: 10), // Tambahkan padding di sini
                                    child: Text('1m20'),
                                  );
                                case 4:
                                  return const Padding(
                                    padding: EdgeInsets.only(right: 10), // Tambahkan padding di sini
                                    child: Text('1m30'),
                                  );
                                case 6:
                                  return const Padding(
                                    padding: EdgeInsets.only(right: 10), // Tambahkan padding di sini
                                    child: Text('1m40'),
                                  );
                                case 8:
                                  return const Padding(
                                    padding: EdgeInsets.only(right: 10), // Tambahkan padding di sini
                                    child: Text('1m50'),
                                  );
                                default:
                                  return const Text('');
                              }
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
                      // Data untuk interaksi touch pada scatter chart
                      scatterTouchData: ScatterTouchData(
                        enabled: false,
                        handleBuiltInTouches: false,
                      ),
                    ),
                  ),
                ),
                // Custom painter untuk label X
                CustomPaint(
                  painter: XLabelPainter(spotsWithColors),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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

// Custom painter untuk menampilkan label X pada titik-titik di chart
class XLabelPainter extends CustomPainter {
  final List<ScatterSpotWithColor> spotsWithColors;

  XLabelPainter(this.spotsWithColors);

  @override
  void paint(Canvas canvas, Size size) {
    for (final spotWithColor in spotsWithColors) {
      final textSpan = TextSpan(
        text: spotWithColor.xLabel,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final offset = Offset(
        spotWithColor.spot.x * size.width / 10 - textPainter.width / 2,
        (10 - spotWithColor.spot.y) * size.height / 10 - textPainter.height - 5,
      );
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
