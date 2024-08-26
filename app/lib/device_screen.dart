import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';

// chart imports
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:video_player/video_player.dart';

// local imports
import 'custom_painter.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key, required this.connection});

  final BluetoothConnection connection;

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  // initialize variables
  // bluetooth_classic
  StreamSubscription? _readSubscription;
  final List<String> _receivedInput = [];

  // fishfinder
  late Future<ui.Image> imageFuture;
  late VideoPlayerController _controller;
  double fishDepth = 0;
  double oceanDepth = 0;
  double confLv = 0;
  // fishfinder UI
  double maxDepth = 5000;
  final Color circleColor = const Color(0xFF123456);
  final Color depthColor = Color.fromARGB(255, 66, 23, 6);
  List<Fish> fishData = [];
  List<Depth> depthData = [];
  double _xOffset = 0.0;
  Timer? _timer;

  @override
  void initState() {
    // bluetooth_classic
    _readSubscription = widget.connection.input?.listen((event) {
      if (mounted) {
        // setState(() => _receivedInput.add(utf8.decode(event)));; // if you want to append data from BL to _data
        // but in this case, we want to only store the latest message from bluetooth
        Uint8List _blMsg = Uint8List.fromList([0, ...event]);
        String msg = String.fromCharCodes(_blMsg);
        // print("data: ${_blMsg}");
        List<String> _blMessages = msg.split(" ");
        double _fishDepth = double.parse(parseNumericString(_blMessages[0]));
        double _oceanDepth = double.parse(parseNumericString(_blMessages[1]));
        double _conf = double.parse(parseNumericString(_blMessages[2]));
        print(
            "fishdepth: $_fishDepth - oceadepth: $_oceanDepth - conf: $_conf");
        setState(() {
          fishDepth = _fishDepth;
          oceanDepth = _oceanDepth;
          confLv = _conf;
        });
      }
    });

    // fishfinder
    startFetchingData();
    _startTimer();
    imageFuture = loadImage('assets/images/fish.png');
    _controller = VideoPlayerController.asset('assets/images/lautlagi.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });

    // flutter
    super.initState();
  }

  @override
  void dispose() {
    widget.connection.dispose();
    _readSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  // function definitions
  Future<ui.Image> loadImage(String asset) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  String parseNumericString(String s) {
    String newS = "";
    s.runes.forEach((int rune) {
      var character = new String.fromCharCode(rune);
      if (isNumeric(character)) {
        newS += character;
      }
    });
    return newS;
  }

  void fetchData() {
    setState(() {
      fishData.add(Fish(x: _xOffset, y: maxDepth - fishDepth));
      depthData.add(Depth(x: _xOffset, y: maxDepth - oceanDepth));
    });
  }

  void startFetchingData() {
    const period = Duration(seconds: 1);
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          List<ScatterSpotWithColor> spotsWithColors = [];
          for (var fish in fishData) {
            spotsWithColors.add(ScatterSpotWithColor(
              spot: ScatterSpot(
                fish.x,
                fish.y,
                dotPainter: FlDotCustomPainter(snapshot.data!),
              ),
              color: circleColor,
              xLabel:
                  '${fish.x.toStringAsFixed(2)}, ${fish.y.toStringAsFixed(2)}',
            ));
          }
          for (var depth in depthData) {
            spotsWithColors.add(ScatterSpotWithColor(
              spot: ScatterSpot(depth.x, depth.y,
                  dotPainter: FlDotCirclePainter(
                    radius: 10,
                    color: Colors.primaries[16],
                  )),
              color: depthColor,
              xLabel:
                  '${depth.x.toStringAsFixed(2)}, ${depth.y.toStringAsFixed(2)}',
            ));
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 35, 178, 255),
              title: const Text('Fish Finder'),
            ),
            bottomNavigationBar: BottomAppBar(
              color: Colors.blue,
              height: 60,
              shadowColor: Colors.black38,
              child: Center(
                child: Text(
                  'Confidence: ${confLv}%',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _controller.value.isInitialized
                            ? VideoPlayer(_controller)
                            : Container(color: Colors.black),
                      ),
                      Positioned(
                        top: 20,
                        right: 255,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  const Text(
                                    "Data Terkini",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Row(
                                    children: [
                                      Image.asset('assets/images/fish.png',
                                          width: 30),
                                      Text(
                                        ":${fishDepth} meter",
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.asset('assets/images/seawapes.png',
                                          width: 30),
                                      Text(
                                        ":${oceanDepth} meter",
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 125, right: 40.0, bottom: 10, left: 16.0),
                        child: ScatterChart(
                          ScatterChartData(
                            scatterSpots:
                                spotsWithColors.map((e) => e.spot).toList(),
                            minX: _xOffset - 10,
                            maxX: _xOffset,
                            minY: 0,
                            maxY: maxDepth,
                            borderData: FlBorderData(
                              show: true,
                              border: const Border(
                                left: BorderSide(color: Colors.white, width: 2),
                                bottom:
                                    BorderSide(color: Colors.white, width: 2),
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
                                  interval: maxDepth / 10,
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 0),
                                      child: Text(
                                        "${(maxDepth - value).toStringAsFixed(0)} m",
                                        style: const TextStyle(
                                          color: Colors.white,
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
                                      return Text(
                                        '${value.toStringAsFixed(0)}s',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      );
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

class Depth {
  double x, y;

  Depth({required this.x, required this.y});
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
