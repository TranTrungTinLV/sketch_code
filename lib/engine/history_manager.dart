import 'package:sketch/model/stroke.dart';

/// Quản lý Undo/Redo bằng cấu trúc Dual Stack (LIFO).
///
/// - Vẽ xong nét → push vào displayStrokes, clear redoStack
/// - Undo → pop từ displayStrokes, push vào redoStack
/// - Redo → pop từ redoStack, push vào displayStrokes
///
/// Lưu trữ vector (chỉ lưu Stroke object), KHÔNG lưu bitmap.
class HistoryManager {
  final List<Stroke> _displayStrokes = [];
  final List<Stroke> _redoStack = [];

  /// Số lượng tối đa undo steps (tránh tràn bộ nhớ)
  final int maxUndoSteps;

  HistoryManager({this.maxUndoSteps = 500});

  /// Danh sách nét đang hiển thị (read-only)
  List<Stroke> get strokes => List.unmodifiable(_displayStrokes);

  /// Có thể undo không?
  bool get canUndo => _displayStrokes.isNotEmpty;

  /// Có thể redo không?
  bool get canRedo => _redoStack.isNotEmpty;

  /// Số nét hiện tại
  int get strokeCount => _displayStrokes.length;

  /// Thêm nét vẽ mới
  void addStroke(Stroke stroke) {
    _displayStrokes.add(stroke);
    _redoStack.clear(); // Xóa toàn bộ redo khi có nét mới

    // Giới hạn bộ nhớ
    if (_displayStrokes.length > maxUndoSteps) {
      _displayStrokes.removeAt(0);
    }
  }

  /// Undo: Rút stroke cuối → đẩy sang redoStack
  Stroke? undo() {
    if (!canUndo) return null;
    final stroke = _displayStrokes.removeLast();
    _redoStack.add(stroke);
    return stroke;
  }

  /// Redo: Rút stroke từ redoStack → đẩy lại displayStrokes
  Stroke? redo() {
    if (!canRedo) return null;
    final stroke = _redoStack.removeLast();
    _displayStrokes.add(stroke);
    return stroke;
  }

  /// Xóa toàn bộ canvas
  void clear() {
    _displayStrokes.clear();
    _redoStack.clear();
  }

  /// Lấy tất cả strokes để export
  List<Stroke> get allStrokes => List.from(_displayStrokes);
}
