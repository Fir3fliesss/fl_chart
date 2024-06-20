// Import library Flutter dan charting
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Widget utama untuk menampilkan scatter chart
class ScatterChartSample2 extends StatefulWidget {
  const ScatterChartSample2({super.key});

  @override
  State<StatefulWidget> createState() => _ScatterChartSample2State();
}

// State dari widget ScatterChartSample2
class _ScatterChartSample2State extends State<ScatterChartSample2> {
  final Color circleColor = const Color(0xFF123456); // Warna lingkaran titik pada chart

  @override
  Widget build(BuildContext context) {
    // Data titik-titik untuk scatter chart {x, y, size}
    final data = [
      (4.0, 4.0, 10.0),
      (2.0, 5.0, 10.0),
      (4.0, 5.0, 10.0),
      (8.0, 6.0, 10.0),
      (5.0, 7.0, 10.0),
      (7.0, 2.0, 10.0),
      (3.0, 2.0, 10.0),
      (2.0, 8.0, 10.0),
      (8.0, 8.0, 10.0),
      (5.0, 2.5, 10.0),
      (3.0, 7.0, 10.0),
    ];

    // Membuat list dari ScatterSpotWithColor dari data
    final spotsWithColors = data.map((e) {
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
        xLabel: '${x}m',
      );
    }).toList();

    // Membuat UI dengan column dan stack
    return Column(
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
                      bottomTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
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

// Main function untuk menjalankan aplikasi Flutter
void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    appBar: AppBar(title: const Text('Fish Finder')), // Judul aplikasi
    body: const ScatterChartSample2(), // Menampilkan widget utama
  ),
));
