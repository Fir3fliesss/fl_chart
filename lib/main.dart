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

    final spotsWithImages = data.asMap().entries.map((e) {
      final index = e.key;
      final (double x, double y, double size) = e.value;
      final imagePath = 'assets/fish.png'; // Path ke gambar Anda
      return ScatterSpotWithImage(
        spot: ScatterSpot(
          x,
          y,
          dotPainter: FlDotImagePainter(
            AssetImage(imagePath),
            size,
          ),
        ),
        imagePath: imagePath,
        xLabel: x.toString() + 'm',
      );
    }).toList();

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              ScatterChart(
                ScatterChartData(
                  scatterSpots: spotsWithImages.map((e) => e.spot).toList(),
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
                painter: XLabelPainter(spotsWithImages),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ScatterSpotWithImage {
  final ScatterSpot spot;
  final String imagePath;
  final String xLabel;

  ScatterSpotWithImage({
    required this.spot,
    required this.imagePath,
    required this.xLabel,
  });
}

class XLabelPainter extends CustomPainter {
  final List<ScatterSpotWithImage> spotsWithImages;

  XLabelPainter(this.spotsWithImages);

  @override
  void paint(Canvas canvas, Size size) {
    for (final spotWithImage in spotsWithImages) {
      final textSpan = TextSpan(
        text: spotWithImage.xLabel,
        style: TextStyle(
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
        spotWithImage.spot.x * size.width / 10 - textPainter.width / 2,
        (10 - spotWithImage.spot.y) * size.height / 10 - textPainter.height - 5,
      );
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class FlDotImagePainter extends FlDotPainter {
  final ImageProvider image;
  final double size;

  FlDotImagePainter(this.image, this.size);

  @override
  void draw(Canvas canvas, Offset offset, {required Color color, required double size}) {
    final paint = Paint();
    final rect = Rect.fromCenter(center: offset, width: this.size, height: this.size);
    final imageRect = Rect.fromLTWH(0, 0, this.size, this.size);

    paintImage(
      canvas: canvas,
      rect: rect,
      image: image,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }

  @override
  Size getSize() => Size(size, size);
}

void main() => runApp(MaterialApp(
  home: Scaffold(
    appBar: AppBar(title: const Text('Scatter Chart Sample')),
    body: const ScatterChartSample2(),
  ),
));
