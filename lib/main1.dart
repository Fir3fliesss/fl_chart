import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ScatterChartSample2 extends StatefulWidget {
  const ScatterChartSample2({super.key});

  @override
  State<StatefulWidget> createState() => _ScatterChartSample2State();
}

class _ScatterChartSample2State extends State<ScatterChartSample2> {
  final Color circleColor = const Color(0xFF123456);
  List<ScatterSpotWithColor> spotsWithColors = [];
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeData() {
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

    spotsWithColors = data.map((e) {
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
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    List<String> _timeLabels = _generateTimeLabels(_seconds);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 25, 182, 255),
        title: const Text('Pembacaan Fishfinder'),
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
                  padding: const EdgeInsets.only(top: 25.0, right: 40.0, bottom: 45.0, left: 16.0),
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

class ScatterSpotWithColor {
  final ScatterSpot spot;
  final Color color;
  String xLabel;

  ScatterSpotWithColor({
    required this.spot,
    required this.color,
    required this.xLabel,
  });
}

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

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: ScatterChartSample2(),
));