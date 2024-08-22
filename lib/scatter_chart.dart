import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FishFinderApp(),
  ));
}

class FishFinderApp extends StatefulWidget {
  const FishFinderApp({super.key});

  @override
  _FishFinderAppState createState() => _FishFinderAppState();
}

class FlDotCustomPainter extends FlDotPainter {
  final ui.Image image;

  FlDotCustomPainter(this.image);

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas,
      {double? opacity = 1, Color? color, double? strokeWidth = 0, double? radius = 15}) {
    final paint = Paint()..color = color?.withOpacity(opacity ?? 1) ?? Colors.black;
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final destinationRect = Rect.fromCenter(center: offsetInCanvas, width: radius! * 2, height: radius * 2);
    final sourceRect = Rect.fromLTWH(0, 0, imageSize.width, imageSize.height);
    canvas.drawImageRect(image, sourceRect, destinationRect, paint);
  }

  @override
  Size getSize(FlSpot spot) => const Size(40, 40);

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    return this;
  }

  @override
  Color get mainColor => Colors.transparent;

  @override
  List<Object?> get props => [image];
}

class _FishFinderAppState extends State<FishFinderApp> {
  Future<ui.Image> loadImage(String asset) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  final Color circleColor = const Color(0xFF123456); // Warna lingkaran pada chart
  List<Fish> fishData = []; // List untuk menyimpan data ikan
  Timer? _timer;
  double _xOffset = 0.0;
  Random random = Random();

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

  void fetchData() {
    setState(() {
      double y = random.nextDouble() * 10;
      fishData.add(Fish(x: _xOffset, y: y));
      if (fishData.length > 10) {
        fishData.removeAt(0);
      }
    });
  }

  void startFetchingData() {
    const period = Duration(seconds: 10); // Update setiap 10 detik
    Timer.periodic(period, (Timer t) {
      fetchData();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _xOffset += 1;
      });
    });
  }

  late Future<ui.Image> imageFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          List<ScatterSpotWithColor> spotsWithColors = [];
          for (var fish in fishData) {
            spotsWithColors.add(ScatterSpotWithColor(
              spot: ScatterSpot(
                fish.x,
                fish.y,
                dotPainter: FlDotCustomPainter(snapshot.data!),
              ),
              color: circleColor,
              xLabel: '${fish.x.toStringAsFixed(2)}, ${fish.y.toStringAsFixed(2)}',
            ));
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 35, 178, 255),
              title: const Text('Fish Finder'),
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
                            minX: _xOffset - 10,
                            maxX: _xOffset,
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
                                  interval: 10,
                                  getTitlesWidget: (value, meta) {
                                    if (value % 10 == 0) {
                                      return Text('${value.toStringAsFixed(0)}s');
                                    }
                                    return const Text('');
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
                                  Image.asset('assets/images/fish.png', width: 24, height: 24),
                                  const SizedBox(width: 8),
                                  const Text('18m', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              Text('Confident: ${random.nextInt(101)}%',
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
  double x, y;

  Fish({required this.x, required this.y});
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