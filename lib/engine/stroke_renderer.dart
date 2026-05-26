import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart' as pf;
import 'package:sketch/model/stroke.dart';

/// Render nét vẽ mượt bằng perfect_freehand.
class StrokeRenderer {
  /// Render một Stroke hoàn chỉnh thành Path
  static Path getStrokePath(Stroke stroke) {
    if (stroke.points.isEmpty) return Path();

    final options = _getOptionsForBrush(stroke.brushType, stroke.baseWidth, isComplete: true);
    final inputPoints = stroke.points
        .map((p) => pf.PointVector(p.position.dx, p.position.dy, p.pressure))
        .toList();
    final outlinePoints = pf.getStroke(inputPoints, options: options);

    return _offsetsToPath(outlinePoints);
  }

  /// Render nét đang vẽ live
  static Path getLiveStrokePath(
    List<StrokePoint> points, {
    BrushType brushType = BrushType.pen,
    double baseWidth = 3.0,
  }) {
    if (points.isEmpty) return Path();

    final inputPoints = points
        .map((p) => pf.PointVector(p.position.dx, p.position.dy, p.pressure))
        .toList();
    final options = _getOptionsForBrush(brushType, baseWidth, isComplete: false);
    final outlinePoints = pf.getStroke(inputPoints, options: options);

    return _offsetsToPath(outlinePoints);
  }

  static pf.StrokeOptions _getOptionsForBrush(
    BrushType type,
    double baseWidth, {
    bool isComplete = true,
  }) {
    switch (type) {
      case BrushType.pen:
        return pf.StrokeOptions(
          size: baseWidth,
          thinning: 0.5,
          smoothing: 0.5,
          streamline: 0.5,
          start: pf.StrokeEndOptions.start(taperEnabled: true),
          end: pf.StrokeEndOptions.end(taperEnabled: true),
          simulatePressure: true,
          isComplete: isComplete,
        );

      case BrushType.pencil:
        return pf.StrokeOptions(
          size: baseWidth * 0.7,
          thinning: 0.7,
          smoothing: 0.3,
          streamline: 0.3,
          start: pf.StrokeEndOptions.start(taperEnabled: true),
          end: pf.StrokeEndOptions.end(taperEnabled: true),
          simulatePressure: true,
          isComplete: isComplete,
        );

      case BrushType.brush:
        return pf.StrokeOptions(
          size: baseWidth * 2.0,
          thinning: 0.6,
          smoothing: 0.7,
          streamline: 0.7,
          start: pf.StrokeEndOptions.start(taperEnabled: true),
          end: pf.StrokeEndOptions.end(taperEnabled: true),
          simulatePressure: true,
          isComplete: isComplete,
        );

      case BrushType.marker:
        return pf.StrokeOptions(
          size: baseWidth * 1.5,
          thinning: 0.0,
          smoothing: 0.5,
          streamline: 0.5,
          simulatePressure: false,
          isComplete: isComplete,
        );

      case BrushType.eraser:
        return pf.StrokeOptions(
          size: baseWidth * 3.0,
          thinning: 0.0,
          smoothing: 0.5,
          streamline: 0.5,
          simulatePressure: false,
          isComplete: isComplete,
        );
    }
  }

  /// Chuyển Offset list thành Path
  static Path _offsetsToPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    return path;
  }

  /// Paint cho Stroke hoàn chỉnh
  static Paint getStrokePaint(Stroke stroke) {
    if (stroke.brushType == BrushType.eraser) {
      return Paint()
        ..color = const Color(0xFFF5F5F0)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
    }

    final paint = Paint()
      ..color = stroke.color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    if (stroke.brushType == BrushType.marker) {
      paint.color = stroke.color.withAlpha(120);
    }

    return paint;
  }

  /// Paint cho live stroke
  static Paint getLivePaint({
    required Color color,
    required BrushType brushType,
  }) {
    if (brushType == BrushType.eraser) {
      return Paint()
        ..color = const Color(0xFFF5F5F0)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    if (brushType == BrushType.marker) {
      paint.color = color.withAlpha(120);
    }

    return paint;
  }
}
