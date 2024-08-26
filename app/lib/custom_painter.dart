import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

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
