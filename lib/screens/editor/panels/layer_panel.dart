import 'package:flutter/material.dart';
import 'package:sketch/model/layer.dart';
import 'package:sketch/untils/app_colors.dart';
import 'package:sketch/untils/app_styles.dart';

/// Panel quản lý layer (giống Photoshop mini).
class LayerPanel extends StatelessWidget {
  final List<CanvasLayer> layers;
  final String activeLayerId;
  final Function(String) onLayerSelected;
  final Function(String, double) onOpacityChanged;
  final Function(String, bool) onVisibilityChanged;
  final Function(String, bool) onLockChanged;
  final VoidCallback onAddLayer;
  final Function(String) onDeleteLayer;

  const LayerPanel({
    super.key,
    required this.layers,
    required this.activeLayerId,
    required this.onLayerSelected,
    required this.onOpacityChanged,
    required this.onVisibilityChanged,
    required this.onLockChanged,
    required this.onAddLayer,
    required this.onDeleteLayer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text('Layers', style: AppStyles.heading3(fontSize: 14)),
              const Spacer(),
              _IconBtn(
                icon: Icons.add,
                tooltip: 'New drawing layer',
                onTap: onAddLayer,
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.border, height: 1),

        // Layer list (reversed — top layer first)
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: layers.length,
            itemBuilder: (context, index) {
              // Reverse: layer cuối (trên cùng) hiển thị trước
              final reverseIndex = layers.length - 1 - index;
              final layer = layers[reverseIndex];
              final isActive = layer.id == activeLayerId;

              return _LayerTile(
                layer: layer,
                isActive: isActive,
                onTap: () => onLayerSelected(layer.id),
                onOpacityChanged: (v) => onOpacityChanged(layer.id, v),
                onVisibilityChanged: (v) => onVisibilityChanged(layer.id, v),
                onLockChanged: (v) => onLockChanged(layer.id, v),
                onDelete: layer.type == LayerType.drawing
                    ? () => onDeleteLayer(layer.id)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LayerTile extends StatefulWidget {
  final CanvasLayer layer;
  final bool isActive;
  final VoidCallback onTap;
  final Function(double) onOpacityChanged;
  final Function(bool) onVisibilityChanged;
  final Function(bool) onLockChanged;
  final VoidCallback? onDelete;

  const _LayerTile({
    required this.layer,
    required this.isActive,
    required this.onTap,
    required this.onOpacityChanged,
    required this.onVisibilityChanged,
    required this.onLockChanged,
    this.onDelete,
  });

  @override
  State<_LayerTile> createState() => _LayerTileState();
}

class _LayerTileState extends State<_LayerTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isActive
              ? AppColors.accentGreen.withAlpha(20)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.isActive ? AppColors.accentGreen.withAlpha(80) : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Visibility toggle
                GestureDetector(
                  onTap: () => widget.onVisibilityChanged(!widget.layer.visible),
                  child: Icon(
                    widget.layer.visible ? Icons.visibility : Icons.visibility_off,
                    size: 16,
                    color: widget.layer.visible
                        ? AppColors.textSecondary
                        : AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 8),

                // Type icon
                Text(widget.layer.typeIcon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),

                // Name
                Expanded(
                  child: Text(
                    widget.layer.name,
                    style: AppStyles.bodyMedium(
                      color: widget.isActive
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Lock
                GestureDetector(
                  onTap: () => widget.onLockChanged(!widget.layer.locked),
                  child: Icon(
                    widget.layer.locked ? Icons.lock : Icons.lock_open,
                    size: 14,
                    color: widget.layer.locked
                        ? AppColors.accentOrange
                        : AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 4),

                // Expand opacity slider
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ),

                // Delete (only drawing layers)
                if (widget.onDelete != null) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: const Icon(Icons.close, size: 14, color: AppColors.textMuted),
                  ),
                ],
              ],
            ),

            // Opacity slider (expandable)
            if (_expanded) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    'Opacity',
                    style: AppStyles.caption(color: AppColors.textMuted),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        activeTrackColor: AppColors.accentGreen,
                        inactiveTrackColor: AppColors.border,
                        thumbColor: AppColors.accentGreen,
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      ),
                      child: Slider(
                        value: widget.layer.opacity,
                        min: 0.0,
                        max: 1.0,
                        onChanged: widget.onOpacityChanged,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${(widget.layer.opacity * 100).round()}%',
                      style: AppStyles.caption(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 14, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
