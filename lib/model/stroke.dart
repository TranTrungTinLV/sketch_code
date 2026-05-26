import 'dart:ui';

/// Loại cọ vẽ
enum BrushType {
  pen,      // Bút mực — nét đều, sắc nét
  pencil,   // Bút chì — nét mỏng, mảnh
  brush,    // Cọ vẽ — nét dày, biến đổi theo áp lực
  marker,   // Bút dạ quang — nét đều, bán trong suốt
  eraser,   // Tẩy
}

/// Một điểm trong nét vẽ, kèm timestamp để tính velocity
class StrokePoint {
  final Offset position;
  final double pressure; // 0.0 → 1.0, giả lập từ velocity
  final int timestamp;   // millisecondsSinceEpoch

  const StrokePoint({
    required this.position,
    this.pressure = 0.5,
    required this.timestamp,
  });

  /// Chuyển sang định dạng cho perfect_freehand: [x, y, pressure]
  List<double> toFreehandPoint() => [position.dx, position.dy, pressure];
}

/// Một nét vẽ hoàn chỉnh (từ onPanDown → onPanEnd)
class Stroke {
  final List<StrokePoint> points;
  final Color color;
  final double baseWidth;
  final BrushType brushType;

  Stroke({
    required this.points,
    this.color = const Color(0xFF000000),
    this.baseWidth = 3.0,
    this.brushType = BrushType.pen,
  });

  bool get isEmpty => points.isEmpty;
  bool get isNotEmpty => points.isNotEmpty;

  /// Tổng chiều dài nét vẽ
  double get totalLength {
    double len = 0;
    for (int i = 1; i < points.length; i++) {
      len += (points[i].position - points[i - 1].position).distance;
    }
    return len;
  }

  /// Tính áp lực giả lập từ velocity giữa 2 điểm liên tiếp.
  ///
  /// Công thức: velocity = distance / timeDelta
  /// Nếu vẽ nhanh (v lớn) → pressure thấp → nét mỏng
  /// Nếu vẽ chậm (v nhỏ) → pressure cao → nét dày
  static double calculatePressure({
    required Offset current,
    required Offset previous,
    required int currentTime,
    required int previousTime,
    double dampingFactor = 0.003,
    double minPressure = 0.15,
    double maxPressure = 1.0,
  }) {
    final distance = (current - previous).distance;
    final timeDelta = (currentTime - previousTime).abs();
    if (timeDelta == 0) return 0.5;

    final velocity = distance / timeDelta; // px/ms
    // Áp lực tỷ lệ nghịch với velocity
    final pressure = 1.0 - velocity * dampingFactor;
    return pressure.clamp(minPressure, maxPressure);
  }

  /// Chuyển tất cả points sang format cho perfect_freehand
  List<List<double>> toFreehandPoints() {
    return points.map((p) => p.toFreehandPoint()).toList();
  }

  /// Serialize thành Map (để export JSON)
  Map<String, dynamic> toJson() {
    return {
      'points': points.map((p) => {
        'x': p.position.dx,
        'y': p.position.dy,
        'pressure': p.pressure,
        'timestamp': p.timestamp,
      }).toList(),
      'color': color.toARGB32(),
      'baseWidth': baseWidth,
      'brushType': brushType.name,
    };
  }

  /// Deserialize từ Map
  factory Stroke.fromJson(Map<String, dynamic> json) {
    final points = (json['points'] as List).map((p) {
      return StrokePoint(
        position: Offset(
          (p['x'] as num).toDouble(),
          (p['y'] as num).toDouble(),
        ),
        pressure: (p['pressure'] as num?)?.toDouble() ?? 0.5,
        timestamp: (p['timestamp'] as num?)?.toInt() ?? 0,
      );
    }).toList();

    return Stroke(
      points: points,
      color: Color(json['color'] as int),
      baseWidth: (json['baseWidth'] as num?)?.toDouble() ?? 3.0,
      brushType: BrushType.values.firstWhere(
        (b) => b.name == json['brushType'],
        orElse: () => BrushType.pen,
      ),
    );
  }
}
