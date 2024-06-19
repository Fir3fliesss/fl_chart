import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ScatterChartSample2 extends StatefulWidget {
  const ScatterChartSample2({super.key});

  @override
  State<StatefulWidget> createState() => _ScatterChartSample2State();
}

class _ScatterChartSample2State extends State<ScatterChartSample2> {
  final Color circleColor = const Color(0xFF123456); // Ganti dengan warna kustom yang Anda inginkan

  @override
  Widget build(BuildContext context) {
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
                  backgroundColor: Colors.lightBlue,
                  borderData: FlBorderData(
                    show: false,
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    checkToShowHorizontalLine: (value) => true,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.green[900]!,
                    ),
                    drawVerticalLine: true,
                    checkToShowVerticalLine: (value) => true,
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.green[900]!,
                    ),
                  ),
                  titlesData: const FlTitlesData(
                    show: true,
                  ),
                  scatterTouchData: ScatterTouchData(
                    enabled: false,
                    handleBuiltInTouches: false,
                    // touchCallback: (FlTouchEvent event, ScatterTouchResponse? response) {
                    //   if (event.isInterestedForInteractions && response != null) {
                    //     // Handle the touch event. For now, do nothing
                    //     // But you can show a custom message or perform any action here
                    //     ('ScatterSpot touched: ${response.touchedSpot}');
                    //   }
                    // },
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
