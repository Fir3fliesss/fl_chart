import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:keep_screen_on/keep_screen_on.dart';

// local imports
import 'bluetooth_functions.dart' as bl_functions;

class FishFinderApp extends StatefulWidget {
  const FishFinderApp({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _FishFinderAppState createState() => _FishFinderAppState();
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
  String _platformVersion = 'Unknown';
  final _bluetoothClassicPlugin = BluetoothClassic();
  List<Device> _devices = [];
  List<Device> _discoveredDevices = [];
  bool _scanning = false;
  int _deviceStatus = Device.disconnected;
  Uint8List _data = Uint8List(0);
  double fishDepth = 0;
  double oceanDepth = 0;
  double confLv = 0;

  double maxDepth = 5000;
  String _GetDevicesButtonLabel = "Refresh Paired Bluetooth Devices";

  Future<ui.Image> loadImage(String asset) async {
    ByteData data = await rootBundle.load(asset);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    ui.FrameInfo fi = await codec.getNextFrame();
    return fi.image;
  }

  final Color circleColor = const Color(0xFF123456);
  final Color depthColor = Color.fromARGB(255, 66, 23, 6);
  List<Fish> fishData = [];
  List<Depth> depthData = [];
  Timer? _timer;
  double _xOffset = 0.0;
  Random random = Random();

  @override
  void initState() {
    _getBtState();
    KeepScreenOn.turnOn();
    _bluetoothClassicPlugin.initPermissions();
    super.initState();
    startFetchingData();
    _startTimer();
    imageFuture = loadImage('assets/images/fish.png');
    _controller = VideoPlayerController.asset('assets/images/lautlagi.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });

    _initiPlatformData();
    _bluetoothClassicPlugin.onDeviceStatusChanged().listen((event) {
      setState(() {
        _deviceStatus = event;
      });
    });
    _bluetoothClassicPlugin.onDeviceDataReceived().listen((event) {
      // _data = Uint8List.fromList([0, ...event]); // if you want to append data from BL to _data
      // but in this case, we want to only store the latest message from bluetooth
      Uint8List _blMsg = Uint8List.fromList([0, ...event]);
      String msg = String.fromCharCodes(_blMsg);
      // print("data: ${_blMsg}");
      List<String> _blMessages = msg.split(" ");
      double _fishDepth = double.parse(parseNumericString(_blMessages[0]));
      double _oceanDepth = double.parse(parseNumericString(_blMessages[1]));
      double _conf = double.parse(parseNumericString(_blMessages[2]));
      print("fishdepth: $_fishDepth - oceadepth: $_oceanDepth - conf: $_conf");
      setState(() {
        _data = _blMsg;
        fishDepth = _fishDepth;
        oceanDepth = _oceanDepth;
        confLv = _conf;
        // fishData.add(Fish(x: _xOffset, y: _fishDepth));
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  void _getBtState() async {
    bool bt_state = await bl_functions.enableBT();
    if (bt_state == true) {
      setState(() {
        _GetDevicesButtonLabel = "Refresh Paired Bluetooth Devices";
      });
    }
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
      // double y = random.nextDouble() * 10;
      // fishData.add(Fish(x: _xOffset, y: y));
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

  Future<void> _initiPlatformData() async {
    String _pltVer =
        await bl_functions.initPlatformState(_bluetoothClassicPlugin);
    setState(() {
      _platformVersion = _pltVer;
    });
  }

  Future<void> _getDevices() async {
    setState(() {
      _GetDevicesButtonLabel = "Refresh Paired Bluetooth Devices";
    });
    await bl_functions.enableBT().then((bt_enabled) {
      _bluetoothClassicPlugin.getPairedDevices().then((res) {
        setState(() {
          _devices = res;
        });
      });
    });
  }

  Future<void> _scan() async {
    if (_scanning) {
      await _bluetoothClassicPlugin.stopScan();
      setState(() {
        _scanning = false;
      });
    } else {
      await _bluetoothClassicPlugin.startScan();
      _bluetoothClassicPlugin.onDeviceDiscovered().listen(
        (event) {
          setState(() {
            _discoveredDevices = [..._discoveredDevices, event];
          });
        },
      );
      setState(() {
        _scanning = true;
      });
    }
  }

  late Future<ui.Image> imageFuture;
  late VideoPlayerController _controller;

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
                  // dotPainter: FlDotCustomPainter(snapshot.data!),
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
            body: _deviceStatus == Device.disconnected
                ? SingleChildScrollView(
                    child: Center(
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () async {
                            await _bluetoothClassicPlugin.initPermissions();
                          },
                          child: const Text("Check Permissions"),
                        ),
                        TextButton(
                          onPressed: _getDevices,
                          child: Text(_GetDevicesButtonLabel),
                        ),
                        // TextButton(
                        //   onPressed: _deviceStatus == Device.connected
                        //       ? () async {
                        //           await _bluetoothClassicPlugin.disconnect();
                        //         }
                        //       : null,
                        //   child: const Text("disconnect"),
                        // ),
                        // TextButton(
                        //   onPressed: _deviceStatus == Device.connected
                        //       ? () async {
                        //           await _bluetoothClassicPlugin.write("ping");
                        //         }
                        //       : null,
                        //   child: const Text("send ping"),
                        // ),
                        // Center(
                        //   child: Text('Running on: $_platformVersion\n'),
                        // ),
                        ...[
                          for (var device in _devices)
                            TextButton(
                                onPressed: () async {
                                  await _bluetoothClassicPlugin.connect(
                                      device.address,
                                      "00001101-0000-1000-8000-00805f9b34fb");
                                  setState(() {
                                    _discoveredDevices = [];
                                    _devices = [];
                                  });
                                },
                                child: Text(device.name ?? device.address))
                        ],
                        TextButton(
                          onPressed: _scan,
                          child: Text(_scanning
                              ? "Stop Scan"
                              : "Scan For Bluetooth Devices"),
                        ),
                        ...[
                          for (var device in _discoveredDevices)
                            Text(device.name ?? device.address)
                        ],
                        // Text("Received data: ${String.fromCharCodes(_data)}")
                      ],
                    ),
                  ))
                : Column(
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
                                        // Text(
                                        //     "Received data: ${String.fromCharCodes(_data)}"),
                                        Row(
                                          children: [
                                            Image.asset(
                                                'assets/images/fish.png',
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
                                            Image.asset(
                                                'assets/images/seawapes.png',
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
                                  top: 125,
                                  right: 40.0,
                                  bottom: 10,
                                  left: 16.0),
                              child: ScatterChart(
                                ScatterChartData(
                                  scatterSpots: spotsWithColors
                                      .map((e) => e.spot)
                                      .toList(),
                                  minX: _xOffset - 10,
                                  maxX: _xOffset,
                                  minY: 0,
                                  maxY: maxDepth,
                                  borderData: FlBorderData(
                                    show: true,
                                    border: const Border(
                                      left: BorderSide(
                                          color: Colors.white, width: 2),
                                      bottom: BorderSide(
                                          color: Colors.white, width: 2),
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
                                            padding:
                                                const EdgeInsets.only(right: 0),
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
