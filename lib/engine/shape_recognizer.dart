import 'dart:math';
import 'dart:ui';
import 'package:sketch/model/stroke.dart';

/// Heuristic-based Shape Recognition (Không dùng AI)
class ShapeRecognizer {
  /// Chấp nhận một nét vẽ méo mó và trả về nét vẽ chuẩn (nếu nhận diện được).
  /// Trả về null nếu không nhận diện được hình cơ bản.
  static List<StrokePoint>? recognizeAndShape(List<StrokePoint> original) {
    if (original.length < 10) return null;

    final points = original.map((p) => p.position).toList();
    final first = points.first;
    final last = points.last;
    
    // Khoảng cách 2 điểm đầu cuối
    final distEndToStart = (first - last).distance;
    final bounds = _getBoundingBox(points);
    final diagonal = (bounds.topLeft - bounds.bottomRight).distance;

    final isClosed = distEndToStart < (diagonal * 0.15); // Đóng kín nếu gần nhau

    if (!isClosed) {
      // 1. Nhận diện ĐƯỜNG THẲNG
      // Tính max deviation (khoảng cách vuông góc lớn nhất từ 1 điểm đến đường thẳng)
      double maxDev = 0;
      for (var p in points) {
        final d = _pointLineDistance(p, first, last);
        if (d > maxDev) maxDev = d;
      }
      
      // Nếu méo ít hơn 10% chiều dài
      if (maxDev < diagonal * 0.1) {
        return _generateLine(first, last, original);
      }
    } else {
      // 2. Nhận diện VÒNG TRÒN / OVAL
      final center = Offset(
        bounds.left + bounds.width / 2,
        bounds.top + bounds.height / 2,
      );
      final rx = bounds.width / 2;
      final ry = bounds.height / 2;

      // Kiểm tra độ lệch so với elip lý tưởng
      double avgDeviation = 0;
      for (var p in points) {
        // Chuẩn hóa tọa độ theo (rx, ry)
        final nx = (p.dx - center.dx) / (rx == 0 ? 1 : rx);
        final ny = (p.dy - center.dy) / (ry == 0 ? 1 : ry);
        // Với elip chuẩn, nx^2 + ny^2 = 1
        final val = nx * nx + ny * ny;
        avgDeviation += (1 - val).abs();
      }
      avgDeviation /= points.length;

      if (avgDeviation < 0.25) { // Sai số nhỏ
        return _generateEllipse(center, rx, ry, original);
      }

      // 3. Nhận diện ĐA GIÁC (Ramer-Douglas-Peucker)
      // Dùng epsilon khoảng 10% đường chéo
      final simplified = _rdpSimplify(points, diagonal * 0.1);
      
      // Khép kín đa giác
      if ((simplified.first - simplified.last).distance > 10) {
        simplified.add(simplified.first);
      }

      // Số góc (loại bỏ điểm trùng/thẳng hàng)
      if (simplified.length == 4) { // Tam giác (3 cạnh + quay về)
        return _generatePolygon(simplified, original);
      } else if (simplified.length == 5) { // Tứ giác (4 cạnh + quay về)
        // Check chữ nhật (góc vuông)
        return _generatePolygon(simplified, original);
      }
    }

    return null;
  }

  // ==================== BỘ TẠO NÉT CHUẨN (GENERATORS) ====================
  
  static List<StrokePoint> _generateLine(Offset start, Offset end, List<StrokePoint> ref) {
    final pressure = ref.first.pressure;
    final int count = ref.length;
    final List<StrokePoint> result = [];
    
    for (int i = 0; i < count; i++) {
      final t = i / (count - 1);
      final pos = Offset.lerp(start, end, t)!;
      result.add(StrokePoint(
        position: pos,
        pressure: pressure,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    return result;
  }

  static List<StrokePoint> _generateEllipse(Offset center, double rx, double ry, List<StrokePoint> ref) {
    final pressure = ref.first.pressure;
    final int count = max(40, ref.length);
    final List<StrokePoint> result = [];
    
    for (int i = 0; i < count; i++) {
      final angle = (i / (count - 1)) * 2 * pi;
      final pos = Offset(
        center.dx + rx * cos(angle),
        center.dy + ry * sin(angle),
      );
      result.add(StrokePoint(
        position: pos,
        pressure: pressure,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    return result;
  }

  static List<StrokePoint> _generatePolygon(List<Offset> corners, List<StrokePoint> ref) {
    final pressure = ref.first.pressure;
    final List<StrokePoint> result = [];
    // Phân bổ đều số điểm cho các cạnh
    final pointsPerEdge = max(10, ref.length ~/ (corners.length - 1));

    for (int i = 0; i < corners.length - 1; i++) {
      final start = corners[i];
      final end = corners[i + 1];
      for (int j = 0; j < pointsPerEdge; j++) {
        final t = j / pointsPerEdge; // Bỏ điểm cuối để ko trùng với đầu cạnh tiếp
        result.add(StrokePoint(
          position: Offset.lerp(start, end, t)!,
          pressure: pressure,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ));
      }
    }
    // Thêm điểm cuối cùng khép góc
    result.add(StrokePoint(
      position: corners.last,
      pressure: pressure,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ));

    return result;
  }

  // ==================== CÔNG CỤ TOÁN HỌC ====================

  static Rect _getBoundingBox(List<Offset> points) {
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (var p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  static double _pointLineDistance(Offset p, Offset a, Offset b) {
    final num = ((b.dy - a.dy) * p.dx - (b.dx - a.dx) * p.dy + b.dx * a.dy - b.dy * a.dx).abs();
    final den = (b - a).distance;
    if (den == 0) return (p - a).distance;
    return num / den;
  }

  static List<Offset> _rdpSimplify(List<Offset> points, double epsilon) {
    if (points.length < 3) return points;
    double dmax = 0;
    int index = 0;
    
    for (int i = 1; i < points.length - 1; i++) {
      double d = _pointLineDistance(points[i], points.first, points.last);
      if (d > dmax) {
        index = i;
        dmax = d;
      }
    }
    
    if (dmax > epsilon) {
      var rec1 = _rdpSimplify(points.sublist(0, index + 1), epsilon);
      var rec2 = _rdpSimplify(points.sublist(index), epsilon);
      return [...rec1.sublist(0, rec1.length - 1), ...rec2];
    } else {
      return [points.first, points.last];
    }
  }
}
