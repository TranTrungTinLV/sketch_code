import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sketch/engine/stroke_renderer.dart';
import 'package:sketch/model/layer.dart';
import 'package:sketch/model/stroke.dart';
import 'package:sketch/untils/app_colors.dart';

/// Canvas chính — hỗ trợ multi-layer, zoom/pan, nét vẽ mượt.
class CanvasArea extends StatelessWidget {
  final GlobalKey canvasBoundaryKey;
  final TransformationController transformController;
  final List<CanvasLayer> layers;
  final Map<String, List<Stroke>> layerStrokes; // layerId → strokes
  final List<StrokePoint> currentStrokePoints;
  final Color currentColor;
  final double currentStrokeWidth;
  final BrushType currentBrush;
  final String activeLayerId;
  final Map<String, Uint8List?> layerImages; // layerId → image bytes
  final Function(Offset) onPanStart;
  final Function(Offset) onPanUpdate;
  final VoidCallback onPanEnd;

  const CanvasArea({
    super.key,
    required this.canvasBoundaryKey,
    required this.transformController,
    required this.layers,
    required this.layerStrokes,
    required this.currentStrokePoints,
    required this.currentColor,
    required this.currentStrokeWidth,
    required this.currentBrush,
    required this.activeLayerId,
    required this.layerImages,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.bgCanvas,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(77),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InteractiveViewer(
        transformationController: transformController,
        minScale: 0.3,
        maxScale: 5.0,
        panEnabled: false, // Pan chỉ khi 2 ngón tay
        scaleEnabled: true,
        child: GestureDetector(
          onPanStart: (d) {
            // Chuyển tọa độ screen → canvas (M_inverse * P_screen)
            final matrix = transformController.value;
            final inverse = Matrix4.inverted(matrix);
            final canvasPos = MatrixUtils.transformPoint(
              inverse,
              d.localPosition,
            );
            onPanStart(canvasPos);
          },
          onPanUpdate: (d) {
            final matrix = transformController.value;
            final inverse = Matrix4.inverted(matrix);
            final canvasPos = MatrixUtils.transformPoint(
              inverse,
              d.localPosition,
            );
            onPanUpdate(canvasPos);
          },
          onPanEnd: (_) => onPanEnd(),
          child: RepaintBoundary(
            key: canvasBoundaryKey,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Image Layers (Reference & Scanned Sketch)
                ...layers
                    .where((l) =>
                        l.type != LayerType.drawing && l.visible)
                    .map((layer) {
                  final bytes = layerImages[layer.id];
                  if (bytes == null) return const SizedBox.shrink();
                  
                  return Opacity(
                    opacity: layer.opacity,
                    child: Center(
                      child: Image.memory(
                        bytes,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                }),
                
                // 2. Drawing Layers & Grid
                CustomPaint(
                  painter: _MultiLayerPainter(
                    layers: layers,
                    layerStrokes: layerStrokes,
                    currentStrokePoints: currentStrokePoints,
                    currentColor: currentColor,
                    currentStrokeWidth: currentStrokeWidth,
                    currentBrush: currentBrush,
                    activeLayerId: activeLayerId,
                    layerImages: layerImages,
                  ),
                  size: Size.infinite,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MultiLayerPainter extends CustomPainter {
  final List<CanvasLayer> layers;
  final Map<String, List<Stroke>> layerStrokes;
  final List<StrokePoint> currentStrokePoints;
  final Color currentColor;
  final double currentStrokeWidth;
  final BrushType currentBrush;
  final String activeLayerId;
  final Map<String, Uint8List?> layerImages;

  _MultiLayerPainter({
    required this.layers,
    required this.layerStrokes,
    required this.currentStrokePoints,
    required this.currentColor,
    required this.currentStrokeWidth,
    required this.currentBrush,
    required this.activeLayerId,
    required this.layerImages,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dot grid nền
    _drawDotGrid(canvas, size);

    // 2. Center guides
    _drawCenterGuide(canvas, size);

    // 3. Render từng layer theo thứ tự (bottom → top)
    for (final layer in layers) {
      if (!layer.visible) continue;

      canvas.saveLayer(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Color.fromRGBO(255, 255, 255, layer.opacity),
      );

      switch (layer.type) {
        case LayerType.referenceImage:
        case LayerType.scannedSketch:
          // Images are now rendered by Image.memory in the Stack above
          break;
        case LayerType.drawing:
          _drawStrokeLayer(canvas, layer);
          // Vẽ nét hiện tại trên active layer
          if (layer.id == activeLayerId && currentStrokePoints.isNotEmpty) {
            _drawLiveStroke(canvas);
          }
          break;
      }

      canvas.restore();
    }
  }

  void _drawDotGrid(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = const Color(0xFFD0D0D0).withAlpha(90)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    const spacing = 24.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.7, dotPaint);
      }
    }
  }

  void _drawCenterGuide(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = AppColors.accentCyan.withAlpha(30)
      ..strokeWidth = 0.5;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      guidePaint,
    );
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      guidePaint,
    );
  }



  void _drawStrokeLayer(Canvas canvas, CanvasLayer layer) {
    final strokes = layerStrokes[layer.id];
    if (strokes == null) return;

    for (final stroke in strokes) {
      final path = StrokeRenderer.getStrokePath(stroke);
      final paint = StrokeRenderer.getStrokePaint(stroke);
      canvas.drawPath(path, paint);
    }
  }

  void _drawLiveStroke(Canvas canvas) {
    final path = StrokeRenderer.getLiveStrokePath(
      currentStrokePoints,
      brushType: currentBrush,
      baseWidth: currentStrokeWidth,
    );
    final paint = StrokeRenderer.getLivePaint(
      color: currentColor,
      brushType: currentBrush,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MultiLayerPainter oldDelegate) => true;
}
