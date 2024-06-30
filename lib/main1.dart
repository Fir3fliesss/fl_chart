import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ScatterChartSample2(),
  ));
}

class ScatterChartSample2 extends StatefulWidget {
  const ScatterChartSample2({super.key});

  @override
  _ScatterChartSample2State createState() => _ScatterChartSample2State();
}

class FlDotCustomPainter extends FlDotPainter {
  final ui.Image image;

  FlDotCustomPainter(this.image);

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas,
      {double? opacity = 1,
      Color? color,
      double? strokeWidth = 0,
      double? radius = 15}) {
    final paint = Paint()
      ..color = color?.withOpacity(opacity ?? 1) ?? Colors.black;
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final destinationRect = Rect.fromCenter(
        center: offsetInCanvas, width: radius! * 2, height: radius * 2);
    final sourceRect = Rect.fromLTWH(0, 0, imageSize.width, imageSize.height);
    canvas.drawImageRect(image, sourceRect, destinationRect, paint);
  }

  @override
  Size getSize(FlSpot spot) => const Size(40, 40);

  void drawTouched(Canvas canvas, FlSpot spot, Offset offsetInCanvas,
      {Color? color, double? strokeWidth = 0, double? radius = 40}) {
    draw(canvas, spot, offsetInCanvas,
        opacity: 1, color: color, strokeWidth: strokeWidth, radius: radius);
  }

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    return this;
  }

  @override
  Color get mainColor => Colors.transparent;

  @override
  List<Object?> get props => [image];
}

class _ScatterChartSample2State extends State<ScatterChartSample2> {
  late Future<ui.Image> imageFuture;
  final Color circleColor = const Color(0xFF123456);
  List<Fish> fishData = [];
  Timer? _timer;
  int _seconds = 0;
  double confidenceValue = 0.0;

  @override
  void initState() {
    super.initState();
    startFetchingData();
    _startTimer();
    imageFuture = loadImage('assets/images/fish.png');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<ui.Image> loadImage(String asset) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  void fetchData() {
    var random = Random();
    bool fishMoved = false;

    setState(() {
      for (Fish fish in fishData) {
        fish.x += fish.vx;
        fish.y += fish.vy;

        if (fish.vx != 0 || fish.vy != 0) {
          fishMoved = true;
        }
      }

      fishData.removeWhere(
          (fish) => fish.x < 0 || fish.x > 10 || fish.y < 0 || fish.y > 10);

      if (random.nextDouble() < 0.1) {
        double x = random.nextBool() ? 0 : 10;
        double y = random.nextDouble() * 10;
        double vx = (random.nextDouble() * 0.2) - 0.1;
        double vy = (random.nextDouble() * 0.2) - 0.1;
        fishData.add(Fish(x: x, y: y, vx: vx, vy: vy));
        fishMoved = true;
      }

      if (fishMoved) {
        confidenceValue = random.nextDouble() * 100;
      } else {
        confidenceValue = 0.0;
      }
    });
  }

  void startFetchingData() {
    const period = Duration(seconds: 1);
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
    return FutureBuilder<ui.Image>(
      future: imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          List<ScatterSpotWithColor> spotsWithColors = fishData.map((fish) {
            return ScatterSpotWithColor(
              spot: ScatterSpot(
                fish.x,
                fish.y,
                dotPainter: FlDotCustomPainter(snapshot.data!),
              ),
              color: circleColor,
              xLabel:
                  '${fish.x.toStringAsFixed(2)}, ${fish.y.toStringAsFixed(2)}',
            );
          }).toList();

          List<String> timeLabels = _generateTimeLabels(_seconds);

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
                        padding: const EdgeInsets.only(
                            top: 25.0, right: 40.0, bottom: 50.0, left: 16.0),
                        child: ScatterChart(
                          ScatterChartData(
                            scatterSpots:
                                spotsWithColors.map((e) => e.spot).toList(),
                            minX: 0,
                            maxX: 10,
                            minY: 0,
                            maxY: 10,
                            borderData: FlBorderData(
                              show: true,
                              border: const Border(
                                left: BorderSide(color: Colors.black, width: 3),
                                bottom:
                                    BorderSide(color: Colors.black, width: 3),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawHorizontalLine: true,
                              checkToShowHorizontalLine: (value) =>
                                  value % 1 == 0,
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
                                    return Text(timeLabels[
                                        (value ~/ 2) % timeLabels.length]);
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
                                  Image.asset('assets/images/fish.png',
                                      width: 24,
                                      height:
                                          24), 
                                  const SizedBox(width: 8),
                                  const Text('18m',
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              Text(
                                  'Confident: ${confidenceValue.toStringAsFixed(2)}%',
                                  style: const TextStyle(fontSize: 16)),
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
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class Fish {
  double x, y, vx, vy;

  Fish({required this.x, required this.y, required this.vx, required this.vy});
}

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
