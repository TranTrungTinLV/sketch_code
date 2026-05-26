import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Edge Detector thuần Dart — Sobel Operator.
///
/// Pipeline: Ảnh gốc → Grayscale → Gaussian Blur → Sobel → Threshold → Ảnh trắng đen.
/// Không dùng AI, chỉ dùng toán ma trận pixel.
class EdgeDetector {
  /// Chạy full pipeline edge detection.
  /// [imageBytes]: bytes ảnh gốc (PNG/JPEG)
  /// [threshold]: ngưỡng lọc (0-255), user điều chỉnh qua Slider
  /// Returns: bytes ảnh trắng đen (PNG)
  static Uint8List? detect(Uint8List imageBytes, {int threshold = 80}) {
    try {
      // Decode ảnh
      final original = img.decodeImage(imageBytes);
      if (original == null) return null;

      // Resize nếu quá lớn (tiết kiệm bộ nhớ)
      img.Image source = original;
      if (source.width > 1024 || source.height > 1024) {
        source = img.copyResize(source,
          width: source.width > source.height ? 1024 : null,
          height: source.height >= source.width ? 1024 : null,
        );
      }

      // Bước 1: Grayscale
      final grayscale = img.grayscale(source);

      // Bước 2: Gaussian Blur (khử nhiễu)
      final blurred = img.gaussianBlur(grayscale, radius: 2);

      // Bước 3: Sobel Edge Detection
      final edges = _sobelOperator(blurred);

      // Bước 4: Thresholding (nhị phân hóa)
      final binary = _applyThreshold(edges, threshold);

      // Bước 5: Đảo màu (nét đen trên nền trắng)
      final inverted = img.invert(binary);

      return Uint8List.fromList(img.encodePng(inverted));
    } catch (e) {
      return null;
    }
  }

  /// Toán tử Sobel: Tính gradient tại mỗi pixel.
  /// Dùng 2 kernel 3x3 (Gx và Gy) để tính đạo hàm theo X và Y.
  static img.Image _sobelOperator(img.Image source) {
    final w = source.width;
    final h = source.height;
    final result = img.Image(width: w, height: h);

    // Sobel kernels
    const gx = [
      [-1, 0, 1],
      [-2, 0, 2],
      [-1, 0, 1],
    ];
    const gy = [
      [-1, -2, -1],
      [0, 0, 0],
      [1, 2, 1],
    ];

    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        double sumX = 0;
        double sumY = 0;

        // Áp dụng kernel 3x3
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final pixel = source.getPixel(x + kx, y + ky);
            final intensity = pixel.r.toDouble(); // Ảnh grayscale nên r=g=b

            sumX += intensity * gx[ky + 1][kx + 1];
            sumY += intensity * gy[ky + 1][kx + 1];
          }
        }

        // Magnitude = sqrt(Gx² + Gy²)
        final magnitude = sqrt(sumX * sumX + sumY * sumY).clamp(0, 255).toInt();

        result.setPixelRgb(x, y, magnitude, magnitude, magnitude);
      }
    }

    return result;
  }

  /// Nhị phân hóa: Pixel > threshold → trắng, ngược lại → đen
  static img.Image _applyThreshold(img.Image source, int threshold) {
    final w = source.width;
    final h = source.height;
    final result = img.Image(width: w, height: h);

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final pixel = source.getPixel(x, y);
        final value = pixel.r.toInt();
        final bw = value > threshold ? 255 : 0;
        result.setPixelRgb(x, y, bw, bw, bw);
      }
    }

    return result;
  }
}
