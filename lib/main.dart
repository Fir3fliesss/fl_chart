import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Mendefinisikan widget ScatterChartSample2 yang akan digunakan sebagai tampilan utama scatter chart
class ScatterChartSample2 extends StatefulWidget {
  const ScatterChartSample2({super.key});

  @override
  State<StatefulWidget> createState() => _ScatterChartSample2State();
}

// State class yang digunakan untuk menyimpan dan mengelola state dari ScatterChartSample2
class _ScatterChartSample2State extends State<ScatterChartSample2> {
  int touchedIndex = -1; // Indeks dari spot yang disentuh

  // Warna abu-abu
  Color greyColor = Colors.grey;

  // Daftar warna yang tersedia untuk digunakan pada scatter spots
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

  List<int> selectedSpots = []; // Daftar indeks spots yang dipilih

  PainterType _currentPaintType = PainterType.circle; // Tipe painter yang digunakan

  // Metode statis untuk mendapatkan painter berdasarkan tipe dan ukuran
  static FlDotPainter _getPaint(PainterType type, double size, Color color) {
    switch (type) {
      case PainterType.circle:
        return FlDotCirclePainter(
          color: color,
          radius: size,
        );
      case PainterType.square:
        return FlDotSquarePainter(
          color: color,
          size: size * 2,
          strokeWidth: 0,
        );
      case PainterType.cross:
        return FlDotCrossPainter(
          color: color,
          size: size * 2,
          width: max(size / 5, 2),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Data untuk scatter spots
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

    // Menyimpan warna yang digunakan untuk setiap spot
    final spotsWithColors = data.asMap().entries.map((e) {
      final index = e.key;
      final (double x, double y, double size) = e.value;
      final color = selectedSpots.contains(index)
          ? _availableColors[index % _availableColors.length]
          : Colors.white.withOpacity(0.5);
      return ScatterSpotWithColor(
        spot: ScatterSpot(
          x,
          y,
          dotPainter: _getPaint(
            _currentPaintType,
            size,
            color,
          ),
        ),
        color: color,
      );
    }).toList();

    // Mengatur tampilan utama scatter chart
    return AspectRatio(
      aspectRatio: 1,
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
              showingTooltipIndicators: selectedSpots,
              scatterTouchData: ScatterTouchData(
                enabled: true,
                handleBuiltInTouches: false,
                mouseCursorResolver:
                    (FlTouchEvent touchEvent, ScatterTouchResponse? response) {
                  return response == null || response.touchedSpot == null
                      ? MouseCursor.defer
                      : SystemMouseCursors.click;
                },
                touchTooltipData: ScatterTouchTooltipData(
                  getTooltipColor: (ScatterSpot touchedSpot) {
                    return spotsWithColors.firstWhere(
                      (element) => element.spot == touchedSpot,
                    ).color;
                  },
                  getTooltipItems: (ScatterSpot touchedSpot) {
                    final bool isBgDark = touchedSpot.x.toInt().isEven;
                    final color1 = isBgDark ? Colors.grey[100] : Colors.black87;
                    final color2 = isBgDark ? Colors.white : Colors.black;
                    return ScatterTooltipItem(
                      'X: ',
                      textStyle: TextStyle(
                        height: 1.2,
                        color: color1,
                        fontStyle: FontStyle.italic,
                      ),
                      bottomMargin: 10,
                      children: [
                        TextSpan(
                          text: '${touchedSpot.x.toInt()} \n',
                          style: TextStyle(
                            color: color2,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: 'Y: ',
                          style: TextStyle(
                            height: 1.2,
                            color: color1,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                          text: touchedSpot.y.toInt().toString(),
                          style: TextStyle(
                            color: color2,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                touchCallback:
                    (FlTouchEvent event, ScatterTouchResponse? touchResponse) {
                  if (touchResponse == null || touchResponse.touchedSpot == null) {
                    return;
                  }
                  if (event is FlTapUpEvent) {
                    final sectionIndex = touchResponse.touchedSpot!.spotIndex;
                    setState(() {
                      if (selectedSpots.contains(sectionIndex)) {
                        selectedSpots.remove(sectionIndex);
                      } else {
                        selectedSpots.add(sectionIndex);
                      }
                    });
                  }
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton(
                value: _currentPaintType,
                items: PainterType.values
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name),
                        ))
                    .toList(),
                onChanged: (PainterType? value) {
                  setState(() {
                    _currentPaintType = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enum untuk menentukan tipe painter
enum PainterType {
  circle,
  square,
  cross,
}

// Kelas untuk menyimpan ScatterSpot bersama dengan warnanya
class ScatterSpotWithColor {
  final ScatterSpot spot;
  final Color color;

  ScatterSpotWithColor({
    required this.spot,
    required this.color,
  });
}

// Fungsi utama untuk menjalankan aplikasi Flutter
void main() => runApp(MaterialApp(
  home: Scaffold(
    appBar: AppBar(title: const Text('Scatter Chart Sample')),
    body: const ScatterChartSample2(),
  ),
));
