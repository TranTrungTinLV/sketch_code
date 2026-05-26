

/// Loại layer
enum LayerType {
  referenceImage,  // Layer 0: Ảnh gốc import
  scannedSketch,   // Layer 1: Ảnh đã scan (edge detection)
  drawing,         // Layer 2+: Nét vẽ người dùng
}

/// Một layer trên canvas
class CanvasLayer {
  final String id;
  String name;
  final LayerType type;
  double opacity;        // 0.0 → 1.0
  bool visible;
  bool locked;           // Không cho vẽ/xóa trên layer này

  // Dữ liệu theo loại layer
  String? imagePath;     // Đường dẫn ảnh (cho referenceImage / scannedSketch)
  List<int>? imageBytes; // Bytes ảnh (khi load từ memory)

  CanvasLayer({
    required this.id,
    required this.name,
    required this.type,
    this.opacity = 1.0,
    this.visible = true,
    this.locked = false,
    this.imagePath,
    this.imageBytes,
  });

  /// Tạo layer ảnh tham khảo
  factory CanvasLayer.referenceImage({
    required String id,
    required String name,
    String? path,
    List<int>? bytes,
  }) {
    return CanvasLayer(
      id: id,
      name: name,
      type: LayerType.referenceImage,
      opacity: 0.4, // Mặc định mờ để dễ trace
      locked: true,  // Không cho vẽ lên ảnh gốc
      imagePath: path,
      imageBytes: bytes,
    );
  }

  /// Tạo layer scan (edge detected)
  factory CanvasLayer.scannedSketch({
    required String id,
    required String name,
    List<int>? bytes,
  }) {
    return CanvasLayer(
      id: id,
      name: name,
      type: LayerType.scannedSketch,
      opacity: 0.6,
      locked: true,
      imageBytes: bytes,
    );
  }

  /// Tạo layer vẽ mới
  factory CanvasLayer.drawing({
    required String id,
    required String name,
  }) {
    return CanvasLayer(
      id: id,
      name: name,
      type: LayerType.drawing,
      opacity: 1.0,
      locked: false,
    );
  }

  /// Icon cho layer type
  String get typeIcon {
    switch (type) {
      case LayerType.referenceImage:
        return '🖼️';
      case LayerType.scannedSketch:
        return '📋';
      case LayerType.drawing:
        return '✏️';
    }
  }
}
