import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ScatterChartSample2 extends StatefulWidget {
  const ScatterChartSample2({super.key});

  @override
  State<StatefulWidget> createState() => _ScatterChartSample2State();
}

class _ScatterChartSample2State extends State<ScatterChartSample2> {
  final _availableColors = [
    Colors.green,
    Colors.yellow,
    Colors.pink,
    Colors.orange,
    Colors.purple,
    Colors.blue,
    Colors.red,
    Colors.cyan,
    Colors.blue,
    Colors.green,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    final data = [
      (4.0, 4.0, 4.0),
      (2.0, 5.0, 12.0),
      (4.0, 5.0, 8.0),
      (8.0, 6.0, 20.0),
      (5.0, 7.0, 14.0),
      (7.0, 2.0, 18.0),
      (3.0, 2.0, 36.0),
      (2.0, 8.0, 22.0),
      (8.0, 8.0, 32.0),
      (5.0, 2.5, 24.0),
      (3.0, 7.0, 18.0),
    ];

    final spotsWithColors = data.asMap().entries.map((e) {
      final index = e.key;
      final (double x, double y, double size) = e.value;
      final color = _availableColors[index % _availableColors.length];
      return ScatterSpotWithColor(
        spot: ScatterSpot(
          x,
          y,
          dotPainter: FlImagePainter(
            image: const AssetImage('assets/fish.png'),
            size: Size(size, size),
          ),
        ),
        color: color,
        xLabel: '${x}m',
      );
    }).toList();

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              ScatterChart(
                ScatterChartData(
                  scatterSpots: spotsWithColors.map((e) => e.spot).toList(),
                  minX: 0,
                  maxX: 10,
                  minY: 0,
                  maxY: 10,
                  borderData: FlBorderData(
                    show: false,
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    checkToShowHorizontalLine: (value) => true,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey[300]!,
                    ),
                    drawVerticalLine: true,
                    checkToShowVerticalLine: (value) => true,
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.grey[300]!,
                    ),
                  ),
                  titlesData: const FlTitlesData(
                    show: false,
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
    );
  }
}

// ignore: non_constant_identifier_names
FlImagePainter({required AssetImage image, required Size size}) {
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

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    appBar: AppBar(title: const Text('Fish Finder')),
    body: const ScatterChartSample2(),
  ),
));