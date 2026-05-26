import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sketch/engine/edge_detector.dart';
import 'package:sketch/engine/history_manager.dart';
import 'package:sketch/engine/shape_recognizer.dart';
import 'package:sketch/model/layer.dart';
import 'package:sketch/model/stroke.dart';
import 'package:sketch/screens/editor/canvas_area.dart';
import 'package:sketch/screens/editor/panels/layer_panel.dart';
import 'package:sketch/screens/editor/panels/left_sidebar.dart';
import 'package:sketch/screens/editor/panels/tool_bar.dart';
import 'package:sketch/services/export_service.dart';
import 'package:sketch/untils/app_colors.dart';
import 'package:sketch/untils/app_styles.dart';
import 'package:sketch/widgets/color_picker_bar.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  // ==================== Canvas ====================
  final GlobalKey _canvasBoundaryKey = GlobalKey();
  final TransformationController _transformController = TransformationController();

  // ==================== Layers ====================
  final List<CanvasLayer> _layers = [];
  final Map<String, List<Stroke>> _layerStrokes = {};
  final Map<String, Uint8List?> _layerImages = {};
  String _activeLayerId = '';
  int _layerCounter = 0;

  // ==================== Drawing ====================
  final HistoryManager _history = HistoryManager(maxUndoSteps: 500);
  List<StrokePoint> _currentStrokePoints = [];
  Color _selectedColor = Colors.black;
  double _strokeWidth = 3.0;
  BrushType _currentBrush = BrushType.pen;
  int _selectedTool = 0; // 0=pen,1=pencil,2=brush,3=marker,4=eraser
  Timer? _shapeRecognitionTimer;
  bool _isShapeSnapped = false;

  // ==================== UI State ====================
  int _sidebarIndex = 0;
  bool _showLayerPanel = true;
  bool _isScanning = false;
  final int _scanThreshold = 80;

  // ==================== Image Picker ====================
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Tạo layer vẽ mặc định
    _addDrawingLayer(name: 'Layer 1');
  }

  @override
  void dispose() {
    _shapeRecognitionTimer?.cancel();
    _transformController.dispose();
    super.dispose();
  }

  // ==================== Layer Management ====================
  void _addDrawingLayer({String? name}) {
    _layerCounter++;
    final id = 'layer_$_layerCounter';
    final layer = CanvasLayer.drawing(
      id: id,
      name: name ?? 'Layer $_layerCounter',
    );
    setState(() {
      _layers.add(layer);
      _layerStrokes[id] = [];
      _activeLayerId = id;
    });
  }

  void _deleteLayer(String layerId) {
    setState(() {
      _layers.removeWhere((l) => l.id == layerId);
      _layerStrokes.remove(layerId);
      _layerImages.remove(layerId);
      if (_activeLayerId == layerId && _layers.isNotEmpty) {
        // Switch to last drawing layer
        final drawingLayers = _layers.where((l) => l.type == LayerType.drawing);
        _activeLayerId = drawingLayers.isNotEmpty
            ? drawingLayers.last.id
            : _layers.last.id;
      }
    });
  }

  // ==================== Import Image ====================
  Future<void> _importImage() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      _layerCounter++;
      final id = 'ref_$_layerCounter';
      final layer = CanvasLayer.referenceImage(
        id: id,
        name: 'Reference ${_layers.where((l) => l.type == LayerType.referenceImage).length + 1}',
        bytes: bytes.toList(),
      );

      setState(() {
        // Insert reference image at bottom
        _layers.insert(0, layer);
        _layerImages[id] = bytes;
      });
    } catch (e) {
      debugPrint('Import error: $e');
    }
  }

  // ==================== Scan to Sketch ====================
  Future<void> _scanToSketch() async {
    // Find reference image layer
    final refLayer = _layers.where(
      (l) => l.type == LayerType.referenceImage && _layerImages[l.id] != null,
    );
    if (refLayer.isEmpty) {
      _showSnackBar('Import an image first to scan');
      return;
    }

    setState(() => _isScanning = true);

    final imageBytes = _layerImages[refLayer.first.id]!;

    // Run edge detection (thuần toán, không AI)
    final edgeBytes = EdgeDetector.detect(
      imageBytes,
      threshold: _scanThreshold,
    );

    if (edgeBytes != null) {
      _layerCounter++;
      final id = 'scan_$_layerCounter';
      final layer = CanvasLayer.scannedSketch(
        id: id,
        name: 'Sketch Scan',
        bytes: edgeBytes.toList(),
      );

      setState(() {
        // Insert scan layer above reference, below drawing
        final firstDrawingIndex = _layers.indexWhere(
          (l) => l.type == LayerType.drawing,
        );
        if (firstDrawingIndex >= 0) {
          _layers.insert(firstDrawingIndex, layer);
        } else {
          _layers.add(layer);
        }
        _layerImages[id] = edgeBytes;
        _isScanning = false;
      });
    } else {
      setState(() => _isScanning = false);
      _showSnackBar('Scan failed — try another image');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.bgSecondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==================== Drawing ====================
  void _onPanStart(Offset pos) {
    // Check layer locked
    final activeLayer = _layers.firstWhere(
      (l) => l.id == _activeLayerId,
      orElse: () => _layers.last,
    );
    if (activeLayer.locked || activeLayer.type != LayerType.drawing) return;

    _shapeRecognitionTimer?.cancel();
    _isShapeSnapped = false;

    setState(() {
      _currentStrokePoints = [
        StrokePoint(
          position: pos,
          pressure: 0.5,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      ];
    });
  }

  void _onPanUpdate(Offset pos) {
    if (_currentStrokePoints.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final lastPoint = _currentStrokePoints.last;

    // Tính pressure từ velocity
    final pressure = Stroke.calculatePressure(
      current: pos,
      previous: lastPoint.position,
      currentTime: now,
      previousTime: lastPoint.timestamp,
    );

    if (_isShapeSnapped) return; // Không vẽ tiếp nếu đã nắn thành hình

    setState(() {
      _currentStrokePoints.add(StrokePoint(
        position: pos,
        pressure: pressure,
        timestamp: now,
      ));
    });

    // Reset Timer 600ms
    _shapeRecognitionTimer?.cancel();
    _shapeRecognitionTimer = Timer(const Duration(milliseconds: 600), () {
      if (_currentStrokePoints.length < 10) return;
      final shaped = ShapeRecognizer.recognizeAndShape(_currentStrokePoints);
      if (shaped != null) {
        setState(() {
          _currentStrokePoints = shaped;
          _isShapeSnapped = true;
        });
      }
    });
  }

  void _onPanEnd() {
    _shapeRecognitionTimer?.cancel();
    _isShapeSnapped = false;
    
    if (_currentStrokePoints.length < 2) {
      _currentStrokePoints = [];
      return;
    }

    final brush = _selectedTool == 4 ? BrushType.eraser : _currentBrush;

    final stroke = Stroke(
      points: List.from(_currentStrokePoints),
      color: _selectedColor,
      baseWidth: _strokeWidth,
      brushType: brush,
    );

    setState(() {
      _history.addStroke(stroke);
      _layerStrokes[_activeLayerId] = _history.strokes;
      _currentStrokePoints = [];
    });
  }

  void _undo() {
    if (!_history.canUndo) return;
    setState(() {
      _history.undo();
      _layerStrokes[_activeLayerId] = _history.strokes;
    });
  }

  void _redo() {
    if (!_history.canRedo) return;
    setState(() {
      _history.redo();
      _layerStrokes[_activeLayerId] = _history.strokes;
    });
  }

  void _clearCanvas() {
    setState(() {
      _history.clear();
      _layerStrokes[_activeLayerId] = [];
    });
  }

  // ==================== Tool selection ====================
  void _selectTool(int index) {
    setState(() {
      _selectedTool = index;
      switch (index) {
        case 0: _currentBrush = BrushType.pen; break;
        case 1: _currentBrush = BrushType.pencil; break;
        case 2: _currentBrush = BrushType.brush; break;
        case 3: _currentBrush = BrushType.marker; break;
        case 4: _currentBrush = BrushType.eraser; break;
      }
    });
  }

  // ==================== Export ====================
  Future<void> _exportPng() async {
    final bytes = await ExportService.exportToPng(_canvasBoundaryKey);
    if (bytes != null) {
      _showSnackBar('Exported PNG (${bytes.length} bytes)');
    }
  }

  // ==================== Build ====================
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final zoomPercent = (_transformController.value.getMaxScaleOnAxis() * 100).round();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.keyZ &&
                HardwareKeyboard.instance.isControlPressed) {
              if (HardwareKeyboard.instance.isShiftPressed) {
                _redo();
              } else {
                _undo();
              }
            }
          }
        },
        child: Column(
          children: [
            _buildTopBar(isMobile),
            Expanded(
              child: Row(
                children: [
                  if (!isMobile)
                    LeftSidebar(
                      selectedIndex: _sidebarIndex,
                      onItemSelected: (i) => setState(() => _sidebarIndex = i),
                    ),

                  ToolBar(
                    selectedTool: _selectedTool,
                    onToolSelected: _selectTool,
                    selectedColor: _selectedColor,
                    onColorSelected: (c) => setState(() => _selectedColor = c),
                  ),

                  // Canvas
                  Expanded(
                    child: Stack(
                      children: [
                        // Multi-layer canvas
                        CanvasArea(
                          canvasBoundaryKey: _canvasBoundaryKey,
                          transformController: _transformController,
                          layers: _layers,
                          layerStrokes: _layerStrokes,
                          currentStrokePoints: _currentStrokePoints,
                          currentColor: _selectedColor,
                          currentStrokeWidth: _strokeWidth,
                          currentBrush: _selectedTool == 4
                              ? BrushType.eraser
                              : _currentBrush,
                          activeLayerId: _activeLayerId,
                          layerImages: _layerImages,
                          onPanStart: _onPanStart,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                        ),

                        // Color picker bar
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ColorPickerBar(
                              selectedColor: _selectedColor,
                              onColorSelected: (c) =>
                                  setState(() => _selectedColor = c),
                            ),
                          ),
                        ),

                        // Brush size indicator
                        Positioned(
                          bottom: 80,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: _BrushSizeControl(
                              size: _strokeWidth,
                              onChanged: (v) => setState(() => _strokeWidth = v),
                            ),
                          ),
                        ),

                        // Scanning indicator
                        if (_isScanning)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black54,
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: AppColors.accentGreen,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Scanning edges...',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Zoom info
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.bgSecondary,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              '$zoomPercent%',
                              style: AppStyles.caption(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Layer panel (right side)
                  if (_showLayerPanel && !isMobile)
                    Container(
                      width: 240,
                      decoration: const BoxDecoration(
                        color: AppColors.bgSidebar,
                        border: Border(
                          left: BorderSide(color: AppColors.border, width: 1),
                        ),
                      ),
                      child: LayerPanel(
                        layers: _layers,
                        activeLayerId: _activeLayerId,
                        onLayerSelected: (id) =>
                            setState(() => _activeLayerId = id),
                        onOpacityChanged: (id, v) => setState(() {
                          _layers.firstWhere((l) => l.id == id).opacity = v;
                        }),
                        onVisibilityChanged: (id, v) => setState(() {
                          _layers.firstWhere((l) => l.id == id).visible = v;
                        }),
                        onLockChanged: (id, v) => setState(() {
                          _layers.firstWhere((l) => l.id == id).locked = v;
                        }),
                        onAddLayer: () => _addDrawingLayer(),
                        onDeleteLayer: _deleteLayer,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: isMobile
          ? Drawer(
              backgroundColor: AppColors.bgSidebar,
              child: LeftSidebar(
                selectedIndex: _sidebarIndex,
                onItemSelected: (i) {
                  setState(() => _sidebarIndex = i);
                  Navigator.pop(context);
                },
              ),
            )
          : null,
    );
  }

  // ==================== Top Bar ====================
  Widget _buildTopBar(bool isMobile) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.bgSidebar,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),

          // Logo
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: AppColors.primaryGradient,
            ),
            child: const Icon(Icons.brush, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Text('DoodleMaster', style: AppStyles.heading3(fontSize: 15)),

          const Spacer(),

          // Import Image
          _TopBtn(
            icon: Icons.image_outlined,
            label: 'Import',
            onTap: _importImage,
          ),
          const SizedBox(width: 6),

          // Scan to Sketch
          _TopBtn(
            icon: Icons.document_scanner_outlined,
            label: 'Scan',
            onTap: _scanToSketch,
          ),
          const SizedBox(width: 12),

          // Undo / Redo / Clear
          _TopIconBtn(
            icon: Icons.undo,
            onTap: _undo,
            enabled: _history.canUndo,
            tooltip: 'Undo (Ctrl+Z)',
          ),
          _TopIconBtn(
            icon: Icons.redo,
            onTap: _redo,
            enabled: _history.canRedo,
            tooltip: 'Redo (Ctrl+Shift+Z)',
          ),
          _TopIconBtn(
            icon: Icons.delete_outline,
            onTap: _clearCanvas,
            tooltip: 'Clear',
          ),

          const SizedBox(width: 8),

          // Toggle layer panel
          _TopIconBtn(
            icon: Icons.layers,
            onTap: () => setState(() => _showLayerPanel = !_showLayerPanel),
            tooltip: 'Layers',
          ),

          const SizedBox(width: 8),

          // Export
          OutlinedButton.icon(
            onPressed: _exportPng,
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Export'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ),

          if (!isMobile) ...[
            const SizedBox(width: 12),
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.bgCard,
              child: Icon(Icons.person, color: AppColors.textSecondary, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

// ==================== Helper Widgets ====================

class _TopBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TopBtn({required this.icon, required this.label, required this.onTap});

  @override
  State<_TopBtn> createState() => _TopBtnState();
}

class _TopBtnState extends State<_TopBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.bgInput : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _hovered ? AppColors.border : Colors.transparent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16,
                color: _hovered ? AppColors.textPrimary : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(widget.label, style: AppStyles.caption(
                color: _hovered ? AppColors.textPrimary : AppColors.textSecondary,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopIconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final String tooltip;

  const _TopIconBtn({
    required this.icon,
    required this.onTap,
    this.enabled = true,
    required this.tooltip,
  });

  @override
  State<_TopIconBtn> createState() => _TopIconBtnState();
}

class _TopIconBtnState extends State<_TopIconBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.enabled ? widget.onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34,
            height: 34,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _hovered && widget.enabled
                  ? AppColors.bgInput
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: widget.enabled
                  ? (_hovered ? AppColors.textPrimary : AppColors.textSecondary)
                  : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _BrushSizeControl extends StatelessWidget {
  final double size;
  final Function(double) onChanged;

  const _BrushSizeControl({required this.size, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary.withAlpha(220),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 6, color: AppColors.textMuted),
          SizedBox(
            width: 120,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                activeTrackColor: AppColors.textSecondary,
                inactiveTrackColor: AppColors.border,
                thumbColor: AppColors.textPrimary,
              ),
              child: Slider(
                value: size,
                min: 1.0,
                max: 20.0,
                onChanged: onChanged,
              ),
            ),
          ),
          const Icon(Icons.circle, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text('${size.round()}px', style: AppStyles.caption()),
        ],
      ),
    );
  }
}
