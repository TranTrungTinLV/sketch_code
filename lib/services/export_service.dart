import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sketch/model/stroke.dart';

/// Export canvas thành PNG hoặc JSON.
class ExportService {
  /// Export canvas thành PNG bytes
  /// Dùng RepaintBoundary key
  static Future<Uint8List?> exportToPng(GlobalKey boundaryKey) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Export PNG error: $e');
      return null;
    }
  }

  /// Export stroke data thành JSON string
  static String exportToJson(List<Stroke> strokes) {
    final data = {
      'version': '1.0',
      'app': 'DoodleMaster',
      'strokeCount': strokes.length,
      'strokes': strokes.map((s) => s.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Import strokes từ JSON string
  static List<Stroke>? importFromJson(String jsonString) {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final strokesJson = data['strokes'] as List;
      return strokesJson
          .map((s) => Stroke.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Import JSON error: $e');
      return null;
    }
  }
}
